% Jacob Bakermans, January 2016
% Load v2 datafiles and add them to input data
% Takes some effort since originally, only the fitsResult.mat extension was
% allowed. This function loads a v2.mat file and extracts and reorders the
% data in such a way that it resembles the fitsResult.mat files.
function newInput = loadDataV2(currentInput, filename, pathname)   
    % Create new files cell 
    newFiles = cell(size(filename));  
    % Initiate waitbar
    wb = waitbar(0,'Loading data files...');
    for (i = 1:length(filename))
        % Load file
        path = [pathname filename{i}];        
        intensities = load(path, 'intensities');
        analysis_info = load(path, 'analysis_info');
        positionData = load(path, 'positionData');
        intensities = intensities.intensities;
        analysis_info = analysis_info.analysis_info;
        positionData = positionData.positionData;
        
        assignin('base', 'loaded_intensities', intensities);
        assignin('base', 'loaded_analysis_info', analysis_info);
        assignin('base', 'loaded_positionData', positionData);
        firstGreenFrame = analysis_info.firstGreenFrame;
        
        fretData = cell(length(intensities),1);
        aDetPos = cell(length(intensities),1);
        for (k = 1:length(intensities))
            green = intensities(k).green;
            red = intensities(k).red;
            if (mod(firstGreenFrame,2) == 1)
                DD = green(1:2:end);
                AD = green(2:2:end);
            else
                DD = green(2:2:end);
                AD = green(1:2:end);                
            end
            if (mod(firstGreenFrame,2) == 1)
                DA = red(1:2:end);
                AA = red(2:2:end);
            else
                DA = red(2:2:end);
                AA = red(1:2:end);
            end
            E = DA ./ (DD + DA);
            S = (DD + DA) ./ (DD + DA + AA);
            fretData{k} = [zeros(size(DA)) zeros(size(DA)) DD DA AD AA E S];
            
            aDetPos{k} = [intensities(k).DDadetPos; intensities(k).AAadetPos; intensities(k).DAadetPos];
        end
            
        assignin('base', 'fretData', fretData);
                    
        data = [];
        for (k = 1:length(intensities))
            a = struct();
            a.aDetData = struct('aDetPos', aDetPos{k});
            a.intensity = [];
            a.fitParam = [];
            a.fretData = fretData{k};
            data = [data a];
        end
        
        assignin('base', 'data', data);
        
        % Add file to new files cell
        newFiles{i} = struct;
        newFiles{i}.filePath = path;
        newFiles{i}.data = data;
        newFiles{i}.images = cell(3,1);
        newFiles{i}.images{1} = positionData.DexDem;
        newFiles{i}.images{2} = positionData.AexAem;
        newFiles{i}.images{3} = positionData.DexAem;          
        % Update waitbar
        waitbar(i/length(filename),wb);          
    end 
    % Close waitbar
    close(wb);    
       
    % Add new input data to existing data
    newInput = currentInput;
    newInput((end + 1):(end + length(newFiles))) = newFiles; % Notice () parenthesis!!!
end