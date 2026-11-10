% plot_nutrients.m
% Graph 1: Nitrogen and phosphorus inputs to the Baltic Proper, 1995-2023
%
% Data: HELCOM (2026). Inputs of nutrients to the sub-basins (2023).
% Values are normalized total inputs (waterborne + airborne), tonnes per year.
% "Normalized" means HELCOM adjusted them to remove the effect of wet and dry years.

clear; close all;

%% 1. Find the project folders (works no matter which folder MATLAB is in)
scriptDir  = fileparts(mfilename('fullpath'));   % ...\Baltic-Sea-Hypoxia\scripts
projectDir = fileparts(scriptDir);               % ...\Baltic-Sea-Hypoxia
dataFile   = fullfile(projectDir, 'data', 'processed', 'nutrient_inputs_normalized.csv');
figDir     = fullfile(projectDir, 'figures');

if ~exist(figDir, 'dir')
    mkdir(figDir);    % creates the figures folder if it doesn't exist yet
end

%% 2. Load the data
T = readtable(dataFile);

year = T.year;
N    = T.TN_BAP_tonnes / 1000;   % nitrogen, converted to thousand tonnes
P    = T.TP_BAP_tonnes / 1000;   % phosphorus, converted to thousand tonnes

% HELCOM maximum allowable inputs (MAI) for the Baltic Proper (Baltic Sea Action Plan 2021)
N_target = 325000 / 1000;
P_target = 7360   / 1000;

%% 3. Make the figure (two panels, one above the other)
fig = figure('Color', 'w', 'Position', [100 100 800 650]);
try
    theme(fig, 'light');   % keep a white background even if MATLAB is in dark mode
catch
    % older MATLAB versions have no dark mode, so nothing to change
end
tl  = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

blue   = [0.00 0.45 0.74];
orange = [0.85 0.33 0.10];
grey   = [0.40 0.40 0.40];

% --- Top panel: nitrogen
nexttile
plot(year, N, '-o', 'LineWidth', 1.8, 'MarkerSize', 4, ...
     'Color', blue, 'MarkerFaceColor', blue);
hold on
yline(N_target, '--', 'HELCOM target', 'Color', grey, 'LineWidth', 1.2, ...
      'LabelHorizontalAlignment', 'left');
hold off
ylabel('Nitrogen (thousand t/yr)');
title('Total nitrogen');
grid on
xlim([1994 2024]);
ylim([0 max(N) * 1.1]);

% --- Bottom panel: phosphorus
nexttile
plot(year, P, '-o', 'LineWidth', 1.8, 'MarkerSize', 4, ...
     'Color', orange, 'MarkerFaceColor', orange);
hold on
yline(P_target, '--', 'HELCOM target', 'Color', grey, 'LineWidth', 1.2, ...
      'LabelHorizontalAlignment', 'left');
hold off
xlabel('Year');
ylabel('Phosphorus (thousand t/yr)');
title('Total phosphorus');
grid on
xlim([1994 2024]);
ylim([0 max(P) * 1.1]);

% Overall title
title(tl, 'Nutrient inputs to the Baltic Proper, 1995-2023', 'FontWeight', 'bold');

%% 4. Save the figure as a PNG for the README
outFile = fullfile(figDir, 'nutrient_trend.png');
exportgraphics(fig, outFile, 'Resolution', 300);
disp(['Saved: ' outFile]);
