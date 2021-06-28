% Jacob Bakermans, December 2015
% Export molecule data to ebFRET input file
function saveData(molData, filename, path)
    totalMols = length(molData);
    includedMols = 0;
    % Find molecule with longest time trace
    maxTime = 1;
    for (currentMol = 1:totalMols)
        if (molData{currentMol}.include)
            maxTime = max(maxTime, length(molData{currentMol}.DD));
            includedMols = includedMols + 1;
        end
    end
    % Create data array
    out = -1*ones(maxTime, includedMols * 2);
    % Fill data array with molecule data
    currentIncluded = 1;
    for (currentMol = 1:totalMols)
        if (molData{currentMol}.include)
            out(molData{currentMol}.min:molData{currentMol}.max, currentIncluded*2 - 1) = molData{currentMol}.DD(molData{currentMol}.min:molData{currentMol}.max);
            out(molData{currentMol}.min:molData{currentMol}.max, currentIncluded*2) = molData{currentMol}.DA(molData{currentMol}.min:molData{currentMol}.max);
            currentIncluded = currentIncluded + 1;
        end
    end
    % Write output array to file
    dlmwrite([path filename],out)       
end