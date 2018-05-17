%% PSD figures
figuredir='/Users/Maarten/Google Drive/SAIL/projects/USV analysis/Neuron/figures';
mkdir(fullfile(figuredir,'psd'));

nb_figs=length(findall(0,'type','figure'))-1;
for figID=1:nb_figs
    figure(figID); 
    h=get(gca,'Title');
    figtitle=strrep(h.String,'Data set: ','');
    figtitle=strrep(figtitle,':','/');
    figtitle=strrep(figtitle,'+','');
    title(figtitle);
    set(gcf,'Position', [50 200 2*150 2*150]);
    filename=strrep(figtitle,'/','_');
    hgexport(gcf,fullfile(figuredir,'psd',filename));
end

%% frequency bandwidth
figuredir='/Users/maarten/Google Drive/SAIL/projects/USV analysis/Neuron/figures';
mkdir(fullfile(figuredir,'frequency_bandwidth'));
figure(1); 
set(gcf,'Position', [50 200 3.5*150 3*150]);
fs=250e3;
fmax=fs/2;
fstart=25000;
fskip=25000;
set(gca,'XTick',[fstart:fskip:fmax]) % frequency
set(gca,'XTickLabel',fix([fstart:fskip:fmax]/1000),'FontName','Helvetica','FontSize',12) % frequency
xlim([fstart/2 fmax]);
xlabel('frequency (kHz)','FontSize',12);
title('Frequency bandwidth','FontSize',13,'fontweight','bold');
set(gca, 'FontSize',12);
hgexport(gcf,fullfile(figuredir,'frequency_bandwidth/overview_all_lines'));

%% syllable rate
figuredir='/Users/maarten/Google Drive/SAIL/projects/USV analysis/Neuron/figures';
mkdir(fullfile(figuredir,'syllable_rate'));
figure(1); 
set(gcf,'Position', [50 200 3.5*150 3*150]);
title('Syllable counts per second','FontSize',13,'fontweight','bold');
set(gca, 'FontSize',12);
hgexport(gcf,fullfile(figuredir,'syllable_rate/overview_all_lines'));

%% syllable duration
figuredir='/Users/maarten/Google Drive/SAIL/projects/USV analysis/Neuron/figures';
mkdir(fullfile(figuredir,'syllable_duration'));
figure(1); 
set(gcf,'Position', [50 200 3.5*150 3*150]);
title('Syllable duration','FontSize',13,'fontweight','bold');
set(gca, 'FontSize',12);
hgexport(gcf,fullfile(figuredir,'syllable_duration/overview_all_lines'));

%% syllable distance
figuredir='/Users/maarten/Google Drive/SAIL/projects/USV analysis/Neuron/figures';
mkdir(fullfile(figuredir,'syllable_distance'));
figure(1); 
set(gcf,'Position', [50 200 3.5*150 3*150]);
title('inter-syllable distance','FontSize',13,'fontweight','bold');
set(gca, 'FontSize',12);
xlim([0 140]);
hgexport(gcf,fullfile(figuredir,'syllable_distance/overview_all_lines'));

%% show repertoire
figuredir='/Users/maarten/Google Drive/SAIL/projects/USV analysis/Neuron/figures';
mkdir(fullfile(figuredir,'repertoires'));
nb_figs=length(findall(0,'type','figure'))-1;
for figID=1:nb_figs
    figure(figID); 
    h=get(gca,'Title');
    longtitle=strrep(h.String,'Syllable repertoire: ','');
    longtitle=strrep(longtitle,':','/');
    ndx=strfind(longtitle,' ');
    set(gcf,'Position', [50 200 7*150 1.75*150]);
    title(sprintf('%s repertoire',longtitle(1:ndx-1)),'FontSize',13,'fontweight','bold');
    set(gca, 'FontSize',12);
    filename=strrep(longtitle(1:ndx-1),'/','_');
    hgexport(gcf,sprintf(fullfile(figuredir,sprintf('repertoires/%s',filename))));
