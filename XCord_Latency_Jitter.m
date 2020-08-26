% Script for Detecting Latency between two Files 
% Created by Daniel Braunstein, 08/17/20
% Version 0.0.0
% 
% This script utilizes cross-correlation to detect latency changes over
% time in longer signals

[y, fs] = audioread("12 Time.wav");
[y2, fs2] = audioread("DanteTest2_Time_441.wav");

% % get first 1.5m
% [y, fs] = audioread("12 Time.wav", [1 1500000]);
% [y2, fs2] = audioread("DanteTest2_Time_441.wav", [1 1500000]);

if (fs ~= fs2)
   error('Error. Sample Rate Mismatch. (Line 9)') 
end

y_l = y(:,1); %left channel
y2_l = y2(:, 1);

windowSize = 8192;
hopSize = 1024;
numHops = floor(length(y) / hopSize);

lastHopStart = (hopSize * numHops + 1);
finalWindowLen = lastHopStart + windowSize;
zeroPadLen = finalWindowLen - length(y);

y_l(end+1:finalWindowLen) = 0;
y2_l(end+1:finalWindowLen) = 0;

results = zeros(numHops, 1);


for i = 1:numHops
    y_temp = y_l((1 + ((i - 1) * hopSize)):(windowSize + ((i - 1) * hopSize)));
    y2_temp = y2_l((1 + ((i - 1) * hopSize)):(windowSize + ((i - 1) * hopSize)));
    
    [r2, lags2] = xcorr(y_temp, y2_temp);
    [m2, idx2] = max(r2);
    
    results(i) = -lags2(idx2) / fs * 1000;
end


meanLatency = mean(results);
medianLatency = median(results);

stablePercentage = sum(results(:) == medianLatency) / length(results) * 100;

x = 1:numHops;
hopsToSeconds = x * hopSize / fs;
plot(hopsToSeconds, results);
ylim([-10 250]);
xlabel('Time[s]');
ylabel('Latency[ms]');
% 
% meanLatency
% medianLatency
% stablePercentage