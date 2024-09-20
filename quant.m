function [xq, delta] = quant(x, w)
% QUANT perfoms mid-riser signal quantization of the input signal with range from -1 to 1.
% Number of the quantization levels is computed according the wordlength.
%
% Input parameters
%       x       vector of input signal
%       w       wordlength
%
% from --> AUDIO_DEQUANT, GITHUB
% Pavel Záviška, Brno University of Technology, 2020

% quantization step
delta = 2^(-w+1); 

% Mid-riser quantization
xq = sign(sign(x)+eps) .* delta .* (floor(abs(x)/delta)+1/2);

% fix the extreme cases for xq > 1 or xq < -1 back to the correct quantization level
xq(xq > 1) = 1 - delta/2;
xq(xq < -1) = -1 + delta/2;


end