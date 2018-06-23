function [X] = mcncup(V,lamVec,D,S,alpha)
%% MCNC-UP algorithm
% @V: the precomputed eigenvectors with dimension of N*M
% @D: the degree matrix (N*N)
% @lamVec: the eigenvalues corresponding to each colum of V
% @S: the unnormalized prior matrix
% @alpha: a parameter in MCNC-UP algorithm
[N,M] = size(V);
if isempty(D)
    nQ = S;
else
    nQ = normPriors(S,diag(D));
end

ngroups = size(S,2);


X = zeros(size(nQ));

for i=1:ngroups
    for j=1:size(V,2)
        X(:,i) = X(:,i)+V(:,j)/(lamVec(j)-alpha)*(V(:,j)'*nQ(:,i));
    end
end
X = normalizeX(X')';
