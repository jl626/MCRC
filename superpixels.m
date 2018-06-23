label = imread('label.png');
image = imread('org.png');
sp = xlsread('sp.xlsx')';
%imread('sp.png');

% different from the mean intensity of the liver

mn = zeros(max(sp(:)),1);

for i = 0:max(sp(:))
    
    idx = find(sp == i);
    mn(i+1) = mean(image(idx));
end

lv = find(label==1);
bg = find(label==0);

m_lv = mean(image(lv));
m_bg = mean(image(bg));


d_lv = abs(mn-m_lv);
d_bg = abs(mn-m_bg);

dc1 = [d_lv,d_bg]';


% distance from the liver centre

centre = [159 101];

[ii,jj]=ind2sub([250 330],find(label+1));
coor = [ii,jj];
dc2 = reshape(pdist2(centre,coor),[250 330]);

c_dist = zeros(max(sp(:))+1,1);

for i = 0:max(sp(:))
     idx = find(sp == i);
     c_dist(i+1) = mean(dc2(idx));
end

% data term
dc = dc1*100+[c_dist, max(c_dist)-c_dist]';

% smoothness term
sc = [0 1; 1 0];

% label cost
lc = [1000 1000];

%centroids = zeros(256,2);
%c1 = regionprops(sp,'centroid')';
%cell2mat(c1.Centroid');

%%{
centroids = zeros(max(sp(:)),2);

for i = 0:max(sp(:))
    idx = find(sp==i);
    img = zeros(250, 330);
    img(idx) = 1;
    val = regionprops(logical(img), 'centroid');
    centroids(i+1,:) = val.Centroid;
end
%}

W = compute_weight3(centroids,15);
W2 = W*0.01;
%W2 = W>0;
W2 = W2 - diag(diag(W2));

%% main graph cut function
h = GCO_Create(max(sp(:))+1,2);
dc=int32(round(dc)); % data cost
GCO_SetDataCost(h,dc);
GCO_SetSmoothCost(h,sc); % smoothness cost
GCO_SetLabelCost(h,lc);
GCO_SetNeighbors(h,W2); % graph
GCO_Expansion(h); % alpha expansion

label1 = GCO_GetLabeling(h);

new_label = zeros(250,330);

for i = 0:max(sp(:))
    idx = find(sp==i);
    new_label(idx) = label1(i+1);
end

GCO_Delete(h);

imshow(image);
hold on
contour(new_label-1.5,[0 0],'r');