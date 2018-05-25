% diag_score
function [sim_score_mean, mssim_diag, diag_ssim, ndx_permutation, ndx_permutation_second] = diag_score(mssim)

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

    % main
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

    % comparing
    ndx_permutation_second=zeros(rDim,1);
    for l=1:rDim,
        ndx=find(sum(mssim==mssim_diag(l,l),1));
        k=0;
        while k<length(ndx)
            if ~ismember(ndx_permutation_second,ndx(k+1))
                ndx_permutation_second(l)=ndx(k+1);
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
