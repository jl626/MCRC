% Create data cost matrix 
%
%
%
%
%
%
%
%
%                   Juheon Lee 30/04/2016
function [wcost] = test_cost(data,h1)

N = size(data,1); 
cc = zeros(length(data),1);

for i= 1:N,
        val = data(i,:);
        %HH = max(data(:,3));
        %r = exp((50-(HH-val(1,3)))/34);
        [idx,~] = rangesearch(data(:,1:2),val(1,1:2),1);
        j = idx{1};
        height = data(j,:); 
        % x,y features
        if length(height)>250 
        k = height(:,3)>val(1,3); height(k,:) = [];        
        h2z = histogram(height(:,3),10,'Normalization','probability'); h2 = h2z.Values;% x,y direction
        %[~,h2y] = hist(height(:,2)-data(i,2),10); %h2y = h2y/max(h2y);
        %[~,h2x] = hist(height(:,1)-data(i,1),10); %h2x = h2x/max(h2x);
        %h2 = [h2z;h2y;h2x];
        c = wasserstein(h1',h2');%*(34/(val(1,3)*0.75)));
                if isempty(c)
                    c = nan;
                end
        cc(i) = c;
        else
        %k = height(:,3)>val(1,3)+4;  height(k,:) = [];        
        %h2z = histogram(height(:,3),10,'Normalization','probability'); h2 = h2z.Values;% x,y direction
        %[~,h2y] = hist(height(:,2)-data(i,2),10); %h2y = h2y/max(h2y);
        %[~,h2x] = hist(height(:,1)-data(i,1),10); %h2x = h2x/max(h2x);
        %h2 = [h2z;h2y;h2x];
        %c = wasserstein(h1',h2');%*(34/(val(1,3)*0.75)));            
        %        if isempty(c)
                    c = nan;
        %        end
        cc(i) = c;
        end       
end
cc(isnan(cc))= nanmax(cc);
wcost = cc;