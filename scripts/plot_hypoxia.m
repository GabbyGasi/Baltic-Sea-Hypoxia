% plot_hypoxia.m
% Graph 2: Share of the Baltic seafloor with hypoxia and anoxia, 1960-2024
%
% Data: Hansson, M. & Viktorsson, L. (2025). Oxygen Survey in the Baltic Sea 2024.
%       SMHI Report Oceanography No. 80, Figure 3.
% Yearly values were read from Figure 3 with WebPlotDigitizer
% (accuracy about +/- 1 percentage point).
% Area covered: Baltic Proper, Gulf of Finland and Gulf of Riga, autumn (Aug-Oct).
% Hypoxia = oxygen below 2 ml/l (this area includes the anoxic area).
% Anoxia  = no oxygen left (hydrogen sulphide present).
% 1961 and 1967 are missing in the original data (shown as gaps).

clear; close all;

%% 1. Find the project folders (works no matter which folder MATLAB is in)
scriptDir  = fileparts(mfilename('fullpath'));
projectDir = fileparts(scriptDir);
dataFile   = fullfile(projectDir, 'data', 'processed', 'oxygen_extent_percent.csv');
figDir     = fullfile(projectDir, 'figures');

if ~exist(figDir, 'dir')
    mkdir(figDir);
end

%% 2. Load the data
T = readtable(dataFile);

year = T.year;
hyp  = T.hypoxia_percent;   % % of bottom area with O2 < 2 ml/l
anox = T.anoxia_percent;    % % of bottom area with no O2

%% 3. Make the figure
fig = figure('Color', 'w', 'Position', [100 100 900 500]);
try
    theme(fig, 'light');   % keep a white background even if MATLAB is in dark mode
catch
    % older MATLAB versions have no dark mode, so nothing to change
end

red   = [0.80 0.10 0.10];
black = [0.15 0.15 0.15];
grey  = [0.40 0.40 0.40];

plot(year, hyp, '-o', 'LineWidth', 1.8, 'MarkerSize', 4, ...
     'Color', red, 'MarkerFaceColor', red);
hold on
plot(year, anox, '-o', 'LineWidth', 1.8, 'MarkerSize', 4, ...
     'Color', black, 'MarkerFaceColor', 'w');

% Mark the 1999 regime shift described by SMHI
xline(1999, '--', 'Regime shift (1999)', 'Color', grey, 'LineWidth', 1.2, ...
      'LabelVerticalAlignment', 'top', 'LabelHorizontalAlignment', 'left', ...
      'HandleVisibility', 'off');
hold off

xlabel('Year');
ylabel('Share of bottom area (%)');
title('Seafloor area with low oxygen in the Baltic Sea, 1960-2024');
subtitle('Baltic Proper, Gulf of Finland and Gulf of Riga, autumn (Aug-Oct)');
legend({'Hypoxic (O_2 < 2 ml/l)', 'Anoxic (no O_2, H_2S present)'}, ...
       'Location', 'northwest');
grid on
xlim([1958 2026]);
ylim([0 40]);

%% 4. Save the figure as a PNG for the README
outFile = fullfile(figDir, 'hypoxia_trend.png');
exportgraphics(fig, outFile, 'Resolution', 300);
disp(['Saved: ' outFile]);
