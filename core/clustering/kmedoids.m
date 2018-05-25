% kmedoids
function [medoids, label, energy, index] = kmedoids(X,k)
% X: d x n data matrix
% k: number of cluster

    v = dot(X,X,1);
    D1 = bsxfun(@plus,v,v')-2*(X'*X);

    dotproduct = bsxfun(@(x, y) x'*y,X,X);
    normX = sqrt(sum(X.^2,1));
    normproduct = normX'*normX;
    D2 = 1-dotproduct./normproduct;

    D = D1;

    n = size(X,2);
    [~,tmp]=sort(mean(D,2),'descend');
    [~, label] = min(D(tmp(1:k),:),[],1);
    last = 0;
    while any(label ~= last)
        [~, index] = min(D*sparse(1:n,label,1,n,k,n),[],1);
        last = label;
        [val, label] = min(D(index,:),[],1);
    end
    energy = sum(val);
    medoids = X(:,index);
end