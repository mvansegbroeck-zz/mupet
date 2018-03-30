% kmeans_clustering
function [x,esq,j,model,bic,logL,syllable_similarity,syllable_correlation,repertoire_similarity] = kmeans_clustering(d,k,K,maxIter,x0)
%KMEANS Vector quantisation using K-means algorithm [X,ESQ,J]=(D,K,X0)
%Inputs:
% D contains data vectors (one per row)
% K is number of centres required
% X0 are the initial centres (optional)
%
%Outputs:
% X is output row vectors (K rows)
% ESQ is mean square error
% J indicates which centre each data vector belongs to

    [n,p] = size(d);

    if nargin<3
      maxIter=100;
    end

    if nargin<4
      K=p;
    end
    N=p/K;

    if nargin<5 || isempty(x0)
       x = d(ceil(rand(1,k)*n),:);
       x = d(1:floor(size(d,1)/k):n,:);
       x = x(1:k,:);
    else
       x=full(x0);
    end
    y = x+1;

    z=zeros(n,k);
    ItNr=0;
    fprintf('K-Means Clustering (K=%i)\n',k);
    fprintf('Max number of iterations: %i \n',maxIter);
    fprintf('iteration     ');
    while any(x(:) ~= y(:))
       ItNr=ItNr+1;

       if(ItNr>maxIter), break; end

%        logL = 0;
       %z=eucl_dx(d',x')';
       z = pdist2( d, x, 'cosine');

       [m,j] = min(z,[],2);
       y = x;
       for i=1:k
          s = j==i;
          if any(s)
            % z_k = mean(pdist2( d(s,:), x(i,:), 'cosine'));
            x(i,:) = mean(d(s,:),1);
          else
             q=find(m~=0);
             if isempty(q) break; end
             r=q(ceil(rand*length(q)));
             x(i,:) = d(r,:);
             m(r)=0;
             y=x+1;
          end
%           logL_k = sum(log(max(1-pdist2( d(s,:), x(i,:), 'cosine'),1e-15)));
%           [~,~,logL_k] = cosine_similarity(d(s,:), x(i,:));
%           logL = logL + logL_k;
       end
%        bic = -2*logL + k*log(n);
%        fprintf('\n Iteration %3d | Log-likelihood: %.3f | BIC: %.3f ...',ItNr, logL, bic);

       fprintf('\b\b\b\b %3d' , ItNr);
    end

    syllable_correlation=zeros(2,k);
    syllable_similarity=zeros(2,k);
    repertoire_cossim=[];
    z = pdist2( d, x, 'cosine');
    [m,j] = min(z,[],2);
    logL = 0;
    for i=1:k
      s = j==i;
      [cossim,~,logL_k] = cosine_similarity(d(s,:), x(i,:));
      repertoire_cossim = [repertoire_cossim  cossim];
      measure_corr = corr(d(s,:)',x(i,:)');
      syllable_similarity(1,i) = mean(1-cossim);
      syllable_similarity(2,i) = std(1-cossim);
      syllable_correlation(1,i) = mean(measure_corr);
      syllable_correlation(2,i) = std(measure_corr);
      logL = logL + logL_k;
    end
    bic = -2*logL + k*log(n);
    repertoire_similarity = mean(repertoire_cossim);
    repertoire_similarity(end+1) = std(repertoire_cossim);
    fprintf('\n Log-likelihood: %.3f | BIC: %.3f ...',logL, bic);
    esq=mean(m,1);
    fprintf('\n [done]\n');

    if nargout > 3
      model.mu=zeros(size(x));
      model.var=zeros(size(x));
      for i=1:k
          di=d(j==1,:);
          model.mu(i,:)=x(i,:);
          model.var(i,:)=var(di);
      end
    end
end