% Jacob Bakermans, December 2015
% To keep things fast, clear the molecules in the input data
function newInput = clearData(currentInput)
    newInput = currentInput;
    for (currentFile = 1:length(currentInput))
        newInput{currentFile}.data = zeros(length(currentInput{currentFile}.data),1);
    end
end