end

%% best match comparison
figuredir='/Users/maarten/Google Drive/SAIL/projects/USV analysis/Neuron/figures';
mkdir(fullfile(figuredir,'compare_best_match'));
nb_figs=length(findall(0,'type','figure'))-1;
for figID=1:2:nb_figs
    figure(figID+1); 
    set(gcf,'Position', [50 200 3*150 3*150]);
    h=get(gca,'Xlabel');
    longtitle=strrep(h.String,'Repertoire: ','');
    longtitle=strrep(longtitle,':','/');
    ndx=strfind(longtitle,' ');
    repertoire2=longtitle(ndx(1)+1:ndx(2)-1);
    xlabel(sprintf('%s',repertoire2),'FontSize',13,'fontweight','bold');
    h=get(gca,'Ylabel');
    longtitle=strrep(h.String,'Repertoire: ','');
    longtitle=strrep(longtitle,':','/');
    ndx=strfind(longtitle,' ');
    repertoire1=longtitle(ndx(1)+1:ndx(2)-1);
    ylabel(sprintf('%s',repertoire1),'FontSize',13,'fontweight','bold');
    set(gca, 'FontSize',12);
    filename=sprintf('%s_%s',strrep(repertoire1,'/','_'),strrep(repertoire2,'/','_'));
    hgexport(gcf,sprintf(fullfile(figuredir,sprintf('compare_best_match/correlation_%s',filename))));

    figure(figID); 
    set(gcf,'Position', [50 200 7*150 1.75*150]);
    title(sprintf('%s repertoire',repertoire1),'FontSize',13,'fontweight','bold');
    set(gca, 'FontSize',12);
    hgexport(gcf,sprintf(fullfile(figuredir,sprintf('compare_best_match/repertoire_%s',filename))));
    
end

%% activity based comparison
figuredir='/Users/maarten/Google Drive/SAIL/projects/USV analysis/Neuron/figures';
mkdir(fullfile(figuredir,'activity_based_match'));
nb_figs=length(findall(0,'type','figure'))-1;
for figID=1:nb_figs
    figure(figID); 
    h=get(gca,'Title');
    longtitle=cellstr(strrep(h.String,'Syllable repertoire: ',''));
    longtitle=strrep(longtitle,':','/');
    ndx=cell2mat(strfind(longtitle,' '));
    set(gcf,'Position', [50 200 6*115 2*115]);
    title(sprintf('%s repertoire',longtitle{1}(1:ndx(1)-1)),'FontSize',13,'fontweight','bold');
    set(gca, 'FontSize',12);
    filename=strrep(strrep(h.String,'Syllable repertoire: ',''),'/','_');
    xlabelnames=get(gca,'XTicklabel');
    xlabelnames = cellfun(@(x) strrep(x,':','/'),xlabelnames,'Un',0);
    xlabelnames = cellfun(@(x) strrep(x,' N80',''),xlabelnames,'Un',0);
    xlabelnames = cellfun(@(x) strrep(x,'+',''),xlabelnames,'Un',0);
    set(gca,'XTickLabel',xlabelnames);
    h=xticklabel_rotate([1:length(xlabelnames)],45,xlabelnames,'Fontsize',11);
    hgexport(gcf,sprintf(fullfile(figuredir,sprintf('activity_based_match/repertoire_%s',filename))));
end

