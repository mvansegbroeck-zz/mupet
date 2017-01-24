% ------------------------------------------------------------------------
% Copyright (C) 2015 University of Southern California, SAIL, U.S.
% Author: Maarten Van Segbroeck
% Mail: maarten@sipi.usc.edu
% Date: 2015-20-1
% ------------------------------------------------------------------------

function show_syllable_category_counts(handles,repertoireNames,NbCategories) 

guihandle=handles.output;

csvdir=fullfile(handles.repertoiredir,'CSV');
if ~exist(csvdir)
  mkdir(csvdir)
end

% csv header
csv_header=sprintf('%s,%s\n', ...
    'syllable category', ...
    'number of calls');

%figure
set(guihandle, 'HandleVisibility', 'off');
close all;
set(guihandle, 'HandleVisibility', 'on');
screenSize=get(0,'ScreenSize');
defaultFigPos=get(0,'DefaultFigurePosition');
basesunits=[];
basesactivations=cell(length(repertoireNames),1);

for repertoireID = 1:length(repertoireNames)
    
    repertoire_filename = fullfile(handles.repertoiredir,repertoireNames{repertoireID});    

    if ~exist(repertoire_filename)
        fprintf('Repertoire of data set does not exist. Build the repertoire.\n');
    else
        load(repertoire_filename,'bases','activations','NbUnits','NbChannels','NbPatternFrames');
    end
    basesunits=[basesunits; bases];
    basesactivations{repertoireID}=activations;
    
end

% 
figure('Position',[defaultFigPos(1) 0.90*screenSize(4)-defaultFigPos(4) defaultFigPos(3)*(1+fix(NbCategories/40)) defaultFigPos(4)]);
V=zeros(NbChannels*(NbPatternFrames+1), length(basesunits));
for k=1:length(basesunits)
  V(:,k)=reshape(basesunits{k}, NbChannels*(NbPatternFrames+1), 1);
end

% meta clustering
[W,J]=kmedoids(V, NbCategories);

% prepare outputs
linebases=cell(NbCategories,1);
for kk=1:NbCategories
    linebases{kk} = reshape(W(1:NbChannels*(NbPatternFrames+1),kk),NbChannels,(NbPatternFrames+1));
end

NbRows=5;
NbCols=floor(NbCategories/NbRows);
linebases_mat=zeros(NbChannels*NbRows,(NbPatternFrames+1)*NbCols);
for kk=1:NbRows
  for ll=1:NbCols
    base_unit_normalized = linebases{(NbRows-kk)*NbCols+ll}./max(max(linebases{(NbRows-kk)*NbCols+ll}));
    linebases_mat((kk-1)*NbChannels+1:kk*NbChannels,(ll-1)*(NbPatternFrames+1)+1:ll*(NbPatternFrames+1))=base_unit_normalized;
  end
end
imagesc(linebases_mat,[0 0.85]); axis xy; hold on;
for kk=1:NbCols-1
  plot([(NbPatternFrames+1)*kk+1,(NbPatternFrames+1)*kk+1],[1 NbRows*NbChannels],'Color',[0.2 0.2 0.2],'LineWidth',1);
end
for kk=1:NbRows-1
  plot([1 size(linebases_mat,2)],[kk*NbChannels+1 kk*NbChannels+1 ],'Color',[0.2 0.2 0.2],'LineWidth',1);
end
cnt=0;
offset1=6;
offset2=28;
for kk=NbRows-1:-1:0
    for jj=0:NbCols-1
        cnt=cnt+1;
        text(offset1+jj*(NbPatternFrames+1),(kk+1)*NbChannels-10,num2str(cnt),'Color','k','FontSize',handles.FontSize2,'fontweight','normal');
    end
end
set(gcf, 'Color', 'w');
set(gca,'XTick',[]);
set(gca,'YTick',[]);
ylabel('Gammatone channels','FontSize',handles.FontSize1);
colormap pink; colormap(flipud(colormap));
title(sprintf('Meta USV syllable repertoire'),'FontSize',handles.FontSize1,'fontweight','bold');
hold off;

% figure
xtickunits=2;
load('util/cmap.mat');
activation_pie=zeros(NbCategories,length(repertoireNames));
nb_of_calls_pie=zeros(NbCategories,length(repertoireNames));
for repertoireID = 1:length(repertoireNames)
    
    basesactivations{repertoireID}=activations;
    
    lineactivity=basesactivations{repertoireID};
    Jline=J((repertoireID-1)*NbUnits+1:repertoireID*NbUnits);
    for k=1:NbCategories
      activation_pie(k,repertoireID)=sum(lineactivity(Jline==k));
    end
    nb_of_calls_pie(:,repertoireID)=activation_pie(:,repertoireID);
    activation_pie(:,repertoireID)=100*activation_pie(:,repertoireID)./sum(activation_pie(:,repertoireID));
end
    
for repertoireID = 1:length(repertoireNames)
    
    figure('Position',[defaultFigPos(1)+(repertoireID)*25 0.90*screenSize(4)-defaultFigPos(4)-(repertoireID)*25 defaultFigPos(3) defaultFigPos(4)]);

    % pie diagram
    h=bar(nb_of_calls_pie(:,repertoireID)',1,'grouped');
    bar_child=get(h,'Children');
    colormap(cmap2);
    %set(bar_child,'CData',max(log(activation_pie(:,repertoireID)'),0));
    set(bar_child,'CData',max(log(min(activation_pie(:,repertoireID),25)'),0));
    set(gca,'XTick',[0:xtickunits:NbCategories]);
    xlim([.5 NbCategories+.5]);
    %ylim([0 40]);
    set(gca,'XGrid','off','YGrid','on','XMinorGrid','off');
    set(gca, 'Box', 'off', 'TickDir','out')
    repertoireName=strtrim(regexprep(strrep(repertoireNames{repertoireID},'.mat',''),'[_([{}()=''.(),;:%{%}!@])]',' ')); 
    title(sprintf('%s',strrep(repertoireName,'_',' ')),'FontSize',handles.FontSize1,'fontweight','bold');
    set(gca, 'FontSize',handles.FontSize2);
    set(gca, 'looseinset', get(gca, 'tightinset'));
%     ylabel('Activity counts (%%)','FontSize',handles.FontSize1);
    ylabel('Number of calls','FontSize',handles.FontSize1);
    xlabel('Repertoire units','FontSize',handles.FontSize1);
    axis('square')
    
    % CSV
    csvfile=fullfile(csvdir, sprintf('%s_syllable_category_counts_of_%i.csv',strrep(repertoireNames{repertoireID},'.mat',''),NbCategories));
    fid = fopen(csvfile,'wt');
    fwrite(fid, csv_header);
    for categoryID = 1:NbCategories
        % print category information
        category_info=sprintf('%i,%i\n', ...
            categoryID, ...
            nb_of_calls_pie(categoryID,repertoireID));
        fwrite(fid, category_info); 
    end
    fclose(fid);
end
    
