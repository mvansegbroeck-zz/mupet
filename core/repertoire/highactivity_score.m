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