%% activity based comparison with Studies
figuredir='/Users/maarten/Google Drive/SAIL/projects/USV analysis/Neuron/figures';
mkdir(fullfile(figuredir,'activity_based_match'));
nb_figs=length(findall(0,'type','figure'))-1;
for figID=1:nb_figs
    figure(figID); 
    h=get(gca,'Title');
    longtitle=cellstr(strrep(h.String,'Syllable repertoire: ',''));
    longtitle=strrep(longtitle,':','/');
    ndx=cell2mat(strfind(longtitle,' '));
    set(gcf,'Position', [50 200 7*150 4*150]);
    title(sprintf('%s repertoire',longtitle{1}(1:ndx(1)-1)),'FontSize',13,'fontweight','bold');
    set(gca, 'FontSize',12);
    filename=strrep(strrep(h.String,'Syllable repertoire: ',''),'/','_');
    xlabelnames=get(gca,'XTicklabel');
    xlabelnames = cellfun(@(x) strrep(x,':','/'),xlabelnames,'Un',0);
    xlabelnames = cellfun(@(x) strrep(x,' N80',''),xlabelnames,'Un',0);
    xlabelnames = cellfun(@(x) strrep(x,'tudy',''),xlabelnames,'Un',0);    
    xlabelnames = cellfun(@(x) strrep(x,'C57BL/6','B6'),xlabelnames,'Un',0);
    xlabelnames = cellfun(@(x) strrep(x,'DBA/2','D2'),xlabelnames,'Un',0);
    xlabelnames = cellfun(@(x) strrep(x,' (129)',''),xlabelnames,'Un',0);
    xlabelnames = cellfun(@(x) strrep(x,'+',''),xlabelnames,'Un',0);    
    xlabelnames = cellfun(@(x) strrep(x,'D2-S4','D2-S4(129)'),xlabelnames,'Un',0);
    xlabelnames = cellfun(@(x) strrep(x,'B6-S4','B6-S4(129)'),xlabelnames,'Un',0);
    set(gca,'XTickLabel',xlabelnames);
    h=xticklabel_rotate([1:length(xlabelnames)],45,xlabelnames,'Fontsize',11);
    hgexport(gcf,sprintf(fullfile(figuredir,sprintf('activity_based_match/repertoire_%s_vs_studies',filename))));
end

%% meta repertoire
figuredir='/Users/maarten/Google Drive/SAIL/projects/USV analysis/Neuron/figures';
mkdir(fullfile(figuredir,'meta_repertoires'));
figure(1); 
h=get(gca,'Title');
longtitle=strrep(h.String,'Syllable repertoire: ','');
longtitle=strrep(longtitle,':','/');
ndx=strfind(longtitle,' ');
set(gcf,'Position', [50 200 9*150 1.25*150]);
title(sprintf('%s repertoire',longtitle(1:ndx-1)),'FontSize',13,'fontweight','bold');
set(gca, 'FontSize',12);
filename=strrep(strrep(h.String,'Syllable repertoire: ',''),'/','_');
filename_addon='6lines_N160';
hgexport(gcf,sprintf(fullfile(figuredir,sprintf('meta_repertoires/%s_%s',filename,filename_addon))));

%% small repertoire
figuredir='/Users/maarten/Google Drive/SAIL/projects/USV analysis/Neuron/figures';
mkdir(fullfile(figuredir,'repertoire_learning_framework'));
figure(1); 
set(gcf,'Position', [50 200 2.25*150 1.25*150]);
title('repertoire units','FontSize',13,'fontweight','bold');
set(gca, 'FontSize',12);
hgexport(gcf,sprintf(fullfile(figuredir,sprintf('repertoire_learning_framework/repertoire'))));

%% small repertoire comparison
figuredir='/Users/maarten/Google Drive/SAIL/projects/USV analysis/Neuron/figures';
mkdir(fullfile(figuredir,'repertoire_learning_framework'));
figure(2); 
set(gcf,'Position', [50 200 2*150 2*150]);
ylabel(sprintf('Repertoire %i', 1),'FontSize',12,'FontWeight','bold');
xlabel(sprintf('Repertoire %i', 2),'FontSize',12,'FontWeight','bold');
set(gca, 'FontSize',12);
hgexport(gcf,sprintf(fullfile(figuredir,sprintf('repertoire_learning_framework/repertoire_comparison'))));


