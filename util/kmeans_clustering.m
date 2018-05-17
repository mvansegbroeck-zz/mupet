function [x,esq,j,model] = kmeans_clustering(d,k,K,maxIter,x0)
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
    fprintf('Max number of iterations: %i \n',maxIter);
    fprintf('iteration     ');
    while any(x(:) ~= y(:))
       ItNr=ItNr+1;
       if(ItNr>maxIter), break; end

       %z=eucl_dx(d',x')'; 
       z = pdist2( d, x, 'cosine');

       [m,j] = min(z,[],2);
       y = x;
       for i=1:k
          s = j==i;
          if any(s)
             x(i,:) = mean(d(s,:),1);
          else
             q=find(m~=0);
             if isempty(q) break; end
             r=q(ceil(rand*length(q)));
             x(i,:) = d(r,:);
             m(r)=0;
             y=x+1;
          end
       end
       fprintf('\b\b\b\b %3d', ItNr);
    end
    esq=mean(m,1);
    fprintf(' [done]\n');

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
