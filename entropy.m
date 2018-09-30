function H = entropy(X, offset)
    H = - sum(X .* log2(offset +  X), 1);
    %H = - sum(X .* log2(X), 1);
end