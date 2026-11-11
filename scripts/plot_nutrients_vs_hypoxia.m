% plot_nutrients_vs_hypoxia.m
% Graph 3: Do lower nutrient inputs lead to less anoxia, and with what delay?
%
% (a) Phosphorus input to the Baltic Proper and anoxic bottom area, 1995-2024
% (b) Correlation between nutrient inputs L years earlier and the anoxic area,
%     for delays (lags) of 0 to 10 years
%
% Data: data/processed/nutrient_inputs_normalized.csv (HELCOM, 1995-2023)
%       data/processed/oxygen_extent_percent.csv    (SMHI Figure 3, 1960-2024)
% Note: nutrient inputs are for the Baltic Proper only; the anoxic area covers
% the Baltic Proper, Gulf of Finland and Gulf of Riga.

clear; close all;

%% 1. Find the project folders
scriptDir  = fileparts(mfilename('fullpath'));
projectDir = fileparts(scriptDir);
nutFile    = fullfile(projectDir, 'data', 'processed', 'nutrient_inputs_normalized.csv');
oxyFile    = fullfile(projectDir, 'data', 'processed', 'oxygen_extent_percent.csv');
figDir     = fullfile(projectDir, 'figures');

if ~exist(figDir, 'dir')
    mkdir(figDir);
end

%% 2. Load the data
nut = readtable(nutFile);
oxy = readtable(oxyFile);

%% 3. Lag analysis
% For each delay L, pair the anoxic area in year Y with the nutrient input
% in year Y - L, and calculate the correlation coefficient r.
lags = 0:10;
rP = nan(size(lags));
rN = nan(size(lags));
nPairs = nan(size(lags));

for k = 1:numel(lags)
    L = lags(k);
    [found, idx] = ismember(oxy.year - L, nut.year);   % input year = oxygen year - L
    ok = found & ~isnan(oxy.anoxia_percent);

    anox = oxy.anoxia_percent(ok);
    P    = nut.TP_BAP_tonnes(idx(ok));
    N    = nut.TN_BAP_tonnes(idx(ok));

    c = corrcoef(P, anox);  rP(k) = c(1, 2);
    c = corrcoef(N, anox);  rN(k) = c(1, 2);
    nPairs(k) = sum(ok);
end

% Show the results in the Command Window and save them as a table
lagResults = table(lags', nPairs', round(rP', 2), round(rN', 2), ...
    'VariableNames', {'lag_years', 'n_years', 'r_phosphorus', 'r_nitrogen'});
disp(lagResults);
writetable(lagResults, fullfile(projectDir, 'data', 'processed', 'lag_correlation.csv'));

%% 4. Make the figure
fig = figure('Color', 'w', 'Position', [100 100 1250 470]);
try
    theme(fig, 'light');   % keep a white background even if MATLAB is in dark mode
catch
end
tl = tiledlayout(1, 2, 'TileSpacing', 'loose', 'Padding', 'compact');   % 'loose' leaves room between the two panels

orange = [0.85 0.33 0.10];
black  = [0.15 0.15 0.15];
blue   = [0.00 0.45 0.74];

% --- (a) Phosphorus input and anoxic area over time
ax = nexttile;
inPeriod = oxy.year >= 1995;

yyaxis left
plot(nut.year, nut.TP_BAP_tonnes / 1000, '-o', 'LineWidth', 1.8, 'MarkerSize', 4, ...
     'Color', orange, 'MarkerFaceColor', orange);
ylabel('Phosphorus input (thousand t/yr)');
ylim([0 25]);

yyaxis right
plot(oxy.year(inPeriod), oxy.anoxia_percent(inPeriod), '-o', 'LineWidth', 1.8, ...
     'MarkerSize', 4, 'Color', black, 'MarkerFaceColor', 'w');
ylabel('Anoxic bottom area (%)');
ylim([0 25]);

ax.YAxis(1).Color = orange;
ax.YAxis(2).Color = black;
xlabel('Year');
xlim([1994 2025]);
grid on
title('(a) Phosphorus input vs. anoxic area');
legend({'Phosphorus input (Baltic Proper)', 'Anoxic area'}, 'Location', 'northwest');

% --- (b) Correlation at different delays
nexttile
b = bar(lags, [rP; rN]', 'grouped');
b(1).FaceColor = orange;
b(2).FaceColor = blue;
hold on
yline(0, 'k-', 'LineWidth', 1, 'HandleVisibility', 'off');
hold off
xlabel('Delay between input and anoxia (years)');
ylabel('Correlation coefficient (r)');
ylim([-1 1]);
xticks(lags);
grid on
title('(b) Correlation at different delays');
legend({'Phosphorus input', 'Nitrogen input'}, 'Location', 'northeast');

title(tl, 'Nutrient inputs vs. anoxia in the Baltic Sea, 1995-2024', 'FontWeight', 'bold');

%% 5. Save the figure as a PNG for the README
outFile = fullfile(figDir, 'nutrients_vs_hypoxia.png');
exportgraphics(fig, outFile, 'Resolution', 300);
disp(['Saved: ' outFile]);
