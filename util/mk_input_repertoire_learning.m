% ------------------------------------------------------------------------
% Copyright (C) 2014 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2014-16-10
% ------------------------------------------------------------------------

function [gt_sonogram_out] = mk_input_repertoire_learning(gt_sonogram_in, K, N, TotNbFrames) 

    % parameters
    min_usv_activity_percentage=0.5;
    min_syllable_duration = 10;
    nb_of_syllables=length(gt_sonogram_in);

    % syllable activity
    usv_activity = size([gt_sonogram_in{:}],2)/TotNbFrames*100;
    if usv_activity < min_usv_activity_percentage
      fprintf('WARNING: file (less than %.2f%% of USV activity)\n',min_usv_activity_percentage);
    end

    % stacking syllable frames
    cnt=0;
    gt_sonogram_out=zeros(K*(N+1), nb_of_syllables);
    for k=1:nb_of_syllables,
        syllable=gt_sonogram_in{k};
        syllable_duration = size(gt_sonogram_in{k},2);
        if syllable_duration > N
            syllable=syllable(:,1:N+1);
            syllable_duration=N+1;
        end
        syllable_patch = zeros(K, N+1);
        cnt=cnt+1;
        gtcumsum=cumsum(sum(syllable,2));
        [~,gtcentern]=min(abs(gtcumsum-(gtcumsum(end)-gtcumsum(1))/2).^2);
        ndx_warp = mod([1:K]-(K/2-gtcentern),K)+1;
        syllable_patch(:, N/2-floor(syllable_duration/2)+1:N/2-floor(syllable_duration/2)+syllable_duration) = syllable(ndx_warp,:);
        gt_sonogram_out(:,cnt)=reshape(syllable_patch,(N+1)*K,1);
    end

    % trim
    gt_sonogram_out(:, end-(nb_of_syllables-cnt)+1:end) = [];

    end
