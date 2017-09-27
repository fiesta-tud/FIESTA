function I = fGetStackFrame(Stack,idx)
I = zeros(size(Stack{1}(:,:,idx)),'like',Stack{1});
for n = 1:length(Stack)
    I(:,:,n) = Stack{n}(:,:,idx);
end