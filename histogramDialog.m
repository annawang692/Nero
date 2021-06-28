% Jacob Bakermans, January 2016
function params = histogramDialog()
    histDialog = dialog('name', 'Set filters', ...
                         'color', [0.95 0.95 0.95], ...
                         'units', 'pixels', ...
                         'CloseRequestFcn', @cancel, ...
                         'DefaultUIPanelBackGroundColor', [0.95 0.95 0.95], ...
                         'DefaultUIControlUnits', 'normalized');
    
    % initialize output
    params = cell(9,1);
    for (i = 1:9)
        params{i} = -1;
    end
    
    % width and height in pixels
    w = 250;
    h = 280;

    % vertical and horizontal padding 
    vp = 0.03;
    hp = 0.03;

    % button height and width
    bh = (1 - 11 * vp) / 10; % nine rows of input, one line of buttons
    bw = (1 - 3 * hp) / 2; % two columns

    rect = get(histDialog, 'position');
    set(histDialog, 'position', [rect(1) rect(2) w h]);
    
    % ui elements: 6 rows, 2 columns
    textInclude ...
        = uicontrol(histDialog, ...
            'style', 'text', ...
            'string', 'Include molecules', ...
            'horizontalalignment', 'left', ...
            'position', [hp 9*bh+10*vp bw bh]);
    popupInclude ...
        = uicontrol(histDialog, ...
            'style', 'popup', ...
            'string', 'All|Selected', ...
            'position', [bw+2*hp 9*bh+10*vp bw bh]);  
    textMinAA ...
        = uicontrol(histDialog, ...
            'style', 'text', ...
            'string', 'Min AA?', ...
            'horizontalalignment', 'left', ...
            'position', [hp 8*bh+9*vp bw bh]);
    minAA ...
        = uicontrol(histDialog, ...
            'style', 'edit', ...
            'backgroundcolor', [1 1 1], ...            
            'string', '200', ...   
            'callback', @editValue, ...
            'position', [bw+2*hp 8*bh+9*vp bw bh]);     
    textMaxAA ...
        = uicontrol(histDialog, ...
            'style', 'text', ...
            'string', 'Max AA?', ...
            'horizontalalignment', 'left', ...
            'position', [hp 7*bh+8*vp bw bh]);
    maxAA ...
        = uicontrol(histDialog, ...
            'style', 'edit', ...
            'backgroundcolor', [1 1 1], ...            
            'string', '2000', ...   
            'callback', @editValue, ...
            'position', [bw+2*hp 7*bh+8*vp bw bh]);           
    textMinDD ...
        = uicontrol(histDialog, ...
            'style', 'text', ...
            'string', 'Min DD?', ...
            'horizontalalignment', 'left', ...
            'position', [hp 6*bh+7*vp bw bh]);
    minDD ...
        = uicontrol(histDialog, ...
            'style', 'edit', ...
            'string', '300', ...   
            'backgroundcolor', [1 1 1], ...                
            'callback', @editValue, ...            
            'position', [bw+2*hp 6*bh+7*vp bw bh]);     
    textMaxDD ...
        = uicontrol(histDialog, ...
            'style', 'text', ...
            'backgroundcolor', [0.95 0.95 0.95], ...
            'string', 'Max DD?', ...
            'horizontalalignment', 'left', ...
            'position', [hp 5*bh+6*vp bw bh]);
    maxDD ...
        = uicontrol(histDialog, ...
            'style', 'edit', ...
            'string', '3000', ...  
            'backgroundcolor', [1 1 1], ...                
            'callback', @editValue, ...            
            'position', [bw+2*hp 5*bh+6*vp bw bh]);        
    textMinDA ...
        = uicontrol(histDialog, ...
            'style', 'text', ...
            'string', 'Min DA?', ...
            'horizontalalignment', 'left', ...
            'position', [hp 4*bh+5*vp bw bh]);
    minDA ...
        = uicontrol(histDialog, ...
            'style', 'edit', ...
            'backgroundcolor', [0.95 0.95 0.95], ...            
            'string', '', ...        
            'callback', @editValue, ...            
            'position', [bw+2*hp 4*bh+5*vp bw bh]);        
    textMaxDA ...
        = uicontrol(histDialog, ...
            'style', 'text', ...
            'string', 'Max DA?', ...
            'horizontalalignment', 'left', ...
            'position', [hp 3*bh+4*vp bw bh]);
    maxDA ...
        = uicontrol(histDialog, ...
            'style', 'edit', ...
            'backgroundcolor', [0.95 0.95 0.95], ...            
            'string', '', ...       
            'callback', @editValue, ...            
            'position', [bw+2*hp 3*bh+4*vp bw bh]);      
    textMinFrame ...
        = uicontrol(histDialog, ...
            'style', 'text', ...
            'string', 'Min frame?', ...
            'horizontalalignment', 'left', ...
            'position', [hp 2*bh+3*vp bw bh]);
    minFrame ...
        = uicontrol(histDialog, ...
            'style', 'edit', ...
            'backgroundcolor', [0.95 0.95 0.95], ...            
            'string', '', ...        
            'callback', @editValue, ...            
            'position', [bw+2*hp 2*bh+3*vp bw bh]);        
    textMaxFrame ...
        = uicontrol(histDialog, ...
            'style', 'text', ...
            'string', 'Max frame?', ...
            'horizontalalignment', 'left', ...
            'position', [hp 1*bh+2*vp bw bh]);
    maxFrame ...
        = uicontrol(histDialog, ...
            'style', 'edit', ...
            'backgroundcolor', [0.95 0.95 0.95], ...            
            'string', '', ...       
            'callback', @editValue, ...            
            'position', [bw+2*hp 1*bh+2*vp bw bh]);          
    okButton ...
        = uicontrol(histDialog, ...
            'style', 'pushbutton', ...
            'string', 'Ok', ...
            'position', [hp vp bw bh], ...
            'callback', @OK);
    cancelButton ...
        = uicontrol(histDialog, ...
            'style', 'pushbutton', ...
            'string', 'Cancel', ...
            'position', [bw+2*hp vp bw bh], ...
            'callback', @cancel);               

    function editValue(source,callbackdata)
        if (isnan(str2double(get(source, 'string'))))
            set(source, 'backgroundcolor', [0.95 0.95 0.95]);
            set(source, 'string', '');
        else
            set(source, 'backgroundcolor', [1 1 1]);
        end
    end
        
    function OK(source,callbackdata)
        params{1} = get(popupInclude, 'value');
        params{2} = str2double(get(minAA, 'string'));
        params{3} = str2double(get(maxAA, 'string'));
        params{4} = str2double(get(minDD, 'string'));
        params{5} = str2double(get(maxDD, 'string'));
        params{6} = str2double(get(minDA, 'string'));        
        params{7} = str2double(get(maxDA, 'string')); 
        params{8} = str2double(get(minFrame, 'string'));        
        params{9} = str2double(get(maxFrame, 'string'));           
        uiresume();
        delete(histDialog);
    end

    function cancel(source,callbackdata)
        for (i = 1:9)
            params{i} = -1;
        end
        uiresume();
        delete(histDialog);
    end

    uiwait(histDialog);                    
end
