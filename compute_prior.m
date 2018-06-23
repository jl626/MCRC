% Create Prior matrix 
%   Input 
%       - data:              data matrix
%       - prior:             seeding point
%       - flag:              pairwise(0)//unary(1)        
%   Output
%
%       - S:                 prior matrix
%
%  reference  "Hu at al. 2013, Multi-Class Constrained Normalized Cut with
%  Hard, Soft..., TIP."
% 
%                   Juheon Lee 31/03/2015
function S = compute_prior(prior,data,flag)
if nargin<3
flag = 1;
end

N = length(data);k = length(prior);
% find k-nearest points from seeding points
%[pidx,dist] = knnsearch(data(:,1:2),prior,'k',nn,'IncludeTies',false); % prior points
%pidx1= sortrows(pidx); Unary_Priors = mat2cell(pidx1,ones(1,k),nn);
[Unary_Priors,dist] = rangesearch(data(:,1:2),prior,0.7); % prior points

% compute pairwise distance between priors
dist = squareform(pdist(prior));
Q=sparse(N,N); %pairwise constraints

if(flag ==0) %pairwise case
    M = []; C = [];
    Cd=[];
    % must-link
    for i = 1:k
    a = Unary_Priors{i};
        for j = 1:length(Unary_Priors{i})
            m = ones(length(a),1)*a(j);
            M = [M;[m,a']];
        end
    end

    % cannot-link
    for i = 1:k
        for j = i+1:k
            C =[C;[Unary_Priors{i}(1)',Unary_Priors{j}(1)']];
            Cd = [Cd;[dist(i,j)]];
        end
    end
    
    for i= 1:size(M,1)
        Q(M(i,1),M(i,2)) = 1;
        Q(M(i,2),M(i,1)) = 1;
    end

    for i= 1:size(C,1)    
        Q(C(i,1),C(i,2)) = exp(-Cd(i)/3)-1;
        Q(C(i,2),C(i,1)) = exp(-Cd(i)/3)-1;
    end
    
    for i=1:N
        Q(i,i)=1;
    end
    S = Q;
    %    linkIdx = [];
%    S = [];
else
    % unary case
    S = zeros(N,k);
% prior matrix S
    for i=1:k
        dif_ind = setdiff(1:k,i);
        S(Unary_Priors{i},i) = 1;
        S(Unary_Priors{i},dif_ind) = -1;
    end  
end
end