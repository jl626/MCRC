function [W,D] = compute_weight3(data,radii)
%
%      
%       Input: data= Number_of_data x Number_of_features
%       ouput: W = pair-wise similarity matrix
%
%         25/11/2014

N = size(data,1); %R = size(data,2);
[idx,~] = knnsearch(data(:,1:2),[],radii);
%[idx,~] = rangesearch(data(:,1:2),data(:,1:2),radii);
    %sigxy = 2;
    %sigz = 3;
    sigxyz = 1;

    ii = [];
    jj = [];
    cc = [];
for i= 1:N,
        %j = idx{i}; % distance within 10 metres
        j = idx(i,:); % distance within 10 metres
        %j = unique([idx{i},idx1{i}]);
        % x,y features
        %xyi = data(i,1:2); 
        %xydelta = xyi(ones(numel(j),1), :) - data(j,1:2); % x,y direction
        % z featues
        %zi = data(i,3); 
        %zdelta = zi(ones(numel(j),1), :) - data(j,3);
        %c = exp((exp(-sqrt(sum(xydelta.^2,2))/sigxy) .* exp(-sqrt(zdelta.^2)/sigz))); % Only LiDAR 
        
        % 3D distance
        xyzi = data(i,1:2); % x,y features
        xyzdelta = xyzi(ones(numel(j),1), :) - data(j,1:2); % x,y direction
        c = sum(xyzdelta.^2,2)/sigxyz; %only LiDAR
        
        ii = [ii i*ones(1,numel(j))];
        jj = [jj j];
        cc = [cc c'];
end
W = sparse(ii,jj,cc,N,N);
%W = max(W,W'); % symmetric knn graph
D=spdiags(sum(W,2),0,length(W),length(W));% diagonal matrix