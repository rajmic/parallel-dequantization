function [x, SDR] = cv_alg(y1, y2, param, in)
% CV_ALG is the Condat-Vu algorithm solving parallel conversion dequantization
%
% Vojtěch Kovanda
% Brno University of Technology, 2024

lam = param.lam(param.w2 - 3); % setting threshold for clipping

% definition of clip function (result of the Fenchel-Rockafellar conjugate of soft thresholding)
clip = @(x) (sign(x).*min(abs(x), lam));

%% initial values
i = 0; % number of iteration
x = zeros(param.L, 1);
u1 = frana(param.F, y2);
u1 = zeros(size(u1));
u2 = zeros(floor(param.L1/param.k), 1);
u3 = zeros(param.L, 1);
SDR = zeros(param.maxit-1, 1);

%% algorithm
while i < param.maxit

    i = i + 1;
    waitbar(i/param.maxit);
     
     % getting Lm* um
     U1 = frsyn(param.F, u1);
     U1 = U1(1:param.L);
     U3 = u3;
     p = zeros(param.L1,1);
     for n = 1:param.k:param.k*length(u2)
         p(n) = u2((n+param.k-1)/param.k);
     end
     U2 = conv(p,param.Bt);
     U2 = U2(length(param.Bt):end-length(param.Bt)+1);

     x_tild = x - param.tau * (U3+U2+U1);
     x = param.rho * x_tild + (1 - param.rho) * x;

     bL = 2*x_tild-x;

     p1 = u1 + param.sig * frana(param.F, bL);
     u1_tild = clip(p1);
     u1 = param.rho * u1_tild + (1 - param.rho) * u1;
     
     p3 = u3 + param.sig * bL;
     u3_tild = p3 - param.sig * projection(p3/param.sig, y2, param.w2);
     u3 = param.rho * u3_tild + (1 - param.rho) * u3;

     bL = conv(bL, param.B);
     aL = bL(1:param.k:end);
     aL = aL(1:floor(param.L1/param.k));

     p2 = u2 + param.sig * aL;
     u2_tild = p2 - param.sig * projection(p2/param.sig, y1, param.w1);
     u2 = param.rho * u2_tild + (1 - param.rho) * u2;
     
    % SDR through iterations
     SDR(i) = 20*log10(norm(in,2)./norm(in-x, 2));

end


