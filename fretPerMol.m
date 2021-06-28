% Jacob Bakermans, February 2016
% Create plot of FRET per molecule over time.
function fretPerMol(allMolecules)   
    % Create filter dialog
    filterParams = timeHistogramDialog();
    
    % User pressed cancel
    if any([filterParams{:}] == -1)
        return
    end
    
    % Create threshold dialog
    thresholdParams = fretPerMolDialog();
    
    % User pressed cancel
    if any([thresholdParams{:}] == -1)
        return
    end    
    
    % Extract values from filter dialog
    if (filterParams{1} == 1)
        includeAll = true;
    else
        includeAll = false;
        if (filterParams{1} == 2)
            synced = false;
        else
            synced = true;
        end
    end
    if (isnan(filterParams{2}))
        minAA = -Inf;
    else
        minAA = filterParams{2};
    end
    if (isnan(filterParams{3}))
        maxAA = Inf;
    else
        maxAA = filterParams{3};
    end    
    if (isnan(filterParams{4}))
        minDD = -Inf;
    else
        minDD = filterParams{4};
    end
    if (isnan(filterParams{5}))
        maxDD = Inf;
    else
        maxDD = filterParams{5};
    end    
    if (isnan(filterParams{6}))
        minDA = -Inf;
    else
        minDA = filterParams{6};
    end
    if (isnan(filterParams{7}))
        maxDA = Inf;
    else
        maxDA = filterParams{7};
    end         
    if (isnan(filterParams{8}))
        minFrame = 1;
    else
        minFrame = filterParams{8};
    end
    if (isnan(filterParams{9}))
        maxFrame = Inf;
    else
        maxFrame = filterParams{9};
    end     
    
    % Extract values from threshold dialog
    thresholds = [];  
    if (~isnan(thresholdParams{1}))
        thresholds = [thresholds min(1,max(0,thresholdParams{1}))];
    end    
    if (~isnan(thresholdParams{2}))
        thresholds = [thresholds min(1,max(0,thresholdParams{2}))];
    end  
    if (~isnan(thresholdParams{3}))
        thresholds = [thresholds min(1,max(0,thresholdParams{3}))];
    end  
    if (~isnan(thresholdParams{4}))
        thresholds = [thresholds min(1,max(0,thresholdParams{4}))];
    end  
    thresholds = [0 thresholds];    
    thresholds = sort(unique(thresholds));
    if (isnan(thresholdParams{5}))
        avgFrames = 1;        
    else
        avgFrames = round(thresholdParams{5});
    end      
    
    % Generate histogram data
    molFRET = cell(length(allMolecules),1);
    maxT = 0;
    for (currentMol = 1:length(allMolecules))
        if (includeAll)
            AA = allMolecules{currentMol}.AA;
            DD = allMolecules{currentMol}.DD;
            DA = allMolecules{currentMol}.DA;
            E = allMolecules{currentMol}.E;
            S = allMolecules{currentMol}.S;     
            t = (1:length(AA))';
            maxT = max(maxT, t(end));
            select = zeros(size(AA));
            select(max(minFrame, 1):min(maxFrame, length(AA))) = true;
            select = select & (AA > minAA & AA < maxAA & DD > minDD & DD < maxDD & DA > minDA & DA < maxDA);
            molFRET{currentMol} = [t(select) E(select)];
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
                    molFRET{currentMol} = [(1:length(E(select)))' E(select)];
                    maxT = max(maxT, length(E(select)));                    
                else
                    molFRET{currentMol} = [t(select) E(select)];   
                    maxT = max(maxT, t(end));                    
                end
            end           
        end
    end
    assignin('base', 'molFRET', molFRET);    
    
    % Find states based on thresholds
    for (currentMol = 1:length(allMolecules))
        if (~isempty(molFRET{currentMol}))
            smoothedFRET = smooth(molFRET{currentMol}(:,2),avgFrames);
            states = zeros(size(smoothedFRET));
            largerThanThreshold = cell(size(thresholds));
            notLargerThanNextThreshold = cell(size(thresholds));   
            for (i = 1:length(thresholds))
                largerThanThreshold{i} = smoothedFRET > thresholds(i);
            end
            for (i = 1:length(thresholds))
                notLargerThanNextThreshold{i} = ones(size(largerThanThreshold{i}));
                for (j = (i+1):length(thresholds))
                    notLargerThanNextThreshold{i} = notLargerThanNextThreshold{i} & ~largerThanThreshold{j};
                end
                states(largerThanThreshold{i} & notLargerThanNextThreshold{i}) = i;
            end
            if (currentMol == 2)
                assignin('base','larger', largerThanThreshold);
                assignin('base','notLargerThanNext', notLargerThanNextThreshold);    
            end            
            molFRET{currentMol} = [molFRET{currentMol} smoothedFRET states];
        end
    end        
    assignin('base', 'molFRET', molFRET);   
    
    % Build matrix of states
    includedMols = 0;
    showIncludedOnly = true;
    for (currentMol = 1:length(allMolecules))
        if ~isempty(molFRET{currentMol})
            includedMols = includedMols + 1;
        end
    end
    if (showIncludedOnly)
        allStates = zeros(includedMols,maxT);
        currentMol = 1;
        for (i = 1:length(allMolecules));
            if (~isempty(molFRET{i}))
                allStates(currentMol,molFRET{i}(:,1)) = (molFRET{i}(:,4))';
                currentMol = currentMol + 1;
            end
        end
    else
        allStates = zeros(length(allMolecules),maxT);
        for (currentMol = 1:length(allMolecules));
            if (~isempty(molFRET{currentMol}))
                allStates(currentMol,molFRET{currentMol}(:,1)) = (molFRET{currentMol}(:,4))';
            end
        end
    end
    %assignin('base', 'datamatrix', allStates);
    
    % determine window size
    screensize = get(0, 'screensize');
    winsize = round([min(0.8 * screensize(4), 800), min(0.7 * screensize(4), 700)]);
    winoffset = round(0.5 * (screensize(3:4)-winsize));    
    
    % Plot figure
    numberOfBins = 50;    
    lightRed = [255/255, 87/255, 87/255];
    lightBlue = [87/255, 87/255, 255/255];
    fig = figure('name', 'Signal histograms', ...
                         'position', [winoffset(:)' winsize(:)'], ...
                         'color', [0.95 0.95 0.95], ...
                         'numbertitle','off', ...
                         'resize','on',...
                         'DefaultUIControlUnits', 'normalized');
                                  
    FRETbins = linspace(0,1,numberOfBins + 1);
    h = pcolor(allStates);    
    set(h,'edgecolor','none')
    xlabel('Time (frames)');
    ylabel('Molecule');
    col = [1 1 1; 1 0 0; 0 1 0; 0 0 1; 1 1 0; 1 0 1; 0 1 1];
    colormap(col);
    %col = load('colormap');
    %colormap(ax2D, col.mycmap);     
end