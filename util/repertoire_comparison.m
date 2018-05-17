% repertoire_comparison
function [mssim, mssim_diag, similarity_score_mean, similarity_score_highactivity, diag_ssim, ndx_permutation] = repertoire_comparison(W1, H1, W2, H2 )

    % parameters
    rDim = length(W1);

    % rescale range
    L=255;
    W1max = max(cellfun(@(x) max(max(x)), W1, 'UniformOutput',1));
    W2max = max(cellfun(@(x) max(max(x)), W2, 'UniformOutput',1));

    % rerank based on occurency
    [activations_tot]=hist(H1,rDim);
    [~,ondx]=sort(activations_tot./sum(activations_tot)*100,'descend');
    activations_cumsum=(cumsum(activations_tot./sum(activations_tot)*100));
    [~, nbestMin]=min(abs(activations_cumsum-5));
    [~, nbest25]=min(abs(activations_cumsum-25));
    [~, nbest50]=min(abs(activations_cumsum-50));
    [~, nbest75]=min(abs(activations_cumsum-75));
    [~, nbestMax]=min(abs(activations_cumsum-95));
    nbestAll=length(activations_cumsum);
    H1=H1(ondx);
    W1=W1(ondx);
    [activations_tot]=hist(H2,rDim);
    [~,ondx]=sort(activations_tot./sum(activations_tot)*100,'descend');
    H2=H2(ondx);
    W2=W2(ondx);

    % smooth
    %W1=cellfun(@(x) smooth2(x,1), W1,'uni',0);
    %W2=cellfun(@(x) smooth2(x,1), W2,'uni',0);

    % reshape
    W1=cell2mat( cellfun(@(x) reshape(x,prod(size(x)),1), W1,'uni',0)');
    W2=cell2mat( cellfun(@(x) reshape(x,prod(size(x)),1), W2,'uni',0)');

    % correlation distance
    measure_corr = bsxfun(@(x, y) corr(x,y), W1, W2);

    % cosine distance
    dotproduct = bsxfun(@(x, y) x'*y, W1, W2);
    normW1 = sqrt(sum(W1.^2,1));
    normW2 = sqrt(sum(W2.^2,1));
    normproduct = normW1'*normW2;
    measure_cosd = dotproduct./normproduct;

    mssim  = ( measure_cosd + measure_corr )./2 ;
    mssim  = ( measure_corr )./1 ;
    [similarity_score_mean, mssim_diag, diag_ssim, ndx_permutation ] = diag_score( mssim );
    similarity_score_highactivity=zeros(1,3);
    mssim_diag=cell(1,5);
    [similarity_score_highactivity(1), mssim_diag{1}] = highactivity_score(mssim, nbestMin);
    [similarity_score_highactivity(2), mssim_diag{2}] = highactivity_score(mssim, nbest25);
    [similarity_score_highactivity(3), mssim_diag{3}] = highactivity_score(mssim, nbest50);
    [similarity_score_highactivity(4), mssim_diag{4}]= highactivity_score(mssim, nbest75);
    [similarity_score_highactivity(5), mssim_diag{5}]= highactivity_score(mssim, nbestMax);
    [similarity_score_highactivity(6), mssim_diag{6}]= highactivity_score(mssim, nbestAll);

end

% normalize
function Anorm = normalize(A)
    Anorm = (A - min(min(A)))/(max(max(A)) - min(min(A)));
end

% diag_score
function [sim_score_mean, mssim_diag, diag_ssim, ndx_permutation] = diag_score(mssim)

    % diagonalize
    rDim=size(mssim,1);
    tmp = mssim;
    mssim_diag = zeros(size(mssim));
    for l=1:rDim, 
        [val1,ndx1]=max(tmp);
        [val2,ndx2]=max(val1);
        col = ndx2;
        row = ndx1(ndx2);
        mssim_diag(row+(l-1),l:end)=tmp(row, :);
        mssim_diag(l:end, col+(l-1))=tmp(:, col);
        mssim_diag(:,[l col+(l-1)])=mssim_diag(:,[col+(l-1) l]);
        mssim_diag([l row+(l-1)],:)=mssim_diag([row+(l-1) l],:);
        tmp(row, :)=[];
        tmp(:, col)=[];
    end;

    ndx_permutation=zeros(rDim,1);
    for l=1:rDim, 
        ndx=find(sum(mssim==mssim_diag(l,l),2));
        k=0;
        while k<length(ndx)
            if ~ismember(ndx_permutation,ndx(k+1))
                ndx_permutation(l)=ndx(k+1);
            end
            k=k+1;
        end 

    end

    diag_energy = sum(diag(mssim_diag))./rDim; 
    tot_energy = (sum(sum(mssim_diag))-diag_energy)./(rDim*rDim-rDim);
    diag_ssim = diag(mssim_diag);
    sim_score_mean=[];
    sim_score_mean(3) = mean(diag_ssim(1:floor(1.0*rDim)));
    sim_score_mean(2) = mean(diag_ssim(1:floor(0.75*rDim)));
    sim_score_mean(1) = mean(diag_ssim(1:floor(0.5*rDim)));

end

% highactivity_score
function [sim_score_highactivity, mssim_diag] = highactivity_score(mssim, nbest)

    % diagonalize
    tmp = mssim(1:nbest, 1:end);
    mssim_diag = zeros(nbest, size(tmp,2));
    mssim_diag_diag = [];
    for l=1:nbest, 
        if l==nbest,
          ndx1 = ones(size(tmp,2),1);
          val1 = tmp;
        else
          [val1,ndx1]=max(tmp);
        end
        [val2,ndx2]=max(val1);
        col = ndx2;
        row = ndx1(ndx2);
        mssim_diag_diag = [ mssim_diag_diag tmp(row, col)];
        mssim_diag(row+(l-1),l:end)=tmp(row, :);
        mssim_diag(l:end, col+(l-1))=tmp(:, col);
        mssim_diag(:,[l col+(l-1)])=mssim_diag(:,[col+(l-1) l]);
        mssim_diag([l row+(l-1)],:)=mssim_diag([row+(l-1) l],:);
        tmp(row, :)=[];
        tmp(:, col)=[];
    end;


    mssim_diag=mssim_diag(1:nbest, 1:nbest);
    sim_score_highactivity = mean( mssim_diag_diag ); 

end

