function averagedVector = block_averaging(inputVector, blockSize)
%% Inputs
% inputVector - measurments of dize [NxL]
% blockSize - block size of for block averaging (int)
%% Output
% averagedVector - block averaging of the inputVector
%%------------------------block averaging---------------------------------%

 remainingPoints = rem(length(inputVector), blockSize);
 second_dim = size(inputVector, 2);

 averagedVector = blockproc(inputVector, [blockSize, second_dim], @(blockStruct) mean(blockStruct.data));
 if remainingPoints > 0
     lastBlock = inputVector(end - remainingPoints + 1:end);
     averagedVector = [averagedVector; mean(lastBlock)];
 end

end