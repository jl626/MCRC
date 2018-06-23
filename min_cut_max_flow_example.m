% load data

lasMatName = sprintf('./data/plot_102.las');
s = lasread(lasMatName,'xyzirncp','double');
    x = s.X;    y = s.Y;    z = s.Z;
    i = s.intensity;    c = s.classification;
    LiDAR = [x,y,z,i]; % all LiDAR points 
    clear x y z i s
    
gd = LiDAR(:,3)<2; % ground point threshold 2 metres
LiDAR(gd,:)=[];tic;


    %initial tree top prior

load('C:/Users/juheonlee/Dropbox/graph_code/data/prior_data_102.mat');

% case - weighted graph

W = compute_weight2(LiDAR,10);  

% case - unweighted graph
W2 = W>0;
W2 = W2 - diag(diag(W2));


% data term (distance from tree tops)
S = compute_datacost(prior(:,1:2),LiDAR,2);

% regularisation term (L2 distance between tree tops)
sc = pdist2(prior(:,1:2),prior(:,1:2));%,'cityblock'); 
%% min cut // max flow algorithm (Boykov et al. 2001, 2004, 2011)
addpath('./gco-v3.0')
addpath('./gco-v3.0/matlab/');
    
% graph cut 
h = GCO_Create(length(LiDAR),size(prior,1));
dc=int32(round(S')); % data cost
GCO_SetDataCost(h,dc);
GCO_SetSmoothCost(h,sc); % smoothness cost
GCO_SetNeighbors(h,W2); % graph

% min-cut max-flow discrete optimisation (alpha expansion // alpha-beta
% swap 

%GCO_Expansion(h); % alpha expansion
GCO_Swap(h); % alpha-beta swap 

% results
label = GCO_GetLabeling(h);

% plot
cstring=rand(max(label),3);figure
for i =1:max(label); id = find(label==i); hold on; h2 =plot3(LiDAR(id,1),LiDAR(id,2),LiDAR(id,3),'.','color',cstring(mod(i,max(label))+1,:),'markersize',4);end 
daspect([1 1 1]);%set(gca,'position',[0 0 1 1],'units', 'normalized');
plot3(prior(:,1),prior(:,2),prior(:,3),'r*','markersize',8);
[E DD SS LL] = GCO_ComputeEnergy(h);  % Energy = Data Energy + Smooth Energy
GCO_Delete(h);
toc;