function [idx,X] = v2idx(v,ngroups,opt,iterCount)

if nargin < 3
    opt =0;
end

if nargin <4
    iterCount =20;
end
opts = statset('Display','off');
% iterCount = 20;
if(opt == 0)    
    X = v;
    [idx] = kmeans(v(:,1:end),ngroups,'EmptyAction','drop','Replicates',...
        iterCount,'options',opts);
elseif(opt==1)
    X=v;
    X = normalizeX(X);
    [idx] = kmeans(X,ngroups,'EmptyAction','drop','Replicates',...
        iterCount,'options',opts);
elseif(opt==2)
    X = sign(v);
    [idx] = kmeans(X,ngroups,'EmptyAction','drop','Replicates',...
        iterCount,'options',opts);
elseif(opt==3)
    N = size(v,1);
    X = v;
    [mtmp,idx] = max(v,[],2);
   
end
