% Jacob Bakermans, January 2016
% Create histograms of (possibly fitered or selected) signal
function createHistograms(allMolecules)   
    % Create dialog
    params = histogramDialog();
    
    % User pressed cancel
    if any([params{:}] == -1)
        return
    end
    
    % Extract values from dialog
    if (params{1} == 1)
        includeAll = true;
    else
        includeAll = false;
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
    for (currentMol = 1:length(allMolecules))
        if (includeAll)
            AA = allMolecules{currentMol}.AA;
            DD = allMolecules{currentMol}.DD;
            DA = allMolecules{currentMol}.DA;
            E = allMolecules{currentMol}.E;
            S = allMolecules{currentMol}.S;            
            select = zeros(size(AA));
            select(max(minFrame, 1):min(maxFrame, length(AA))) = true;
            select = select & (AA > minAA & AA < maxAA & DD > minDD & DD < maxDD & DA > minDA & DA < maxDA);
            histData = [histData; E(select) S(select)];
        else
            if (allMolecules{currentMol}.include)
                AA = allMolecules{currentMol}.AA;
                DD = allMolecules{currentMol}.DD;
                DA = allMolecules{currentMol}.DA;
                E = allMolecules{currentMol}.E;
                S = allMolecules{currentMol}.S;  
                select = zeros(size(AA));
                select(max(max(minFrame, 1),allMolecules{currentMol}.min):min(min(maxFrame, length(AA)),allMolecules{currentMol}.max)) = true;
                select = select & (AA > minAA & AA < maxAA & DD > minDD & DD < maxDD & DA > minDA & DA < maxDA);
                histData = [histData; E(select) S(select)];                 
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
    fig = figure('name', 'Signal histograms', ...
                         'position', [winoffset(:)' winsize(:)'], ...
                         'color', [0.95 0.95 0.95], ...
                         'menubar', 'none', ... 
                         'numbertitle','off', ...
                         'resize','on',...
                         'DefaultUIControlUnits', 'normalized');
    controlAxes = subplot(5,5,5);
    set(controlAxes, 'visible', 'off');
    controlAxesPos = get(controlAxes, 'Position');
    uicontrol(fig, ...
                'style', 'pushbutton', ...
                'string', 'Save data', ...
                'TooltipString', 'Save histogram data for further analysis in other software.',...                      
                'callback', @saveClick,...                       
                'position', [controlAxesPos(1) + 0.01, controlAxesPos(2) + controlAxesPos(4)/2 + 0.01, controlAxesPos(3) + 0.02, 0.04]);
    uicontrol(fig, ...
                    'style', 'popup', ...
                    'string', 'Fit histogram...|1 Gaussian|2 Gaussians|3 Gaussians|4 Gaussians', ...             
                    'callback', @fitPopupClick,...                    
                    'position', [controlAxesPos(1) + 0.01, controlAxesPos(2) + controlAxesPos(4)/2 - 0.05, controlAxesPos(3) + 0.02, 0.04]);             
                     
    axesFRET = subplot(5,5,1:4);
    binspace = linspace(0,1,numberOfBins + 1);
    counts = histc(histData(:,1), binspace);
    xFRET = binspace;
    yFRET = counts;
    bar(binspace,counts, 'histc');     
    xlim([0 (binspace(end) + binspace(2) - binspace(1))]);
    set(get(gca,'child'), 'FaceColor', lightRed);
    set(gca,'xtick',[]) 
    
    subplot(5,5,[10 15 20 25]);
    counts = histc(histData(:,2), binspace);
    barh(binspace,counts, 'histc'); 
    ylim([0 (binspace(end) + binspace(2) - binspace(1))]);
    set(get(gca,'child'), 'FaceColor', lightBlue);
    set(gca,'ytick',[]);
    
    ax2D = subplot(5,5, [6:9 11:14 16:19 21:24]);
    n = hist3(histData,'Edges', {binspace,binspace});
    n1 = n';
    n1(size(n,1) + 1, size(n,2) + 1) = 0;
    % E on x-axis, S on y-axis
    xb = linspace(0,1,size(n,1)+1);
    yb = linspace(0,1,size(n,1)+1);
    h = pcolor(xb,yb,n1);       
    set(h,'edgecolor','none')
    xlabel('Efficiency');
    ylabel('Stoichiometry');
    col = load('colormap');
    colormap(ax2D, col.mycmap);
    
    function fitPopupClick(source,callbackdata)
        % Evaluate user input
        choice = get(source, 'value');
        x = xFRET';
        y = yFRET;
        % Fit gaussians to bins (quick 'n dirty solution. Better would be
        % to fit the distribution instead of the histogram.)
        switch choice
            case 2
                % Fit one gaussian, output results
                f = fit(x,y,'gauss1');
                plotGaussians(axesFRET, f, 1);                
            case 3
                f = fit(x,y,'gauss2');
                plotGaussians(axesFRET, f, 2);                                
            case 4
                f = fit(x,y,'gauss3');
                plotGaussians(axesFRET, f, 3);                                
            case 5
                f = fit(x,y,'gauss4');
                plotGaussians(axesFRET, f, 4);                                                
        end
        set(source, 'value', 1);        
    end   
    
    function plotGaussians(plotAxes, fitObject, numberOfGaussians)
        % Use beautiful ebFRET colors
        colorsEbFRET = [0.00, 0.66, 0.66
               0.00, 0.33, 0.66
               0.33, 0.00, 0.66
               0.75, 0.50, 0.00
               0.33, 0.66, 0.00
                0.66, 0.00, 0.00];             
        
        % Initiate list of individual parameters of each gaussian
        legendData = cell(numberOfGaussians, 1);
        colors = cell(numberOfGaussians, 1);
        fitData = cell(numberOfGaussians, 1);
        fitCoefficients = coeffvalues(fitObject);
        totalArea = 0;
        
        % Extract coefficients of each Gaussian seperately
        for (i = 1:numberOfGaussians)            
            fitData{i} = struct();
            fitData{i}.a = fitCoefficients((i - 1)*3 + 1);
            fitData{i}.b = fitCoefficients((i - 1)*3 + 2);
            fitData{i}.c = fitCoefficients((i - 1)*3 + 3);
            fitData{i}.area = sqrt(2 * pi) * fitData{i}.a * fitData{i}.c;
            totalArea = totalArea + fitData{i}.area;
        end
        
        % Update area and legend text
        for (i = 1:numberOfGaussians)
            fitData{i}.area = fitData{i}.area / totalArea;
            legendData{i} = ['Gaussian ' num2str(i) '. Center: ' num2str(fitData{i}.b) ', Area: ' num2str(fitData{i}.area)];
        end
        
        % determine window size
        fitWinsize = round([min(0.6 * screensize(4), 600), min(0.525 * screensize(4), 525)]);
        fitWinoffset = round(0.5 * (screensize(3:4)-fitWinsize));           
        
        % Note: histogram y-values correspond to x-value of left side of
        % histogram bar. As a consequence, the fit seems shifted to the
        % left, since it fits the left edge of each bar. In the original
        % plot, we can't shift the bins, so shift the fit half a bin to the
        % right. In the new figure, shift the bins half a bin to the left.
        % Then the fit always passes through the center of the bars.
        
        % Add some results to the original histogram
        axes(plotAxes);
        x = xFRET';
        yTot = zeros(size(xFRET'));
        hold on;
        for (i = 1:numberOfGaussians)
            y = fitData{i}.a * gaussmf(x, [sqrt(0.5)*fitData{i}.c fitData{i}.b]);
            plot(x + 0.5 * (x(2) - x(1)), y, 'Color', colorsEbFRET(i,:), 'lineWidth', 2);
            yTot = yTot + y;            
        end
        plot(x + 0.5 * (x(2) - x(1)), yTot, 'LineStyle', '-', 'Color', [0 0 0], 'lineWidth', 2); 
        xlim([0 (x(end) + x(2) - x(1))]);        
        hold off;           
        
        % Plot results in separate window
        figure('name', 'Gaussian fits', ...
                         'position', [fitWinoffset(:)' fitWinsize(:)'], ...
                         'color', [0.95 0.95 0.95], ...
                         'numbertitle','off', ...
                         'resize','on',...
                         'DefaultUIControlUnits', 'normalized');

        hold on;
        fitAxes = bar(x - 0.5 * (x(2) - x(1)),yFRET, 'histc');     
        xlim([0 1]);
        set(get(gca,'child'), 'FaceColor', lightRed);   
        set(get(gca,'child'), 'EdgeColor', [1 1 1]);          
        for (i = 1:numberOfGaussians)
            y = fitData{i}.a * gaussmf(x, [sqrt(0.5)*fitData{i}.c fitData{i}.b]);
            plot(x, y, 'Color', colorsEbFRET(i,:), 'lineWidth', 3);
        end
        plot(x, yTot, 'LineStyle', '-', 'Color', [0 0 0], 'lineWidth', 3); 
        hold off;
        legend({'Histogram', legendData{:}});
        
        % Output the fit parameters
        assignin('base', 'FitData', fitData);
    end

    function saveClick(source, callbackdata)       
        [filename, pathname] = uiputfile('*.txt', 'Save histogram data');
        if (isequal(filename,0) || isequal(pathname,0)) % User pressed cancel
            return;
        else
            header = 'E\tS\n'; 
            % Write header to file
            fileID = fopen([pathname filename],'wt');
            fprintf(fileID,header);
            fclose(fileID);
            % Save created output matrix to file
            dlmwrite([pathname filename],histData,'-append','delimiter','\t','newline', 'pc')   
            
            %Save created histograms
            [~,name,~] = fileparts(filename);
            outmatrix = [xFRET' yFRET];
            dlmwrite([pathname name '_E_histogram.txt'], outmatrix,'delimiter','\t','newline', 'pc')              
            
            Scounts = histc(histData(:,2), xFRET);
            outmatrix = [xFRET' Scounts];
            dlmwrite([pathname name '_S_histogram.txt'], outmatrix,'delimiter','\t','newline', 'pc')              
        end             
    end    
end