function [idx,peak,Ntrees] = dynamic_local_maxima(OHM)

% parameters
[M, N]=size(OHM);
thres = 5;
minsrh = 3;
if nanmax(OHM(:)) >15
maxsrh = 5;
else
maxsrh = 5;   
end
% remove nan
%hh(isnan(hh))=[];
OHM(isnan(OHM))=0;
hh = OHM;
%step search size
stepss = [minsrh:2:maxsrh];
% vectorise OHM & filter <2m
hh(hh<2)=[];
%[mm,nn] = size(OHM);
% plot histogram & divide data from thres to quantile 0.99
%hh = hist(H,length(stepss));
hq = quantile(hh,0.99);
% generate sequence with length(stepss) interval
ss = thres:(hq-thres)/(length(stepss)-1):hq;
% ???? do not understand logic
Max = OHM;%reshape(OHM(:),N,M);
%Max = fliplr(Max);
Gnew = Max;
Max = zeros(size(Max));
Index = zeros(size(Max));
dd = length(stepss);
% define edges
[j,i] = find(Gnew);
II = [i,j];
c = find(i>=ceil(minsrh/2));
II = II(c,:);
c = find(II(:,1)<=size(Gnew,1)-ceil(minsrh/2));
II = II(c,:);
c = find(II(:,2)>=ceil(minsrh/2));
II = II(c,:);
c = find(II(:,2)<=size(Gnew,2)-ceil(minsrh/2));
II = II(c,:);
clear c i j
index = 1;

for i = 1:length(II)
    % each grid
    k = II(i,1);
    r = II(i,2);
    %check height quantile
    if Gnew(r,k)<max(ss)
    pos = find(Gnew(r,k)<ss, 1 )-1;
    else
        pos = dd;
    end
    if pos ==0
        pos = 1;
    end
    % define search size
    search = stepss(pos);
  
    minR = r-floor(search/2);
    if minR<1
       minR = 1;
    end
    minC = (k-floor(search/2));
    if minC<1
       minC = 1;
    end  
    maxR = r+floor(search/2);
    if maxR>size(Gnew,1)
       maxR = size(Gnew,1);       
    end    
    maxC = k+floor(search/2);
    if maxC>size(Gnew,2)
       maxC = size(Gnew,2);
    end
    FIL = Gnew(minR:maxR,minC:maxC);  
    if Gnew(r,k)==max(FIL(:)) && Gnew(r,k)~=0    
    Max(r,k)=1;
    Index(r,k)=index;
    index=index+1;
   end
end
Ntrees=max(Index(:));
peak = Max';
[x,y] = find(peak);
idx = [x,y];
%imshow(Max) %Max is the raster of the local maxima

