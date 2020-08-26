% Script for Detecting Latency between two Files 
% Created by Daniel Braunstein, 08/13/20
% Version 0.1.0
% 
% This script utilizes cross-correlation to detect latency between 
%   recorded channels
%   e.g. Guitar_DI_01 vs Guitar_Amp_Km84_01
% 
% Usage note: Currently this software only compares like-take-numbers. 
%   Ensure parity between take numbers (e.g. _01 vs _01) otherwise 
%   readings will be inaccurate
%

numChan = 3;    % number of channels for simlutaneous comparison
numTests = 10;  % number of recordings/tests to compare

% Comparison Mode Enumerator sets the following for numChan N
% 0 - Baseline vs variables: compares 1 to 2, 1 to 3,... 1 to N
% 1 - Daisy Chain / succession: compares 1 to 2, 2 to 3,... N-1 to N
COMPARISON_MODE_ENUM = 0;

%------------------------------------
% Channel Names 
%------------------------------------
%   These are the channel / track names the daw uses to name recorded takes 
%   Set these to whatever the 'identical' part of the filename is

%   arrays to hold initial channel names (from daw) and the files
%   associated with them
chanNames = strings(numChan);   
chanFileNames = strings(numTests, numChan);

chanNames(1) = "Solo_Mon_out_18i8_in_1";
chanNames(2) = "Solo_ASIO_In_1_Dante";
chanNames(3) = "Solo_ASIO_In_1_Dante_Ableton_Dante";
% ... chanNames(numChan) = " ";

%------------------------------------
% DAW Suffix
%------------------------------------
%   This is any character the Daw adds to the filenames in recorded takes
%   e.g. for takes "Guitar 1_03.wav" and "Guitar 1_04.wav", this is '_'
dawSuffix = "#";

%-----------------------------------
% Audio FileType
%-----------------------------------
%   Audio fileType to read in. Supported Formats Include:
%   All Platforms:
%       .wav, .ogg, .flac, .au, .aiff, .aif, aifc
%   Win7 (or Later), Macintosh, Linux: 
%       .mp3, .m4a, .mp4
fileType = ".wav";

%-----------------------------------
% Take Number Format
%-----------------------------------
% take number formatting in the daw 
%   e.g. 1,2,3 vs 01, 02, 03
takeNumberFormat = '%02d';

%-----------------------------------
% Print Out
%-----------------------------------
% Boolean to enable console printing
printOut = true;

% Set array of filenames by channel
for f = 1:numTests
    for ch = 1:numChan
        chanFileNames(f, ch) = chanNames(ch) + dawSuffix + ...
            sprintf(takeNumberFormat, f) + fileType;
    end
end

% Create empty results array
results = zeros(numTests, 1);

% Bool as flag to check all channel filepaths are valid
validPaths = true;
file1Valid = true;
file2Valid = true;

% ComparisonModeEnum0
% Run the XCor and get results
if COMPARISON_MODE_ENUM == 0
for n = 1:numTests
    for i = 2:numChan
    
        % Set Incremental Filepath names
        filepath1 = chanFileNames(n, 1);
        filepath2 = chanFileNames(n, i);

        % Check that the first file exists, if so, read in audio
        if exist(filepath1, 'file') == 2
            [y, fs] = audioread(filepath1);
            validPaths = true; %#ok<NASGU>
        else
            validPaths = false; %#ok<NASGU>
            file1Valid = false;
        end

        % Check that second file exists, if so, read in audio
        if exist(filepath2, 'file') == 2
            [y2, fs2] = audioread(filepath2);
            validPaths = true; 
        else
            validPaths = false;
            file2Valid = false; 
        end

        % If both paths (at index) returned valid, run xcorr + save results
        % If either path is invalid, print index as fnf
        if validPaths 
            [r, lags] = xcorr(y, y2);
            [m, idx] = max(r);
            results(n) = -lags(idx) / fs * 1000;
        elseif ~validPaths & ~file1Valid %file 1 is invalid
            fprintf('File "%s" not found for Xcorr with "%s"\n', chanFileNames(n, 1), chanFileNames(n, i));
            results(n) = -1;
        elseif ~validPaths & ~file2Valid %file 2 is invalid
            fprintf('File "%s" not found for Xcorr with "%s"\n', chanFileNames(n, i), chanFileNames(n, 1));
            results(n) = -1;
        else
            fprintf('Files not found: %s, %s\n', chanFileNames(n, 1), chanFileNames(n, i));
            results(n) = -1;
        end

        % if printout is set to TRUE, print successful latency calculation
        if printOut
            if (results(n) ~= -1)
                fprintf('%28s | %42s| latency:   %0.4fms\n', chanFileNames(n, 1),...
                                    chanFileNames(n, i), results(n));
            end
        end
    end
end
elseif COMPARISON_MODE_ENUM == 1
for n = 1:numTests
    for i = 1:numChan-1
    
        % Set Incremental Filepath names
        filepath1 = chanFileNames(n, i);
        filepath2 = chanFileNames(n, i+1);

        % Check that the first file exists, if so, read in audio
        if exist(filepath1, 'file') == 2
            [y, fs] = audioread(filepath1);
            validPaths = true; %#ok<NASGU>
        else
            validPaths = false; %#ok<NASGU>
            file1Valid = false;
        end

        % Check that second file exists, if so, read in audio
        if exist(filepath2, 'file') == 2
            [y2, fs2] = audioread(filepath2);
            validPaths = true; 
        else
            validPaths = false;
            file2Valid = false; 
        end

        % If both paths (at index) returned valid, run xcorr + save results
        % If either path is invalid, print index as fnf
        if validPaths 
            [r, lags] = xcorr(y, y2);
            [m, idx] = max(r);
            results(n) = -lags(idx) / fs * 1000;
        elseif ~validPaths & ~file1Valid %file 1 is invalid
            fprintf('File "%s" not found for Xcorr with "%s"\n', chanFileNames(n, i), chanFileNames(n, i+1));
            results(n) = -1;
        elseif ~validPaths & ~file2Valid %file 2 is invalid
            fprintf('File "%s" not found for Xcorr with "%s"\n', chanFileNames(n, i), chanFileNames(n, i+1));
            results(n) = -1;
        else
            fprintf('Files not found: %s, %s\n', chanFileNames(n, i), chanFileNames(n, i+1));
            results(n) = -1;
        end

        % if printout is set to TRUE, print successful latency calculation
        if printOut
            if (results(n) ~= -1)
                fprintf('%42s | %42s| latency:   %0.4fms\n', chanFileNames(n, i),...
                                    chanFileNames(n, i+1), results(n));
            end
        end
    end
end
end

% results
