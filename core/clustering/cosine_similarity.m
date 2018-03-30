% cosine similarity
function [cossim, cossim_logl, cossim_logl_sum] = cosine_similarity(X,y)
    cossim = [];
    for k = 1:size(X,1)
        cossim(end+1) = X(k,:)*y'/(norm(X(k,:),2)*norm(y,2));
    end
    cossim_logl = log(max((cossim+1)/2,1e-15));
    cossim_logl_sum = sum(cossim_logl);
end
