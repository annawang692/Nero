% Jacob Bakermans, December 2015
% Load datafiles and add them to input data
function newInput = loadData(currentInput, filename, pathname)   
    % Create new files cell 
    newFiles = cell(size(filename));  
    % Initiate waitbar
    wb = waitbar(0,'Loading data files...');
    for (i = 1:length(filename))
        % Load file
        path = [pathname filename{i}];        
        all = load(path, 'twotoneData');
        
        % Add file to new files cell
        newFiles{i} = struct;
        newFiles{i}.filePath = path;
        newFiles{i}.images = all.twotoneData.results.aDetImages;
        newFiles{i}.data = all.twotoneData.results.data;
        for (j = 1:length(newFiles{i}.data)) 
            newFiles{i}.data(j).fitParam = [];
        end
        % Update waitbar
        waitbar(i/length(filename),wb);          
    end 
    % Close waitbar
    close(wb);    
       
    % Add new input data to existing data
    newInput = currentInput;
    newInput((end + 1):(end + length(newFiles))) = newFiles; % Notice () parenthesis!!!
end