% Dequantization of a signal from two parallel quantized observations 
%
% parallel conversion of two branches giving observations y_1 and y_2
%
%          x
%       ___|___
%      |       |  
%      B     Q_coarse
%     D_k      y_2
%    Q_fine   
%     y_1
%
% B is anti-aliasing filter, D_k is downsampling, Q_fine is fine
% quantization, Q_coarse is coarse quantization
%
% the PEMO-Q audioqual is now inactive
%
% Vojtěch Kovanda
% Brno University of Technology, 2024


% using LTFAT toolbox
ltfatstart


%% input signal
 audiofile = 'test/violin1_1.wav';      % 'violin1_1.wav'
                                        % 'violin2_1.wav'
                                        % 'cello_1.wav'
                                        % 'cello_pizz.wav' 
                                        % 'bass_guitar2.wav' 
                                        % 'Harpsichord.wav' 
                                        % 'trumpet.wav' 
                                        % 'organ.wav'
                                        % 'mix_1. wav'

[x, param.fs] = audioread(audiofile);

% signal length
param.L = length(x);

% normalization
maxval = max(abs(x));
x = x/maxval;

%% generate observations y_1 and y_2

% setting conversion parameters
param.w1 = 16;           % bit depth (bps) of Q_fine
param.w2 = 8;            % bit depth (bps) of Q_coarse
param.k = 4;             % downsampling factor

% load impulse response of B for downsampling factor k = 4 and sampling
% frequency f_s = 48kHz
load("filter_coeffs_6cutoff.mat");
param.B = Num;
param.Bt = flip(param.B);

% first branch

% filtering (using convolution)
y1 = conv(x, param.B);

% signal length after filtering
param.L1 = length(y1);

% quantization
y1 = quant(y1, param.w1);

% downsampling
y1 = y1(1:param.k:end);
y1 = y1(1:floor(param.L1/param.k));

% second branch

% quantization
y2 = quant(x, param.w2);


%% settings for proposed algorithm (CVA)

% frame settings
param.winlen = 2048;            % window length
param.wtype = 'hann';           % window type
param.a = param.winlen/4;       % window shift
param.M = 2*param.winlen;       % number of frequency channels

% frame construction
param.F = frametight(frame('dgtreal', {param.wtype, param.winlen}, param.a, param.M));
param.F = frameaccel(param.F, param.L);

% algorithm parameters
param.lam = [0.0012 0.0012 0.0012 0.0012 0.0012 0.0001 0.00005 0.00002 0.00001 0.000005 0.000001 0.0000005 0.0000001]; % different clipping thresholds for different bit depths of y_2
param.rho = 0.8;
param.tau = 1;
param.sig = 1/2;

% maximal number of iteration
param.maxit = 200;

%% calling optimization algorithm

[xhat, SDR_t] = cv_alg(y1, y2, param, x);

%% evaluation

% SDR of reconstructed signal, SDR(xhat, x)
[SDR, bestit] = max(SDR_t);

% SDR of quantized signal, SDR(y2, x)
SDRq = 20*log10(norm(x,2)./norm(x-y2, 2));

% ODG of reconstructed signal, ODG(x, x)
% [~, ~, ODG] = audioqual(x, xhat, param.fs); 

% ODG of quantized signal, ODG(y2, x)
% [~, ~, ODGq] = audioqual(x, y2, param.fs);

fprintf('SDR of the quantized signal is %4.3f dB.\n', SDRq);
fprintf('SDR of the reconstructed signal is %4.3f dB.\n', SDR);
% fprintf('ODG of the quantized signal is %4.3f.\n', ODGq);
% fprintf('ODG of the reconstructed signal is %4.3f.\n', ODG);

% plot results

figure;
plot(SDR_t);
ylabel('SDR (dB)');
xlabel('number of iteration');