% Jacob Bakermans, February 2016
% Horst Steuer, June 2017
% Create sum of selected traces
function createSumTraces(allMolecules)   

    
    %traces can have different length so find the longest
    maxlength = 0;
    for (currentMol = 1:length(allMolecules))
        maxlength = max(maxlength,length(allMolecules{currentMol}.AA));
    end
    AAsum = zeros(maxlength,1);
    DAsum = zeros(maxlength,1);
    DDsum = zeros(maxlength,1);
    includeAll = false;
    for (currentMol = 1:length(allMolecules))
        if (includeAll)
            AA = zeros(maxlength,1);
            DA = zeros(maxlength,1);
            DD = zeros(maxlength,1);
            AA(1:length(allMolecules{currentMol}.AA)) = allMolecules{currentMol}.AA;
            DD(1:length(allMolecules{currentMol}.AA)) = allMolecules{currentMol}.DD;
            DA(1:length(allMolecules{currentMol}.AA)) = allMolecules{currentMol}.DA;
            
            AAsum = AAsum + AA;
            DAsum = DAsum + DA;
            DDsum = DDsum + DD;
         
        else
            if (allMolecules{currentMol}.include)
                AA = zeros(maxlength,1);
                DA = zeros(maxlength,1);
                DD = zeros(maxlength,1);
                AA(1:length(allMolecules{currentMol}.AA)) = allMolecules{currentMol}.AA;
                DD(1:length(allMolecules{currentMol}.AA)) = allMolecules{currentMol}.DD;
                DA(1:length(allMolecules{currentMol}.AA)) = allMolecules{currentMol}.DA;
                
                AAsum = AAsum + AA;
                DAsum = DAsum + DA;
                DDsum = DDsum + DD;
                
               
            end           
        end
    end
    plotMols(DDsum, DAsum, AAsum);
    exportMols(DDsum, DAsum, AAsum);
    
    
    
    function exportMols(DD,DA,AA)
        X = (1:length(DD))';
        outData = [X DD DA AA];
        filename = fullfile('.', 'DDDAAAsums.txt');
        fid = fopen(filename, 'wt');
        fprintf(fid, '%s\t%s\t%s\t%s\n', 'X', 'DD','DA','AA');  % header
        X = 1:length(DD);
        fclose(fid);
        dlmwrite(filename,outData,'delimiter','\t','precision',['%10.',num2str(12),'f'],'-append');
    end
    
     function plotMols(DD,DA,AA)  
         X = 1:length(DD);
         figure
         hold on;
         plot(X, AA, 'k', 'DisplayName', 'AA');        
         plot(X, DD, 'g', 'DisplayName', 'DD');
         plot(X, DA, 'r', 'DisplayName', 'DA');
         hold off;   
         legend('show', 'location', 'northeast');
     end
end