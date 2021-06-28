% Jacob Bakermans, December 2015
function Nero()
    % Initiate variables
    NeroData = struct;
    NeroData.in = {};
    NeroData.mols = {};
    currentMol = 1;
    axTrace1 = [];
    axTrace2 = [];
    selectedMols = [];
    currentSelectedMol = 1;
    ignoreClick = false; % Workaround for Matlab's focus issues
    patch1 = -1;
    patch2 = -1;

    % Set window parameters
    bg_color = [0.95 0.95 0.95];
    % determine window size
    screensize = get(0, 'screensize');
    winsize = round([min(0.9 * screensize(3), 1200), min(0.7 * screensize(4), 700)]);
    winoffset = round(0.5 * (screensize(3:4)-winsize));
    % Create window
    window = figure('name', 'Nero trace selection', ...
                         'units','pixels', ...
                         'position', [winoffset(:)' winsize(:)'], ...
                         'color', bg_color, ...
                         'menubar', 'none', ... 
                         'numbertitle','off', ...
                         'resize','on');
    set(window, ...
        'DefaultUIPanelBackGroundColor', [0.95 0.95 0.95], ...
        'DefaultUIControlUnits', 'normalized', ...
        'DefaultAxesLooseInset', [0.00, 0, 0, 0], ... 
        'DefaultAxesUnits', 'normalized');
    set(window,'KeyPressFcn',@keyPressFunction,...
        'WindowButtonDownFcn', @mousePressed,...
        'WindowButtonMotionFcn', @setCursor);
   
    % Set ui size parameters
    pos = getpixelposition(window);
    hp = 4 / pos(3);
    vp = 4 / pos(4);
    tracePanelWidth = 0.8;
    tracePanelHeight = 0.9;
    imagePanelWidth = 1 - tracePanelWidth;
    imagePanelHeight = tracePanelHeight;
    controlPanelWidth = 1;
    controlPanelHeight = 1 - tracePanelHeight;    
    
    % Create panels
    tracePanel ...
        = uipanel(window, ...
                  'position', [hp, controlPanelHeight, tracePanelWidth - 2*hp, tracePanelHeight - vp], ...
                  'title', 'Traces');
    imagePanel ...
        = uipanel(window, ...
                  'position', [tracePanelWidth, controlPanelHeight, imagePanelWidth - hp, imagePanelHeight - vp], ...
                  'title', 'Images');
    controlPanel ...
        = uipanel(window, ...
                  'position', [hp, vp, controlPanelWidth - 2*hp, controlPanelHeight - 2*vp], ...
                  'title', 'Control');         
              
    %Create full crosshair lines
    crossHair = createCrossHair(window);
              
    % Calculate user input size
    buttonWidth = imagePanelWidth / 4; % Padding included
    buttonHeight = 0.4; % Padding included    
    buttonY = (1 - buttonHeight) * 0.3;
    textHeight = (1 - buttonHeight - buttonY);
    textY = buttonY + buttonHeight;
    molSliderPosition = [hp buttonY (1-imagePanelWidth - buttonWidth * 5 - 2*hp) buttonHeight-vp];
    molSliderLabelPosition = [molSliderPosition(1) textY molSliderPosition(3) textHeight-vp];
    molEditPosition = [(molSliderPosition(1) + molSliderPosition(3) + hp) buttonY buttonWidth-hp buttonHeight-vp];
    molEditLabelPosition = [molEditPosition(1) textY molEditPosition(3) textHeight-vp];
    includePosition = [(molEditPosition(1) + molEditPosition(3) + hp + buttonWidth * 0.4) buttonY (buttonWidth * 0.6 - hp) buttonHeight-vp];
    includeLabelPosition = [(molEditPosition(1) + molEditPosition(3) + hp) textY buttonWidth - hp textHeight-vp];
    minEditPosition = [(includePosition(1) + includePosition(3) + hp) buttonY buttonWidth-hp buttonHeight-vp];
    minEditLabelPosition = [minEditPosition(1) textY minEditPosition(3) textHeight-vp];    
    maxEditPosition = [(minEditPosition(1) + minEditPosition(3) + hp) buttonY buttonWidth-hp buttonHeight-vp];
    maxEditLabelPosition = [maxEditPosition(1) textY maxEditPosition(3) textHeight-vp]; 
    showPosition = [(maxEditPosition(1) + maxEditPosition(3) + hp) buttonY buttonWidth-hp buttonHeight-vp];
    showLabelPosition = [showPosition(1) textY showPosition(3) textHeight-vp]; 

    dataPosition = [tracePanelWidth+hp buttonY buttonWidth*2-2*hp buttonHeight-vp];
    dataLabelPosition = [dataPosition(1) textY dataPosition(3) textHeight-vp];
    filePosition = [(dataPosition(1) + dataPosition(3) + hp) buttonY+4*vp buttonWidth*2-hp buttonHeight-vp];
    fileLabelPosition = [filePosition(1) textY filePosition(3) textHeight-vp];
    
    importPosition = [tracePanelWidth+hp buttonY buttonWidth-2*hp buttonHeight+textHeight];
    exportPosition = [(importPosition(1) + importPosition(3) + hp) buttonY buttonWidth-hp buttonHeight+textHeight];  
    savePosition = [(exportPosition(1) + exportPosition(3) + hp) buttonY buttonWidth-hp buttonHeight+textHeight];      
    loadPosition = [(savePosition(1) + savePosition(3) + hp) buttonY buttonWidth-hp buttonHeight+textHeight];         
    
    % Create user inputs    
    molSlider ...
        = uicontrol(controlPanel, ...
                    'Style', 'slider',...
                    'Min',1,'Max',2,'Value',1,...
                    'SliderStep', [1/1 , 10/1], ...
                    'enable', 'off',...
                    'callback', @molSliderClick,...                  
                    'position', molSliderPosition);      
    molSliderLabel ...
        = uicontrol(controlPanel, ...
                    'style', 'text', ...
                    'string', '[Left/right arrow] to scroll. [Up/down arrow] to clip, or [Left mouse click] in trace. [Right mouse click] to reset. [Space] to include.', ...
                    'backgroundcolor', bg_color, ...
                    'position', molSliderLabelPosition);
    molEdit ...
        = uicontrol(controlPanel, ...
                    'style', 'edit', ...
                    'string', '1', ...
                    'enable', 'off',...                    
                    'callback', @molEditClick,...                  
                    'backGroundColor', [1 1 1], ...
                    'position', molEditPosition); 
    molEditLabel ...
        = uicontrol(controlPanel, ...
                    'style', 'text', ...
                    'string', 'Molecule', ...
                    'backgroundcolor', bg_color, ...
                    'position', molEditLabelPosition); 
    include ...
        = uicontrol(controlPanel, ...
                    'style', 'checkbox', ...
                    'value', 0, ...                    
                    'enable', 'off', ...
                    'callback', @includeClick, ...
                    'position', includePosition);       
    includeLabel ...
        = uicontrol(controlPanel, ...
                    'style', 'text', ...
                    'string', 'Include?', ...
                    'backgroundcolor', bg_color, ...
                    'position', includeLabelPosition);        
    minEdit ...
        = uicontrol(controlPanel, ...
                    'style', 'edit', ...
                    'string', '1', ...
                    'enable', 'off',...                    
                    'callback', @minEditClick,... 
                    'KeyPressFcn', @minEditKey,...                    
                    'position', minEditPosition); 
    minEditLabel ...
        = uicontrol(controlPanel, ...
                    'style', 'text', ...
                    'string', 'Min', ...
                    'backgroundcolor', bg_color, ...
                    'position', minEditLabelPosition);  
    maxEdit ...
        = uicontrol(controlPanel, ...
                    'style', 'edit', ...
                    'string', '1', ...
                    'enable', 'off',...                    
                    'callback', @maxEditClick,...  
                    'KeyPressFcn', @maxEditKey,...                      
                    'position', maxEditPosition); 
    showPopupLabel ...
        = uicontrol(controlPanel, ...
                    'style', 'text', ...
                    'string', 'Show', ...
                    'backgroundcolor', bg_color, ...
                    'position', showLabelPosition);  
    showPopup ...
        = uicontrol(controlPanel, ...
                    'style', 'popup', ...
                    'string', 'All|Selected', ...
                    'enable', 'off',...                    
                    'callback', @showPopupClick,...                    
                    'position', showPosition);                   
    maxEditLabel ...
        = uicontrol(controlPanel, ...
                    'style', 'text', ...
                    'string', 'Max', ...
                    'backgroundcolor', bg_color, ...
                    'position', maxEditLabelPosition);                                 
    dataPopupLabel ...
        = uicontrol(controlPanel, ...
                    'style', 'text', ...
                    'string', 'Data', ...
                    'backgroundcolor', bg_color, ...
                    'position', dataLabelPosition);  
    dataPopup ...
        = uicontrol(controlPanel, ...
                    'style', 'popup', ...
                    'string', 'Select option...|Create histograms|Time evolution|FRET per mol|Export current trace|Sum traces', ...
                    'enable', 'off',...                    
                    'callback', @dataPopupClick,...                    
                    'position', dataPosition);                
    filePopupLabel ...
        = uicontrol(controlPanel, ...
                    'style', 'text', ...
                    'string', 'File', ...
                    'backgroundcolor', bg_color, ...
                    'position', fileLabelPosition);  
    filePopup ...
        = uicontrol(controlPanel, ...
                    'style', 'popup', ...
                    'string', 'Select option...|Import TwoTone file|Export ebFRET file|Load Nero session|Save Nero Session', ...
                    'enable', 'on',...                    
                    'callback', @filePopupClick,...                    
                    'position', filePosition);                            
                
    function updateSelectedMols()
        selectedMols = [];
        for (i = 1:length(NeroData.mols))
            if (NeroData.mols{i}.include)
                selectedMols = [selectedMols i];
            end
        end
    end                
                
    function updateCrossHair(fig, crossHair)
        % Use get function instead of dot notation
        getCurrentPoint = get(fig, 'CurrentPoint');
        getUnits = get(fig, 'Units');
        getPosition = get(fig, 'Position');
        getParent = get(fig, 'Parent');
        
        gap = 1; % 3 pixel view port between the crosshairs        
        cp = hgconvertunits(fig, [getCurrentPoint 0 0], getUnits, 'pixels', fig);
        cp = cp(1:2);
        figPos = hgconvertunits(fig, getPosition, getUnits, 'pixels', getParent);
        figWidth = figPos(3);
        figHeight = figPos(4);

        % Early return if point is outside the figure
        if cp(1) < gap || cp(2) < gap || cp(1)>figWidth-gap || cp(2)>figHeight-gap
            return
        end

        set(crossHair, 'Visible', 'on');
        thickness = 1; % 1 Pixel thin lines. 
        set(crossHair(1), 'Position', [cp(1) 0 thickness cp(2)-gap]);
        set(crossHair(2), 'Position', [cp(1) cp(2)+gap thickness figHeight-cp(2)-gap]);
    end

    function crossHair = createCrossHair(fig)
        % Create thin uicontrols with black backgrounds to simulate fullcrosshair pointer.
        % 1: horizontal left, 2: horizontal right, 3: vertical bottom, 4: vertical top
        for k = 1:2
            crossHair(k) = uicontrol(fig, 'Style', 'text',...
                                     'Visible', 'off',...
                                     'Units', 'pixels',...
                                     'BackgroundColor', [0 0 0],...
                                     'HandleVisibility', 'off',...
                                     'HitTest', 'off'); %#ok<AGROW>
        end
    end

    function filePopupClick(source,callbackdata)
        choice = get(source, 'value');
        set(source, 'value', 1);           
        switch choice
            case 1
                return;
            case 2
                importClick(source,callbackdata);
                resetFocus(window);             
            case 3
                exportClick(source,callbackdata);
            case 4
                loadClick(source,callbackdata);
                resetFocus(window);                 
            case 5
                saveClick(source,callbackdata);
        end              
    end

    function dataPopupClick(source,callbackdata)
        choice = get(source, 'value');
        switch choice
            case 2
                histogramsClick(source,callbackdata);
            case 3
                timeHistogramsClick(source,callbackdata);
            case 4
                fretPerMolClick(source,callbackdata);                
            case 5
                exportTraceClick(source, callbackdata);
                resetFocus(window);
            case 6
                sumTracesClick(source, callbackdata);
        end       
        set(source, 'value', 1);        
    end

    function showPopupClick(source,callbackdata)
        choice = get(source, 'value');
        switch choice
            case 1
                selected = 1;
                set(molSlider, 'value', selected);        
                set(molEdit, 'string', num2str(selected));
                currentMol = selected;
                % Update include and min/max values for selected mol
                set(minEdit, 'String', num2str(NeroData.mols{currentMol}.min));
                set(maxEdit, 'String', num2str(NeroData.mols{currentMol}.max)); 
                set(include, 'Value', NeroData.mols{currentMol}.include);
                % Plot selected mol
                plotMol(currentMol);
            case 2
                if (isempty(selectedMols))
                    msgbox('There are no molecules selected. Nothing to display.');
                    set(source, 'value', 1);                    
                else                                       
                    selected = selectedMols(1);
                    currentSelectedMol = 1;
                    set(molSlider, 'value', selected);        
                    set(molEdit, 'string', num2str(selected));
                    currentMol = selected;
                    % Update include and min/max values for selected mol
                    set(minEdit, 'String', num2str(NeroData.mols{currentMol}.min));
                    set(maxEdit, 'String', num2str(NeroData.mols{currentMol}.max)); 
                    set(include, 'Value', NeroData.mols{currentMol}.include);
                    % Plot selected mol
                    plotMol(currentMol);
                end
        end
        resetFocus(window);  
    end

    function importClick(source,callbackdata)
        % Ask to keep or replace current molecules
        if (isempty(NeroData.in))
            keep = false;        
        else
            choice = questdlg('Keep or replace current molecules?', ...
                            'Keep or replace?', 'Keep', 'Replace', 'Cancel', 'Keep');    
            switch choice
                case 'Keep'
                    keep = true;
                case 'Replace'
                    keep = false;
                case 'Cancel'
                    return;
            end
        end
        
        % Ask if ALEX FRET, CW FRET or single green channel experiment

        choice2 = questdlg('FRET', ...
            'FRET?', 'no', 'yes', 'Cancel', 'Cancel');
        switch choice2
            case 'no'
                FRET = false;
                ALEX = false;
            case 'yes'
                FRET = true;
            case 'Cancel'
                return;
        end
        
        if FRET
            choice3 = questdlg('ALEX',...
                'ALEX?', 'no', 'yes', 'Cancel', 'Cancel');
            switch choice3
                case 'no'
                    ALEX = false;
                case 'yes'
                    ALEX = true;
                case 'Cancel'
                    return;
            end
        end

        
        % Show file loading dialog
        [filename, pathname, filetype] = uigetfile({'*.fitResult.mat','(Preferred) TwoTone output files (*.fitResult.mat)'; '*.v2.mat', 'TwoTone v2 output files (*.v2.mat)'},'Choose TwoTone file', 'MultiSelect', 'on');

        % User pressed cancel
        if (isequal(filename, 0))
            return;
        end
        
        % Convert filename to cell array
        filename = cellstr(filename); 
        % Take first filename as a caption for the window
        set(window, 'Name', [filename{1} ' - Nero trace selection']);
        
        % Set [mols] and [in] according to keep
        if (~keep) % Don't want to keep current molecules
            NeroData.in = {}; % Empty input data
            NeroData.mols = {}; % Empty plot data
            currentMol = 1; % Reset currently shown molecule
        end
        
        % Load data into input data
        if (filetype == 1)
            NeroData.in = loadData(NeroData.in, filename, pathname);
        elseif (filetype == 2)
            NeroData.in = loadDataV2(NeroData.in, filename, pathname);
        end
        % Extract plot data from input data
        if FRET & ALEX
            NeroData.mols = loadMols(NeroData.in, NeroData.mols);
        elseif (~FRET)
            NeroData.mols = loadMolsSingleIntensity(NeroData.in, NeroData.mols);
        elseif FRET & (~ALEX)
            NeroData.mols = loadMolsCWFRET(NeroData.in, NeroData.mols);
        end
        % Clear input data to free space
        %NeroData.in = clearData(NeroData.in);
        % Show results
        assignin('base', 'NeroData', NeroData);
        
        % Now data is loaded, we dan start plotting
        if (~isempty(NeroData.mols))
            set(molSlider, 'enable', 'on');
            set(molEdit, 'enable', 'on');
            set(include, 'enable', 'on');
            set(minEdit, 'enable', 'on');
            set(maxEdit, 'enable', 'on');
            set(dataPopup, 'enable', 'on');
            set(showPopup, 'enable', 'on');                 
            set(molEdit, 'string', num2str(currentMol));              
            set(molSlider, 'value', currentMol);            
            set(molSlider, 'max', length(NeroData.mols));
            set(molSlider, 'sliderstep', [1/length(NeroData.mols) , 5/length(NeroData.mols)]);
        end

        % Update include and min/max values for selected mol
        set(minEdit, 'String', num2str(NeroData.mols{currentMol}.min));
        set(maxEdit, 'String', num2str(NeroData.mols{currentMol}.max)); 
        set(include, 'Value', NeroData.mols{currentMol}.include);
        % Plot selected mol
        plotMol(currentMol);     
    end  

    function exportClick(source, callbackdata)
        if (isempty(NeroData.mols))
            msgbox('You need to load TwoTone traces before you can export ebFRET data');
            return;
        end    
        [filename, pathname] = uiputfile('*.dat', 'Export ebFRET data');
        if (isequal(filename,0) || isequal(pathname,0))
            return;
        else
            saveData(NeroData.mols, filename, pathname);
        end     
        resetFocus(window);         
    end

    function saveClick(source, callbackdata)
        if (isempty(NeroData.mols))
            msgbox('There is nothing to save...');
            return;
        end    
        [filename, pathname] = uiputfile('*.mat', 'Save current session');
        if (isequal(filename,0) || isequal(pathname,0)) % User pressed cancel
            return;
        else
            % Export data to workspace
            assignin('base', 'NeroData', NeroData);
            % Export data to mat file
            save([pathname filename], 'NeroData');
        end    
        resetFocus(window);         
    end

    function loadClick(source,callbackdata)
        % Confirm loading a previous session
        if (~isempty(NeroData.in))
            choice = questdlg('Load a previous session? Current session will be lost.', ...
                            'Load?', 'Load', 'Cancel', 'Load');    
            if (isequal(choice, 'Cancel'))
                return;
            end
        end        
        
        % Show file loading dialog
        [filename, pathname] = uigetfile({'*.mat','Nero session (*.mat)'},'Choose session file');

        % User pressed cancel
        if (isequal(filename, 0) || isequal(pathname,0))
            return;
        end
        
        % Set window caption to filename
        set(window, 'Name', [filename ' - Nero trace selection']);
        
        % Load mat file into workspace
        newDat = load([pathname filename]);
        %assignin('base', 'newDat', newDat);    
        % Check if mat file is Nero session        
        if (isfield(newDat, 'NeroData'))
            NeroData = newDat.NeroData;
            currentMol = 1;
        else
            return;
        end

        % Show results
        assignin('base', 'NeroData', NeroData);
        
        % Now data is loaded, we dan start plotting
        if (~isempty(NeroData.mols))
            set(molSlider, 'enable', 'on');
            set(molEdit, 'enable', 'on');
            set(include, 'enable', 'on');
            set(minEdit, 'enable', 'on');
            set(maxEdit, 'enable', 'on');
            set(dataPopup, 'enable', 'on');
            set(showPopup, 'enable', 'on');            
            set(molEdit, 'string', num2str(currentMol));              
            set(molSlider, 'value', currentMol);            
            set(molSlider, 'max', length(NeroData.mols));
            set(molSlider, 'sliderstep', [1/length(NeroData.mols) , 5/length(NeroData.mols)]);
        end

        % Update include and min/max values for selected mol
        set(minEdit, 'String', num2str(NeroData.mols{currentMol}.min));
        set(maxEdit, 'String', num2str(NeroData.mols{currentMol}.max)); 
        set(include, 'Value', NeroData.mols{currentMol}.include);
        % Plot selected mol
        plotMol(currentMol);              
    end   

    function histogramsClick(source, callbackdata)
        if (isempty(NeroData.mols))
            msgbox('You need to load TwoTone traces before you can create signal histograms');
            return;
        end                  
        % Run histogram function
        createHistograms(NeroData.mols);        
    end

    function timeHistogramsClick(source, callbackdata)
        if (isempty(NeroData.mols))
            msgbox('You need to load TwoTone traces before you can create signal histograms');
            return;
        end                  
        % Run histogram function
        createTimeHistograms(NeroData.mols);        
    end

    function sumTracesClick(source, callbackdata)
        if (isempty(NeroData.mols))
            msgbox('You need to load TwoTone traces before you can create signal histograms');
            return;
        end                  
        % Run histogram function
        createSumTraces(NeroData.mols);        
    end

    function fretPerMolClick(~, callbackdata)
        if (isempty(NeroData.mols))
            msgbox('You need to load TwoTone traces before you can create signal histograms');
            return;
        end                  
        % Run histogram function
        fretPerMol(NeroData.mols);        
    end

    function exportTraceClick(source, callbackdata)
        exportTrace(NeroData.mols, currentMol);
    end

    function mousePressed(source,callbackdata)      
        if (ignoreClick)
            ignoreClick = false;
            return;
        end
        mouseButton = get(window, 'SelectionType'); % left mb: 'normal', right mb: 'alt', double click: 'open'
        if (~isempty(NeroData.mols) && (gca == axTrace1 || gca == axTrace2))
            if (isequal(mouseButton, 'normal')) % Left button: select
                mousePressedX = get(gca,'currentpoint');
                mousePressedX = mousePressedX(1,1);
                [mouseReleasedX, mouseReleasedY] = myGinput(1);
                set(crossHair, 'Visible', 'off');   
                minVal = min(round(mousePressedX), round(mouseReleasedX));
                maxVal = max(round(mousePressedX), round(mouseReleasedX));
                if (abs(mouseReleasedX - mousePressedX) > 5)            
                    % Set min and max
                    NeroData.mols{currentMol}.min = max(1, minVal);       
                    NeroData.mols{currentMol}.max = min(length(NeroData.mols{currentMol}.DD), maxVal);        
                    % If you clip, you probably want to keep it
                    NeroData.mols{currentMol}.include = true;
                    % Update UI
                    set(minEdit,'string', num2str(NeroData.mols{currentMol}.min));
                    set(maxEdit,'string', num2str(NeroData.mols{currentMol}.max));
                    set(include,'value', true);
                    plotMol(currentMol);  
                end
            elseif (isequal(mouseButton, 'alt')) % Right button: reset
                minVal = 1;
                maxVal = length(NeroData.mols{currentMol}.DD);                
                % Set min and max
                NeroData.mols{currentMol}.min = minVal;       
                NeroData.mols{currentMol}.max = maxVal;        
                % If you undo, you probably don't want to keep it
                NeroData.mols{currentMol}.include = false;
                % Update UI
                set(minEdit,'string', num2str(minVal));
                set(maxEdit,'string', num2str(maxVal));
                set(include,'value', false);
                % Plot clipped mol
                plotMol(currentMol);                  
            end
        end
    end
    
    function setCursor(source, callbackdata)
        if (~isempty(NeroData.mols))
            C1 = get(axTrace1,'currentpoint');
            xlim1 = get(axTrace1,'xlim');
            ylim1 = get(axTrace1,'ylim');
            outX1 = ~any(diff([xlim1(1) C1(1,1) xlim1(2)])<0);
            outY1 = ~any(diff([ylim1(1) C1(1,2) ylim1(2)])<0);
            
            C2 = get(axTrace2,'currentpoint');
            xlim2 = get(axTrace2,'xlim');
            ylim2 = get(axTrace2,'ylim');
            outX2 = ~any(diff([xlim2(1) C2(1,1) xlim2(2)])<0);
            outY2 = ~any(diff([ylim2(1) C2(1,2) ylim2(2)])<0);            
                        
            if ((outX1 && outY1) || (outX2 && outY2))
                updateCrossHair(window, crossHair);  
            else
                set(crossHair, 'Visible', 'off');                  
            end 
        end
    end

    function plotMol(molecule)        
        % Load trace data (have to do it before plotting - Matlab bug?)
        DD = NeroData.mols{molecule}.DD;
        DA = NeroData.mols{molecule}.DA;
        AA = NeroData.mols{molecule}.AA;
        E = NeroData.mols{molecule}.E;
        S = NeroData.mols{molecule}.S;
        X = 1:length(DD);
        lims = [NeroData.mols{molecule}.min NeroData.mols{molecule}.max];               
               
        % Plot trace figues
        axTrace1 = subplot(2,1,1, 'Parent', tracePanel);     
        hold on;
        plot(X, AA, 'k', 'DisplayName', 'AA');        
        plot(X, DD, 'g', 'DisplayName', 'DD');
        plot(X, DA, 'r', 'DisplayName', 'DA');
        hold off;   
        legend('show', 'location', 'northeast');
        xlim(lims);
        figpos = get(gca, 'Position');        
        set(gca, 'Position', [figpos(1) - 0.08 figpos(2) - 0.05 figpos(3) + 0.15 figpos(4) + 0.1]);
        axTrace2 = subplot(2,1,2, 'Parent', tracePanel);       
        hold on;
        plot(X, S, 'k', 'DisplayName', 'Stoichiometry');
        plot(X, E, 'r', 'DisplayName', 'Efficiency');         
        hold off;
        xlim(lims);
        legend('show', 'location', 'northeast');        
        figpos = get(gca, 'Position');        
        set(gca, 'Position', [figpos(1) - 0.08 figpos(2) - 0.05 figpos(3) + 0.15 figpos(4) + 0.1]);        
        
        % Load image data
        file = NeroData.mols{molecule}.file;
        particleBorder = 6;
        imgDD = NeroData.in{file}.images{1};
        imgAA = NeroData.in{file}.images{2};
        imgDA = NeroData.in{file}.images{3};
        posDD = ceil(NeroData.mols{molecule}.posDD);
        posAA = ceil(NeroData.mols{molecule}.posAA);
        posDA = ceil(NeroData.mols{molecule}.posDA);        
        % Cut out the particle
        molDD = double(imgDD(max(posDD(2)-particleBorder,1):min(posDD(2)+particleBorder,size(imgDD,1)),...
                        max(posDD(1)-particleBorder,1):min(posDD(1)+particleBorder,size(imgDD,2))));
        molAA = double(imgAA(max(posAA(2)-particleBorder,1):min(posAA(2)+particleBorder,size(imgAA,1)),...
                        max(posAA(1)-particleBorder,1):min(posAA(1)+particleBorder,size(imgAA,2))));
        molDA = double(imgDA(max(posDA(2)-particleBorder,1):min(posDA(2)+particleBorder,size(imgDA,1)),...
                        max(posDA(1)-particleBorder,1):min(posDD(1)+particleBorder,size(imgDA,2)))); 

        % Plot particle images
        subplot(3,1,1, 'Parent', imagePanel);
        subimage(molDD, [min(min(molDD)) max(max(molDD))]);
        axis off;
        figpos = get(gca, 'Position');        
        set(gca, 'Position', [figpos(1) - 0.05 figpos(2) - 0.05 figpos(3) + 0.05 figpos(4) + 0.05]);      
        subplot(3,1,2, 'Parent', imagePanel);
        subimage(molAA, [min(min(molAA)) max(max(molAA))]);
        axis off;        
        figpos = get(gca, 'Position');        
        set(gca, 'Position', [figpos(1) - 0.05 figpos(2) - 0.05 figpos(3) + 0.05 figpos(4) + 0.05]);         
        subplot(3,1,3, 'Parent', imagePanel);
        subimage(molDA, [min(min(molDA)) max(max(molDA))]);
        axis off;        
        figpos = get(gca, 'Position');        
        set(gca, 'Position', [figpos(1) - 0.05 figpos(2) - 0.05 figpos(3) + 0.05 figpos(4) + 0.05]);             
        
        % Not really part of plotting, but do this here to be sure we
        % update often enough:
        updateSelectedMols();        
    end

    function includeClick(source,callbackdata)
        val = get(source,'Value');
        NeroData.mols{currentMol}.include = val;     
    end    

    function molEditClick(source,callbackdata)
        val = get(source,'String');   
        selected = max(1,min(round(str2double(val)),get(molSlider, 'max')));
        set(molSlider, 'value', selected);
        set(molEdit, 'string', num2str(selected));
        currentMol = selected;
        % Update include and min/max values for selected mol
        set(minEdit, 'String', num2str(NeroData.mols{currentMol}.min));
        set(maxEdit, 'String', num2str(NeroData.mols{currentMol}.max)); 
        set(include, 'Value', NeroData.mols{currentMol}.include);
        % Plot selected mol
        plotMol(currentMol);
    end 

    function minEditClick(source,callbackdata)
        val = get(source,'String');   
        minVal = round(str2double(val));
        NeroData.mols{currentMol}.min = min(max(1, minVal), NeroData.mols{currentMol}.max-1);        
        plotMol(currentMol);
    end 

    function maxEditClick(source,callbackdata)
        val = get(source,'String');   
        maxVal = round(str2double(val));
        NeroData.mols{currentMol}.max = max(NeroData.mols{currentMol}.min+1,min(length(NeroData.mols{currentMol}.DD), maxVal));        
        plotMol(currentMol);
    end 

    function molSliderClick(source,callbackdata)
        val = get(source,'value');
        selected = round(val);
        if (get(showPopup, 'value') == 2)
            if (selected < currentMol)                
                % In this case, move to first selected molecule on the left
                newCurrentSelectedMol = find(selectedMols < currentMol, 1, 'last');
                if ~isempty(newCurrentSelectedMol)
                    currentSelectedMol = newCurrentSelectedMol;                     
                end
            else
                % In this case, move to first selected molecule on the right                
                newCurrentSelectedMol = find(selectedMols > currentMol, 1, 'first');
                if ~isempty(newCurrentSelectedMol)
                    currentSelectedMol = newCurrentSelectedMol;
                end
            end
            selected = selectedMols(currentSelectedMol);
        end
        set(molSlider, 'value', selected);        
        set(molEdit, 'string', num2str(selected));
        currentMol = selected;
        % Update include and min/max values for selected mol
        set(minEdit, 'String', num2str(NeroData.mols{currentMol}.min));
        set(maxEdit, 'String', num2str(NeroData.mols{currentMol}.max)); 
        set(include, 'Value', NeroData.mols{currentMol}.include);
        % Plot selected mol
        plotMol(currentMol);
    end  

    function minEditKey(~,Event)
        if (~isempty(NeroData.mols))
            switch Event.Key
                case 'uparrow'
                    % Set focus to maxEdit
                    uicontrol(maxEdit); 
                case 'downarrow'
                    % Set focus to main window (only works if all ui is enabled)                    
                    set(findobj(window, 'Type', 'uicontrol'), 'Enable', 'off');
                    drawnow;
                    set(findobj(window, 'Type', 'uicontrol'), 'Enable', 'on');
            end
        end
    end

    function maxEditKey(~,Event)
        if (~isempty(NeroData.mols))
            switch Event.Key
                case 'uparrow'
                    % Set focus to main window (only works if all ui is enabled)
                    set(findobj(window, 'Type', 'uicontrol'), 'Enable', 'off');
                    drawnow;
                    set(findobj(window, 'Type', 'uicontrol'), 'Enable', 'on');
                case 'downarrow'
                    % Set focus to minEdit
                    uicontrol(minEdit); 
            end
        end
    end

    function resetFocus(fig)
        % Make sure gcf and gco are set correctly
        figure(fig);
        drawnow;
        
        % Get current mouse coordinates
        mouseCurrentPos = get(0,'PointerLocation');
        
        % Simulate mouse click on window
        ignoreClick = true;        
        windowPos = get(fig, 'Position');
        set(0,'PointerLocation', [windowPos(1)+1 windowPos(2)+1]);
        robot = java.awt.Robot;
        robot.mousePress(java.awt.event.InputEvent.BUTTON1_MASK);
        robot.mouseRelease(java.awt.event.InputEvent.BUTTON1_MASK);      
        
        % Place mouse back to old position
        set(0, 'PointerLocation', mouseCurrentPos);        
    end

    function keyPressFunction(~,Event)
        if (~isempty(NeroData.mols))
            switch Event.Key
                case 'leftarrow'
                    if (get(showPopup, 'value') == 2)
                        if (currentMol == selectedMols(currentSelectedMol)) % 'Normal' situation
                            currentSelectedMol = max(1, currentSelectedMol - 1);
                            currentMol = selectedMols(currentSelectedMol);
                        else  % Looking at deselected molecule in show selected only mode
                            % In this case, move to first selected molecule on the left
                            newCurrentSelectedMol = find(selectedMols < currentMol, 1, 'last');
                            if ~isempty(newCurrentSelectedMol)
                                currentSelectedMol = newCurrentSelectedMol;
                                currentMol = selectedMols(currentSelectedMol);                                
                            end
                        end
                    else
                        currentMol = max(currentMol - 1, 1);
                    end
                    % Update slider and molselect
                    set(molSlider, 'value', currentMol);        
                    set(molEdit, 'string', num2str(currentMol));
                    % Update include and min/max values for selected mol
                    set(minEdit, 'String', num2str(NeroData.mols{currentMol}.min));
                    set(maxEdit, 'String', num2str(NeroData.mols{currentMol}.max)); 
                    set(include, 'Value', NeroData.mols{currentMol}.include);
                    % Plot selected mol
                    plotMol(currentMol);
                case 'rightarrow'
                    if (get(showPopup, 'value') == 2)
                        if (currentMol == selectedMols(currentSelectedMol)) % 'Normal' situation
                            currentSelectedMol = min(length(selectedMols), currentSelectedMol + 1);
                            currentMol = selectedMols(currentSelectedMol);
                        else  % Looking at deselected molecule in show selected only mode
                            % In this case, move to first selected molecule on the right
                            newCurrentSelectedMol = find(selectedMols > currentMol, 1, 'first');
                            if ~isempty(newCurrentSelectedMol)
                                currentSelectedMol = newCurrentSelectedMol;
                                currentMol = selectedMols(currentSelectedMol);
                            end
                        end                        
                    else
                        currentMol = min(currentMol + 1, length(NeroData.mols));
                    end                                        
                    % Update slider and molselect
                    set(molSlider, 'value', currentMol);        
                    set(molEdit, 'string', num2str(currentMol));                    
                    % Update include and min/max values for selected mol
                    set(minEdit, 'String', num2str(NeroData.mols{currentMol}.min));
                    set(maxEdit, 'String', num2str(NeroData.mols{currentMol}.max)); 
                    set(include, 'Value', NeroData.mols{currentMol}.include);
                    % Plot selected mol
                    plotMol(currentMol);     
                case 'space'                  
                    NeroData.mols{currentMol}.include = ~NeroData.mols{currentMol}.include;
                    % Update include for selected mol
                    set(include, 'Value', NeroData.mols{currentMol}.include);             
                case 'uparrow'
                    uicontrol(minEdit);
                case 'downarrow'
                    uicontrol(maxEdit); 
                case 't'
