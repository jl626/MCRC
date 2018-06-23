%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       Wasserstein distance 
% 
% W_2 (\mu_0, \mu_1)
%
%
% input - p1 reference distribution
%       - p2 template distribution
%
% output - cost optimal transport cost
%        - move transported value
%
% c.f. it computes L^2-wasserstein distance 
%
%           Juheon Lee 17/08/2016
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cost] = wasserstein(p1,p2)

 % l2 distance
f = pdist2(p1,p2)'; f = f(:);
 
m = length(p1);
%n = length(p2); if two distributions have different sizes

% solve linear programming.
A = [kron(eye(m),ones(1,m));kron(ones(1,m),eye(m))]; b = ones(m*2,1);
Aeq = ones(m*2,m*m); beq = ones(m*2,1)*m; bd = zeros(m*m,1);
option = optimoptions('linprog','Algorithm','interior-point','Diagnostics','off','Display','off');
[move,cost]=linprog(f,A,b,Aeq,beq,bd,[],[],option);
cost = cost/sum(move);