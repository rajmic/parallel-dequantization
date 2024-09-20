function [p, SDR] = cp_alg(y, param, in)
% Chambolle-Pock algorithm
%
% Vojtěch Kovanda
% Brno University of Technology, 2024

% definition of clip function (result of the Fenchel-Rockafellar conjugate of soft thresholding)
clip = @(x) (sign(x).*min(abs(x), 1));

zeta = param.lam(param.w-3); % setting threshold for clipping
sig = 1/zeta;

%% initial values
i = 0;

p = zeros(param.L, 1);
x = zeros(param.L, 1);
q = frana(param.F, y);
q = zeros(size(q));
SDR = zeros(param.maxit-1, 1);

%% algorithm
while i < param.maxit

    i = i + 1;
     
waitbar(i/param.maxit);
    
     q = clip(q + sig.*frana(param.F, x));
     p_old = p;
     p1 = frsyn(param.F, q);
     p1 = p1(1:param.L);
     p = projection(p-zeta*p1, y, param.w);
     x = p + param.rho*(p - p_old);

     SDR(i) = 20*log10(norm(in,2)./norm(in-p, 2));

end

