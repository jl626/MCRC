function [W] = smooth(data,radii)
%
%      
%       Input: data= Number_of_data x Number_of_features
%       ouput: W = pair-wise similarity matrix
%
%         Jan Lellmann, Juheon Lee
%         25/11/2014

N = size(data,1); R = size(data,2);
%[idx,dist] = knnsearch(data(:,1:2),data(:,1:2),'k',radii,'IncludeTies',true);
[idx,~] = rangesearch(data(:,1:2),data(:,1:2),radii);
    sigxy = 2;%0.13;%1.35; 
%    sigz = 3;%8;
%   sigxyz = 5;
%    sigf = 0.005;% england 0.003 % italy 
%   sigff = 1.5;
    ii = [];
    jj = [];
    cc = [];
for i= 1:N,
%        j = idx(i,:); % distance within 10 metres
        j = idx{i};
        % x,y features
        xyi = data(i,1:2); 
        xydelta = xyi(ones(numel(j),1), :) - data(j,1:2); % x,y direction
        c = (exp(-sqrt(sum(xydelta.^2,2))/sigxy)); %.* exp(-sqrt(zdelta.^2)/sigz))  ; % Only LiDAR 
%   
        ii = [ii i*ones(1,numel(j))];
        jj = [jj j];
        cc = [cc c'];
end
W = sparse(ii,jj,cc,N,N);
W = W>0;
%W = max(W,W'); % symmetric knn graph
%D=spdiags(sum(W,2),0,length(W),length(W));% diagonal matrix