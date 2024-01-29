function extractedVector = block_extraction(inputVector, blockSize)
    %% Inputs
    % inputVector - string array of measurements [Nx1]
    % blockSize - block size for block extraction (int)
    %% Output
    % extractedVector - block extraction of the inputVector
    %%------------------------block extraction----------------------------%

    inputVector = inputVector(:);

    numBlocks = ceil(length(inputVector) / blockSize);
    extractedVector = strings(numBlocks, 1);

    for i = 1:numBlocks
        startIndex = (i - 1) * blockSize + 1;
        endIndex = min(i * blockSize, length(inputVector));
        block = inputVector(startIndex:endIndex);
        extractedVector(i) = block(1);
    end
end