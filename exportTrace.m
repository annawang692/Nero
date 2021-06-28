% Jacob Bakermans, January 2016
% Export all data from current molecule trace to file
function exportTrace(allMolecules, currentMol)
        [filename, pathname] = uiputfile('*.txt', 'Save current trace');
        if (isequal(filename,0) || isequal(pathname,0)) % User pressed cancel
            return;
        else
            % Get data
            t = allMolecules{currentMol}.min:allMolecules{currentMol}.max;
            AA = allMolecules{currentMol}.AA(allMolecules{currentMol}.min:allMolecules{currentMol}.max);
            DD = allMolecules{currentMol}.DD(allMolecules{currentMol}.min:allMolecules{currentMol}.max);
            DA = allMolecules{currentMol}.DA(allMolecules{currentMol}.min:allMolecules{currentMol}.max);
            E = allMolecules{currentMol}.E(allMolecules{currentMol}.min:allMolecules{currentMol}.max);
            S = allMolecules{currentMol}.S(allMolecules{currentMol}.min:allMolecules{currentMol}.max);              
            % Create header
            header = 't\tAA\tDD\tDA\tE\tS\n'; 
            % Write header to file
            fileID = fopen([pathname filename],'wt');
            fprintf(fileID,header);
            fclose(fileID);
            % Save created output matrix to file
            dlmwrite([pathname filename],[t' AA DD DA E S],'-append','delimiter','\t','newline', 'pc')   
        end  
end