   % load data
    lasMatName = sprintf('./data/plot_102.las');
    s = lasread(lasMatName,'xyzirncp','double');
    x = s.X;    y = s.Y;    z = s.Z;
    i = s.intensity;    c = s.classification;
    LiDAR = [x,y,z,i]; % all LiDAR points 
    clear x y z i s
    
    gd = LiDAR(:,3)<2; % ground point threshold 2 metres
    LiDAR(gd,:)=[];
    tic;
    addpath('./mcnc');
    %initial tree top prior
    load('./data/prior_data_102.mat');
   
    M = size(prior,1); % the number of spectral eigenvectors.
    % construct sparse graph (with radius <0.5 metres)
    [W,D] = compute_weight(LiDAR,0.5);
    % graph Laplacian
    L = (D-W);
    vol = sum(diag(D));
    % compute eigenvectors
    [nV,sig] = nc(L,D,M,1);
    % graph cut parameter 
    alpha = -1*sig(end);  
    % constraining graph cut with tree top priors
    S = compute_prior(prior(:,1:2),LiDAR,1);
    uc = mcncup(nV(:,2:end),sig(2:end),D,S,alpha);
    % results
    label = v2idx(uc,M,3);
    
    % plot
    cstring=rand(max(label),3);
    for i =1:max(label); id = find(label==i); hold on; h2 =plot3(LiDAR(id,1),LiDAR(id,2),LiDAR(id,3),'.','color',cstring(mod(i,max(label))+1,:),'markersize',4);end 
    daspect([1 1 1]);%set(gca,'position',[0 0 1 1],'units', 'normalized');
    plot3(prior(:,1),prior(:,2),prior(:,3),'r*','markersize',8);
    toc;