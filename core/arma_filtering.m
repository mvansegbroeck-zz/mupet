% arma_filtering
function featarma = arma_filtering(featmvn, M)
% ARMA Normalization using M-tap FIR
    featarma = featmvn;
    if size(featmvn,2) <= M
        return
    end
    tmp1 = sum(featarma(:,[1:M]),2);
    tmp2 = sum(featmvn(:,[M+1:2*M+1]),2);
    featarma(:,M+1) = ( tmp1 + tmp2 ) ./ ( 2*M + 1 );
    for t=M+2:size(featmvn,2)-M,
        tmp1 = tmp1 + featarma(:,t-1) - featarma(:,t-M-1);
        tmp2 = tmp2 + featmvn(:,t+M) - featmvn(:,t-1);
        featarma(:,t) = ( tmp1 + tmp2 ) ./ ( 2*M + 1 );
    end
end