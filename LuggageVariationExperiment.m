clear; clc;

% Add current directory and all subdirectories to path
addpath(pwd, ...
    fullfile(pwd, 'simulation'), ...
    fullfile(pwd, 'passengers'), ...
    fullfile(pwd, 'boarding'), ...
    fullfile(pwd, 'visualization'), ...
    fullfile(pwd, 'utils'));

% Experiment controls
runs_per_config = 100;
base_seed = 1;
show_visualization = false;
show_progress = true;

% Luggage percentages: 0%, 10%, 20%, ..., 100% (11 values)
luggage_percentages = 0:10:100;
n_luggage_levels = numel(luggage_percentages);

% Boarding strategies to test
strategies = {'back_to_front', ...
              'random', ...
              'outside_in', ...
              'reverse_pyramid', ...
              'half_block_mix', ...
              'steffen'};
n_strategies = numel(strategies);

% Initialize results table: rows = luggage %, columns = strategies
results = zeros(n_luggage_levels, n_strategies);

fprintf('\n=== LUGGAGE VARIATION EXPERIMENT ===\n');
fprintf('Running %d luggage levels x %d strategies x %d runs = %d total runs\n', ...
    n_luggage_levels, n_strategies, runs_per_config, n_luggage_levels * n_strategies * runs_per_config);
fprintf('\n');

% Outer loop: luggage percentages
for lug_idx = 1:n_luggage_levels
    luggage_pct = luggage_percentages(lug_idx);
    luggage_prob = luggage_pct / 100.0;
    
    fprintf('Luggage %3.0f%% | ', luggage_pct);
    
    % Inner loop: strategies
    for strat_idx = 1:n_strategies
        strategy = strategies{strat_idx};
        
        boarding_times = nan(runs_per_config, 1);
        
        % Run simulations for this strategy/luggage combination
        for run_idx = 1:runs_per_config
            seed = base_seed + run_idx - 1;
            params = load_params(seed);
            
            params.show_visu = show_visualization;
            params.boarding_strategy = strategy;
            
            % Set luggage probability for this run
            params.has_luggage = rand(1, params.N) < luggage_prob;
            
            options = struct('verbose', false, 'enable_pauses', show_visualization);
            KPI = run_simulation(params, options);
            
            boarding_times(run_idx) = KPI.boarding_time;
        end
        
        % Calculate mean boarding time for this strategy/luggage combination
        mean_time = mean(boarding_times);
        results(lug_idx, strat_idx) = mean_time;
        
        fprintf('%8.2f ', mean_time);
    end
    fprintf('\n');
end

fprintf('\n=== RESULTS TABLE ===\n\n');

% Create output table
luggage_col = luggage_percentages';
output_table = table(luggage_col, ...
    results(:, 1), results(:, 2), results(:, 3), ...
    results(:, 4), results(:, 5), results(:, 6), ...
    'VariableNames', ['Luggage', strategies]);

disp(output_table);

% Save to CSV file with timestamp
timestamp = datetime('now', 'Format', 'yyyyMMdd_HHmmss');
csv_filename = sprintf('results/luggage_variation_%s.csv', timestamp);
writetable(output_table, csv_filename);

fprintf('\nResults saved to: %s\n', csv_filename);

% Also display in a format easy to copy (like your screenshot)
fprintf('\n=== COPY-PASTE FORMAT ===\n\n');
fprintf('%-12s', 'Luggage');
for i = 1:n_strategies
    % Extract strategy name without '_strategy' suffix for cleaner output
    strat_name = strrep(strategies{i}, '_strategy', '');
    fprintf('%12s', strat_name);
end
fprintf('\n');

for lug_idx = 1:n_luggage_levels
    fprintf('%10.0f%%', luggage_percentages(lug_idx));
    for strat_idx = 1:n_strategies
        fprintf('%12.2f', results(lug_idx, strat_idx));
    end
    fprintf('\n');
end
