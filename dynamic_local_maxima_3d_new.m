function [id, pos,Ntree] = dynamic_local_maxima_3d_new(data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dynamic method 
%{
% parameters
% x direction max and min
thres = 0.5;
minsrh = 0.5;
h = data(:,3);

% search size maximum
if max(data(:,3)) >15
maxsrh = 3;
else
maxsrh = 5;   
end

%step search size
stepss = [minsrh:0.5:maxsrh];

% vectorise OHM & filter <2m
h(h<2)=[];
%[mm,nn] = size(OHM);
% plot histogram & divide data from thres to quantile 0.99
%hh = hist(H,length(stepss));
hq = quantile(h,0.99);
% generate sequence with length(stepss) interval
ss = thres:(hq-thres)/(length(stepss)-1):hq;
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fixed window method
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fixed case
%window = knnsearch(data(:,1:2),data(:,1:2),'k',100,'IncludeTies',true);
h = data(:,3)<2;
data(h,:)=[];
[window,dist] = rangesearch(data(:,1:2),data(:,1:2),2);
% local maxima points
index = [];
thr = quantile(data(:,3),0.5);

for i = 1:length(data)    
    % dynamic search 
    %{
    %check height quantile
    if h(i)<max(ss)
    pos = find(Gnew(r,k)<ss, 1 )-1;
    else
        pos = dd;
    end
    if pos ==0
        pos = 1;
    end    
    search = stepss(pos);
    %}
    % local window sample
    if data(i,3) > thr
    list = window{i};
    else
    list = window{i};
    dd = dist{i}>1.5;
    list(dd)=[];
    end
   %list = window{i};
   sample = data(list,3);
   hmax = max(data(list,3));
       if data(i,3) == hmax;
        tie = find(sample==hmax);
        others = find(list(tie) ~= i);
            if ~isempty(others)
            data(list(tie(others)),3)=0;
            end
       index = [index,i];     
       end      
end
n_data = data(index,:);
id = find(n_data(:,3)>0);
pos = n_data(id,:);
Ntree = length(id);
