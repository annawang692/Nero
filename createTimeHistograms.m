% Jacob Bakermans, February 2016
% Create plot of histogram evolution over time
function createTimeHistograms(allMolecules)   
    % Create dialog
    params = timeHistogramDialog();
    
    % User pressed cancel
    if any([params{:}] == -1)
        return
    end
    
    % Extract values from dialog
    if (params{1} == 1)
        includeAll = true;
    else
        includeAll = false;
        if (params{1} == 2)
            synced = false;
        else
            synced = true;
        end
    end
    if (isnan(params{2}))
        minAA = -Inf;
    else
        minAA = params{2};
    end
    if (isnan(params{3}))
        maxAA = Inf;
    else
        maxAA = params{3};
    end    
    if (isnan(params{4}))
        minDD = -Inf;
    else
        minDD = params{4};
    end
    if (isnan(params{5}))
        maxDD = Inf;
    else
        maxDD = params{5};
    end    
    if (isnan(params{6}))
        minDA = -Inf;
    else
        minDA = params{6};
    end
    if (isnan(params{7}))
        maxDA = Inf;
    else
        maxDA = params{7};
    end         
    if (isnan(params{8}))
        minFrame = 1;
    else
        minFrame = params{8};
    end
    if (isnan(params{9}))
        maxFrame = Inf;
    else
        maxFrame = params{9};
    end     
    
    % Generate histogram data
    histData = []; % m x 2 matrix, first column E, second column S
    maxT = 0;
    for (currentMol = 1:length(allMolecules))
        if (includeAll)
            AA = allMolecules{currentMol}.AA;
            DD = allMolecules{currentMol}.DD;
            DA = allMolecules{currentMol}.DA;
            E = allMolecules{currentMol}.E;
            S = allMolecules{currentMol}.S;     
            t = (1:length(AA))';
            select = zeros(size(AA));
            select(max(minFrame, 1):min(maxFrame, length(AA))) = true;
            select = select & (AA > minAA & AA < maxAA & DD > minDD & DD < maxDD & DA > minDA & DA < maxDA);
            histData = [histData; t(select) E(select)];
            tSelect = t(select);
            if (~isempty(tSelect))
                maxT = max(maxT, tSelect(end));   
            end
        else
            if (allMolecules{currentMol}.include)
                AA = allMolecules{currentMol}.AA;
                DD = allMolecules{currentMol}.DD;
                DA = allMolecules{currentMol}.DA;
                E = allMolecules{currentMol}.E;
                S = allMolecules{currentMol}.S;  
                t = (1:length(AA))';                   
                select = zeros(size(AA));
                select(max(max(minFrame, 1),allMolecules{currentMol}.min):min(min(maxFrame, length(AA)),allMolecules{currentMol}.max)) = true;
                select = select & (AA > minAA & AA < maxAA & DD > minDD & DD < maxDD & DA > minDA & DA < maxDA);
                if (synced)
                    histData = [histData; (1:length(E(select)))' E(select)];
                    maxT = max(maxT, length(E(select)));                    
                else
                    histData = [histData; t(select) E(select)];   
                    maxT = max(maxT, t(end));                    
                end
            end           
        end
    end
    
    % determine window size
    screensize = get(0, 'screensize');
    winsize = round([min(0.8 * screensize(4), 800), min(0.7 * screensize(4), 700)]);
    winoffset = round(0.5 * (screensize(3:4)-winsize));    
    
    % Plot figure
    numberOfBins = 50;    
    lightRed = [255/255, 87/255, 87/255];
    lightBlue = [87/255, 87/255, 255/255];
    fig = figure('name', 'Histogram time evolution', ...
                         'position', [winoffset(:)' winsize(:)'], ...
                         'color', [0.95 0.95 0.95], ...
                         'numbertitle','off', ...
                         'resize','on',...
                         'DefaultUIControlUnits', 'normalized');
                                  
    FRETbins = linspace(0,1,numberOfBins + 1);
    timeBins = 1:maxT;
    subplot(1,5,5);
    counts = histc(histData(:,2), FRETbins);
    barh(FRETbins,counts, 'histc'); 
    ylim([0 (FRETbins(end) + FRETbins(2) - FRETbins(1))]);
    set(get(gca,'child'), 'FaceColor', lightBlue);
    set(gca,'xtick',[]);
    set(gca,'YAxisLocation', 'right');    
    
    subplot(1,5,1:4);    
    n = hist3(histData,'Edges', {timeBins,FRETbins});
    n1 = n';
    % E on x-axis, S on y-axis
    n1(size(n1,1) + 1, size(n1,2) + 1) = 0;    
    xb = linspace(1,maxT,size(n,1)+1);
    yb = linspace(0,1,size(n,2)+1);
    h = pcolor(xb,yb,n1);    
    set(h,'edgecolor','none')
    xlabel('Time (frames)');
    ylabel('FRET Efficiency');
    %col = load('colormap');
    %colormap(ax2D, col.mycmap);     
end