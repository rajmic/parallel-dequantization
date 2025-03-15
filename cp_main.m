% Chambolle-Pock sparsity based dequantization
%
% Vojtěch Kovanda
% Brno University of Technology, 2024

% using LTFAT toolbox
ltfatstart

%% input signal
 audiofile = 'test/violin_scales/A_staccato.wav';

 % the audio recordings are divided by instruments in the "test" folder
 
 % for example
 % 'test/violin_scales/A_staccato.wav'
 % 'test/trumpet_scales/A#.wav'
 % 'test/sax_tenor_scales/A#_legato.wav'
 % 'test/sax_alto_scales/D#_staccato.wav'
 % 'test/flute_scales/C_legato.wav'
 % 'test/clarinet_scales/F_legato.wav'

[x, param.fs] = audioread(audiofile);

% signal length
param.L = length(x);

% normalization
maxval = max(abs(x));
x = x/maxval;

%% generate observations y

% setting conversion parameters
param.w = 8;

% quantization
y = quant(x, param.w);

%% settings for proposed algorithm

% frame settings

param.winlen = 2048; % window length
param.wtype = 'hann';  % window type
param.a = param.winlen/4;  % window shift
param.M = 2*param.winlen; % number of frequency channels

% frame construction
param.F = frametight(frame('dgtreal', {param.wtype, param.winlen}, param.a, param.M));
param.F = frameaccel(param.F, param.L);

% algorithm parameters

param.lam = [0.0012 0.000094 0.000032 0.000013 0.0000055 0.0000027 0.0000018 0.0000011 0.0000006 0.0000004 0.0000003 0.0000002 0.0000001]; % different clipping thresholds for different bit depth
param.rho = 1;

%% calling optimization algorithm

param.maxit = 200;
[xcp, SDR_in_time] = cp_alg(y, param, x);

%% evaluation

SDR = max(SDR_in_time);
SDRq = 20*log10(norm(x,2)./norm(x-y, 2));
% [~, ~, ODG] = audioqual(x, xcp, param.fs); 
% [~, ~, ODGq] = audioqual(x, y, param.fs);

fprintf('SDR of the quantized signal is %4.3f dB.\n', SDRq);
fprintf('SDRcp of the reconstructed signal is %4.3f dB.\n', SDR);
% fprintf('ODG of the quantized signal is %4.3f.\n', ODGq);
% fprintf('ODGcp of the reconstructed signal is %4.3f.\n', ODG);
