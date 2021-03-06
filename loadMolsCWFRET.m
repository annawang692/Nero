% Jacob Bakermans, December 2015
% Extract data from (possibly changed) input data to individual molecule data
function newMols = loadMolsCWFRET(in, currentMols)
    % Initiate variables
    numberOfFiles = length(in);
    numberOfMolecules = 0;
    newMols = currentMols;
   
    % Check all files in input data
    for (currentFile = 1:numberOfFiles)        
        allMolData = in{currentFile}.data;
        molsInFile = length(allMolData);
        numberOfMolecules = numberOfMolecules + molsInFile;
        if (numberOfMolecules > length(newMols)) % If these molecules are new
            for (i = 1:molsInFile)
                % Extract molecule data from input data
                data = allMolData(i);
                DD = data.intensity(:,1); % data.intensity(2:2:end,1);
                DA = data.intensity(:,2); % data.intensity(2:2:end,2);
                AD = ones(size(DD)); % data.intensity(1:2:end,1);
                AA = ones(size(DD)); % data.intensity(1:2:end,2);
                E = DA./(DD+DA);
                S = ones(size(DD));
                % Save molecule data
                currentMol = length(newMols) + 1;
                newMols{currentMol} = struct;                
                newMols{currentMol}.DD = DD;
                newMols{currentMol}.DA = DA;
                newMols{currentMol}.AA = AA;
                newMols{currentMol}.E = E;
                newMols{currentMol}.S = S;
                newMols{currentMol}.posDD = data.aDetData.aDetPos(1,:);
                newMols{currentMol}.posAA = data.aDetData.aDetPos(2,:); 
                newMols{currentMol}.posDA = data.aDetData.aDetPos(3,:);                
                newMols{currentMol}.include = false;
                newMols{currentMol}.min = 1;
                newMols{currentMol}.max = length(E);
                newMols{currentMol}.file = currentFile;
            end
        end
    end
end