function proj = projection(x, xq, w)
% PROJECTION perfoms projection of vector x onto the set of feasible
% solutions
%
% input x
% quntized signal xq
% wordlength w
%
% based on PROJ from <-- AUDIO_DEQUAN, GITHUB
% by Pavel Záviška, Brno University of Technology, 2020

delta = 2^(-w+1); 

overstep_above = (x - xq) > delta/2 & xq < 1 - delta/2;
overstep_below = (xq - x) > delta/2 & xq > delta/2 - 1;

proj = x;

    proj(overstep_above) = xq(overstep_above) + delta/2 - eps;
    proj(overstep_below) = xq(overstep_below) - delta/2 + eps;


end