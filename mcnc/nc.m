function [uc,d] = nc(L,D,ngroups,opt)

if nargin <4
    opt =0;
end

if(opt ==0)     %% D^-1*L
    invD = sparse(diag(1./(diag(D)+1e-10)));
    L_norm = invD * L;
    opts.disp = 0;
    opts.tol = 1e-2;
    opts.maxit = 30000;
    [uc,d] = eigs(L_norm,ngroups,'sr',opts);
    
elseif(opt == 1) %% L
    N = size(L,1);
    nD = sparse(1:N,1:N,1./(sqrt(diag(D))+eps));
    L_norm = nD * L * nD;
    opts.disp = 0;
    opts.tol = 1e-2;
    opts.maxit = 30000;
    [uc,d] = eigs(L_norm+speye(length(L_norm))*1e-12,ngroups,'sm',opts);      
elseif(opt ==2) %% D^-0.5*L*D^-0.5
    N = size(L,1);
    nD = sparse(1:N,1:N,1./(sqrt(diag(D))+1e-10));
    L_norm = nD * L * nD;
    opts.disp = 0;
    opts.tol = 1e-2;
    opts.maxit = 30000;
    [uc,d] = eigs(L_norm,ngroups,'sr',opts);  
    %[uc,d] = eigs(L_norm,ngroups,'sm',opts);      
    [d,id] = sort(diag(d),'ascend');
    uc = uc(:,id);
end