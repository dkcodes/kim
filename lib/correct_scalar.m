function [out, scalars ]= correct_scalar(A, B, toggle_sign_only)


if size(A, 2) ~= size(B, 2)
    error('size(A, 2) must equal size(B, 2)');
end
size_A = size(A, 1);
size_B = size(B, 1);
scalars = zeros(1, size(A,2));
for i = 1:size(A, 2)
    a = A(:,i);
    b = resample(B(:,i), size_A, size_B);
    scalars(i) = a\b;
end
if nargin>2
    if toggle_sign_only == 1
        scalars = sign(scalars);
    end
end
out = A .* repmat(scalars, size(A,1), 1);



    