function nQ = normPriors(Q,d)

AQ = abs(Q);
PQ = (AQ+Q)/2;
NQ = (AQ-Q)/2;
P = size(Q,2);
nQ = [];

for i=1:P
    pq = PQ(:,i);
    nq = NQ(:,i);
    pd = d.*pq;
    nd = d.*nq;
    pvol = sum(pd)+1e-6;
    nvol = sum(nd)+1e-6;
    n= sqrt(pd*nvol/pvol)-sqrt(nd*pvol/nvol);
    nQ = [nQ,n];
end

nQ = normalizeX(nQ')';