% show_syllables
function show_syllables(handles,syllable_ndx)
    % make syllable patch
    syllable_gt = handles.syllable_data{2,syllable_ndx};
    syllable_duration=size(syllable_gt,2);
    syllable_patch_window=max(handles.patch_window,ceil(syllable_duration/2)*2);
    syllable_patch_gt = zeros(size(syllable_gt,1), syllable_patch_window);
    syllable_patch_window_start=floor(syllable_patch_window/2)-floor(syllable_duration/2);
    syllable_patch_gt(:, syllable_patch_window_start+1:syllable_patch_window_start+syllable_duration) = syllable_gt;
    syllable_fft = handles.syllable_data{3,syllable_ndx};
    syllable_fft_median=median(syllable_fft(:));
    syllable_fft_median=2*syllable_fft_median;
    syllable_patch_fft = syllable_fft_median*ones(size(syllable_fft,1), syllable_patch_window);
    syllable_duration=size(syllable_fft,2);
    syllable_patch_fft(:, syllable_patch_window_start+1:syllable_patch_window_start+syllable_duration) = syllable_fft;

    % fft figure
    axes(handles.syllable_axes_fft);
    syllable_patch_fft_dB=10*log10(abs(syllable_patch_fft(1:2:end,:)+1e-5)); % in dB
    fft_range_db1=-30;
    fft_range_db1_min=-30;
    fft_range_db2=0;
    fft_peak_db=handles.syllable_stats{12,syllable_ndx};
    fft_range=[fft_range_db1_min , fft_peak_db+fft_range_db2];
    imagesc(syllable_patch_fft_dB,fft_range); axis xy; colorbar;
    colormap default;
    colormap pink; colormap(flipud(colormap));
    set(gca,'YTick',[0:size(syllable_patch_fft_dB,1)/5:size(syllable_patch_fft_dB,1)]) % FFT bands
    set(gca,'YTickLabel',fix([0:handles.sample_frequency/2/5:handles.sample_frequency/2]/1e3)) % FFT bands
    set(gca,'XTick',[0:syllable_patch_window/6:syllable_patch_window]) % frequency
    set(gca,'XTickLabel',fix([0:handles.frame_shift_ms*syllable_patch_window/6:syllable_patch_window*handles.frame_shift_ms]*1e3)) % frequency
    set(gca, 'FontSize',handles.FontSize3,'FontName','default');
    xlabel('Time (milliseconds)','FontSize',handles.FontSize2,'FontName','default');
    ylabel('Frequency [kHz]','FontSize',handles.FontSize2,'FontName','default');
    title('Sonogram','FontSize',handles.FontSize1,'FontName','default','FontWeight','bold');
    ylim([size(syllable_fft,1)/125000*25000/2 size(syllable_fft,1)/2]);
    axvals=axis; %text(axvals(2)/2,axvals(4)/2,{'MUPET version 1.0', '(unreleased)'},'Color',[0.9 0.9 0.9],'FontSize',handles.FontSize1+10,'HorizontalAlignment','center','Rotation',45);

    % gt figure
    axes(handles.syllable_axes_gt);
    imagesc(syllable_patch_gt, [0, max(max(syllable_patch_gt))]); axis xy; colorbar;
    colormap default;
    colormap pink; colormap(flipud(colormap));
    set(gca,'YTick',[0:size(syllable_patch_gt,1)/4:size(syllable_patch_gt,1)]) % GT bands
    set(gca,'XTick',[0:syllable_patch_window/6:syllable_patch_window]) % frequency
    set(gca,'XTickLabel',fix([0:handles.frame_shift_ms*syllable_patch_window/6:syllable_patch_window*handles.frame_shift_ms]*1e3)) % frequency
    set(gca, 'FontSize',handles.FontSize3,'FontName','default');
    xlabel('Time (milliseconds)','FontSize',handles.FontSize2,'FontName','default');
    ylabel('Gammatone bands','FontSize',handles.FontSize2,'FontName','default');
    title('Gammatone representation','FontSize',handles.FontSize1,'FontName','default','fontweight','bold');
    axvals=axis; %text(axvals(2)/2,axvals(4)/2,{'MUPET version 1.0', '(unreleased)'},'Color',[0.9 0.9 0.9],'FontSize',handles.FontSize1+10,'HorizontalAlignment','center','Rotation',45);

    % display syllable information
    syllable_info_string1=sprintf('%s%s%s%s%s', ...
        sprintf('File: %s\n',handles.filename), ...
        sprintf('Number of syllables in file: %i\n', size(handles.syllable_stats,2)), ...
        sprintf('Syllable number shown: %i of %i\n',syllable_ndx, size(handles.syllable_stats,2)), ...
        sprintf('Syllable start time: %.4f sec\n',handles.syllable_stats{8,syllable_ndx}), ...
        sprintf('Syllable end time: %.4f sec\n',handles.syllable_stats{9,syllable_ndx}));
    set(handles.syllable_info_panel1, 'HorizontalAlignment', 'left');
    set(handles.syllable_info_panel1, 'FontSize',handles.FontSize2+1,'FontName','default');
    set(handles.syllable_info_panel1, 'FontAngle', 'normal');
    set(handles.syllable_info_panel1, 'string', syllable_info_string1);

    syllable_info_string2=sprintf('%s%s%s%s%s', ...
        sprintf('  starting frequency: %.2f kHz\n', handles.syllable_stats{2,syllable_ndx}), ...
        sprintf('  final frequency: %.2f kHz\n', handles.syllable_stats{3,syllable_ndx}), ...
        sprintf('  minimum frequency: %.2f kHz\n', handles.syllable_stats{4,syllable_ndx}), ...
        sprintf('  maximum frequency: %.2f kHz\n', handles.syllable_stats{5,syllable_ndx}), ...
        sprintf('  mean frequency: %.2f kHz\n',handles.syllable_stats{10,syllable_ndx}));
    set(handles.syllable_info_panel2, 'HorizontalAlignment', 'left');
    set(handles.syllable_info_panel2, 'FontSize',handles.FontSize2+1,'FontName','default');
    set(handles.syllable_info_panel2, 'FontAngle', 'normal');
    set(handles.syllable_info_panel2, 'string', syllable_info_string2);

    if handles.syllable_stats{14,syllable_ndx} == -100
        inter_syllable_interval='_';
    else
        if handles.syllable_stats{14,syllable_ndx}>=1e3
            inter_syllable_interval=sprintf('%.4f sec',handles.syllable_stats{14,syllable_ndx}/1e3);
        else
            inter_syllable_interval=sprintf('%.2f ms',handles.syllable_stats{14,syllable_ndx});
        end
    end

    % display syllable information
    syllable_info_string3=sprintf('%s%s%s%s%s%s', ...
        sprintf('  frequency bandwidth: %.2f kHz\n',handles.syllable_stats{6,syllable_ndx}), ...
        sprintf('  syllable duration: %.2f ms\n', handles.syllable_stats{13,syllable_ndx}), ...
        sprintf('  inter-syllable interval: %s\n',inter_syllable_interval), ...
        sprintf('  total syllable energy: %.2f dB\n', handles.syllable_stats{11,syllable_ndx}), ...
        sprintf('  peak syllable amplitude: %.2f dB\n', handles.syllable_stats{12,syllable_ndx}));
    set(handles.syllable_info_panel3, 'HorizontalAlignment', 'left');
    set(handles.syllable_info_panel3, 'FontSize',handles.FontSize2+1,'FontName','default');
    set(handles.syllable_info_panel3, 'FontAngle', 'normal');
    set(handles.syllable_info_panel3, 'string', syllable_info_string3);
end