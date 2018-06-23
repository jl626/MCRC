function [X,flag] = normalizeX(X)
% Rescale each row by largest element to prevent over/underflow, and
% compute the 2-norm.
Xmax = max(abs(X),[],2);
X2 = bsxfun(@rdivide,X,Xmax);
Xnorm = sqrt(sum(X2.^2, 2));

% The norm will be NaN for rows that are all zeros, fix that for the test
% below.
Xnorm(Xmax==0) = 0;

% The norm will be NaN for rows of X that have any +/-Inf. Those should be
% Inf, but leave them as is so those rows will not affect the test below.
% The points can't be normalized, so any distances from them will be NaN
% anyway.

% Find points that are effectively zero relative to the point with largest norm.
flag = any(Xnorm <= eps(max(Xnorm)));

% Back out the rescaling, and normalize rows of X to have unit 2-norm.
% Rows can't be normalized become all NaN.
Xnorm = Xnorm .* Xmax;
X = bsxfun(@rdivide,X,Xnorm);