%                     set(patch1, 'Visible', 'on');
%                     set(patch2, 'Visible', 'on');
%                     lim1 = get(axTrace1, 'ylim');
%                     lim2 = get(axTrace2, 'ylim');
%                     y1 = [lim1(1) lim1(1) lim1(2) lim1(2)];
%                     y2 = [lim2(1) lim2(1) lim2(2) lim2(2)];
%                     set(patch1, 'x', 400 * [rand rand rand rand]);
%                     set(patch1, 'y', y1);
%                     set(patch2, 'x', 600 * [rand rand rand rand]);
%                     set(patch2, 'y', y2);
%                     set(axTrace1, 'ylim', lim1);
%                     set(axTrace2, 'ylim', lim2);                    
                otherwise
            end
        end
    end
end

% OLD BUTTONS
% % Set focus to main window (only works if all ui is enabled)                    
% set(findobj(window, 'Type', 'uicontrol'), 'Enable', 'off');
% drawnow;
% set(findobj(window, 'Type', 'uicontrol'), 'Enable', 'on');  
% import ...
%     = uicontrol(controlPanel, ...
%                 'style', 'pushbutton', ...
%                 'string', 'Import', ...
%                 'TooltipString', 'Import TwoTone data files',...
%                 'callback', @importClick,...                       
%                 'position', importPosition);       
% export ...
%     = uicontrol(controlPanel, ...
%                 'style', 'pushbutton', ...
%                 'string', 'Export', ...
%                 'TooltipString', 'Export ebFRET data file',...                    
%                 'callback', @exportClick,...                       
%                 'position', exportPosition); 
% saveSession ...
%     = uicontrol(controlPanel, ...
%                 'style', 'pushbutton', ...
%                 'string', 'Save', ...
%                 'TooltipString', 'Save this Molselect session',...                      
%                 'callback', @saveClick,...                       
%                 'position', savePosition);                   
% loadSession ...
%     = uicontrol(controlPanel, ...
%                 'style', 'pushbutton', ...
%                 'string', 'Load', ...
%                 'TooltipString', 'Load a previous Molselect session',...                    
%                 'callback', @loadClick,...                       
%                 'position', loadPosition);  
