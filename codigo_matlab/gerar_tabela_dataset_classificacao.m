% gerar_tabela_dataset_classificacao.m - Generate Table 1: Dataset Statistics
%
% This script generates Table 1 for the classification article showing:
% - Total images and distribution across 4 classes
% - Train/val/test split sizes
% - Class balance metrics
%
% Requirements: 7.4
% Task: 9.1

function sucesso = gerar_tabela_dataset_classificacao()
    fprintf('\n========================================================================\n');
    fprintf('GENERATING TABLE 1: DATASET STATISTICS (4-CLASS CLASSIFICATION)\n');
    fprintf('========================================================================\n\n');
    
    try
        % Check if labels file exists
        labelsFile = 'output/classification/labels/classification_labels.csv';
        if ~exist(labelsFile, 'file')
            error('Labels file not found: %s\nPlease run executar_classificacao first.', labelsFile);
        end
        
        % Load labels
        fprintf('Loading classification labels...\n');
        labels = readtable(labelsFile);
        
        % Extract class information (4 classes: 0, 1, 2, 3)
        classes = labels.SeverityClass;
        
        % Count total images per class
        class0_total = sum(classes == 0);
        class1_total = sum(classes == 1);
        class2_total = sum(classes == 2);
        class3_total = sum(classes == 3);
        total_images = length(classes);
        
        % Calculate percentages
        class0_pct = (class0_total / total_images) * 100;
        class1_pct = (class1_total / total_images) * 100;
        class2_pct = (class2_total / total_images) * 100;
        class3_pct = (class3_total / total_images) * 100;
        
        % Calculate train/val/test splits (70/15/15)
        class0_train = round(class0_total * 0.70);
        class0_val = round(class0_total * 0.15);
        class0_test = class0_total - class0_train - class0_val;
        
        class1_train = round(class1_total * 0.70);
        class1_val = round(class1_total * 0.15);
        class1_test = class1_total - class1_train - class1_val;
        
        class2_train = round(class2_total * 0.70);
        class2_val = round(class2_total * 0.15);
        class2_test = class2_total - class2_train - class2_val;
        
        class3_train = round(class3_total * 0.70);
        class3_val = round(class3_total * 0.15);
        class3_test = class3_total - class3_train - class3_val;
        
        total_train = class0_train + class1_train + class2_train + class3_train;
        total_val = class0_val + class1_val + class2_val + class3_val;
        total_test = class0_test + class1_test + class2_test + class3_test;
        
        % Display statistics
        fprintf('\nDataset Statistics:\n');
        fprintf('------------------\n');
        fprintf('Class 0 (No corrosion):     %3d images (%.1f%%)\n', class0_total, class0_pct);
        fprintf('Class 1 (Light <10%%):       %3d images (%.1f%%)\n', class1_total, class1_pct);
        fprintf('Class 2 (Moderate 10-30%%):  %3d images (%.1f%%)\n', class2_total, class2_pct);
        fprintf('Class 3 (Severe >30%%):      %3d images (%.1f%%)\n', class3_total, class3_pct);
        fprintf('Total:                      %3d images\n\n', total_images);
        
        fprintf('Data Splits:\n');
        fprintf('------------\n');
        fprintf('Training:   %3d images (70%%)\n', total_train);
        fprintf('Validation: %3d images (15%%)\n', total_val);
        fprintf('Test:       %3d images (15%%)\n\n', total_test);
        
        % Generate LaTeX table
        fprintf('Generating LaTeX table...\n');
        
        latex = sprintf('\\begin{table}[htbp]\n');
        latex = [latex sprintf('\\caption{Dataset Statistics and Class Distribution for Hierarchical 4-Class Classification}\n')];
        latex = [latex sprintf('\\label{tab:dataset_statistics_classification}\n')];
        latex = [latex sprintf('\\centering\n')];
        latex = [latex sprintf('\\small\n')];
        latex = [latex sprintf('\\renewcommand{\\arraystretch}{1.25}\n')];
        latex = [latex sprintf('\\begin{tabular}{lcccccc}\n')];
        latex = [latex sprintf('\\hline\\hline\n')];
        latex = [latex sprintf('\\textbf{Severity Class} & \\textbf{Corroded Area} & \\textbf{Train} & \\textbf{Val} & \\textbf{Test} & \\textbf{Total} & \\textbf{\\%%} \\\\\n')];
        latex = [latex sprintf('\\hline\n')];
        latex = [latex sprintf('Class 0 (No corrosion) & $P_c = 0\\%%$ & %d & %d & %d & %d & %.1f\\%% \\\\\n', ...
            class0_train, class0_val, class0_test, class0_total, class0_pct)];
        latex = [latex sprintf('Class 1 (Light) & $P_c < 10\\%%$ & %d & %d & %d & %d & %.1f\\%% \\\\\n', ...
            class1_train, class1_val, class1_test, class1_total, class1_pct)];
        latex = [latex sprintf('Class 2 (Moderate) & $10\\%% \\leq P_c < 30\\%%$ & %d & %d & %d & %d & %.1f\\%% \\\\\n', ...
            class2_train, class2_val, class2_test, class2_total, class2_pct)];
        latex = [latex sprintf('Class 3 (Severe) & $P_c \\geq 30\\%%$ & %d & %d & %d & %d & %.1f\\%% \\\\\n', ...
            class3_train, class3_val, class3_test, class3_total, class3_pct)];
        latex = [latex sprintf('\\hline\n')];
        latex = [latex sprintf('\\textbf{Total} & --- & \\textbf{%d} & \\textbf{%d} & \\textbf{%d} & \\textbf{%d} & \\textbf{100.0\\%%} \\\\\n', ...
            total_train, total_val, total_test, total_images)];
        latex = [latex sprintf('\\hline\\hline\n')];
        latex = [latex sprintf('\\end{tabular}\n')];
        latex = [latex sprintf('\\normalsize\n')];
        latex = [latex sprintf('\\end{table}\n')];
        
        % Create output directory
        if ~exist('tabelas_classificacao', 'dir')
            mkdir('tabelas_classificacao');
        end
        
        % Save LaTeX table
        outputFile = fullfile('tabelas_classificacao', 'tabela_dataset_estatisticas.tex');
        fid = fopen(outputFile, 'w', 'n', 'UTF-8');
        fprintf(fid, '%s', latex);
        fclose(fid);
        
        fprintf('✓ LaTeX table saved: %s\n', outputFile);
        
        % Save data to MAT file
        dataFile = fullfile('tabelas_classificacao', 'tabela_dataset_estatisticas_dados.mat');
        save(dataFile, 'class0_total', 'class1_total', 'class2_total', 'class3_total', ...
            'total_images', 'class0_pct', 'class1_pct', 'class2_pct', 'class3_pct', ...
            'class0_train', 'class0_val', 'class0_test', ...
            'class1_train', 'class1_val', 'class1_test', ...
            'class2_train', 'class2_val', 'class2_test', ...
            'class3_train', 'class3_val', 'class3_test', ...
            'total_train', 'total_val', 'total_test');
        
        fprintf('✓ Data saved: %s\n', dataFile);
        
        % Generate text report
        reportFile = fullfile('tabelas_classificacao', 'tabela_dataset_estatisticas_relatorio.txt');
        fid = fopen(reportFile, 'w', 'n', 'UTF-8');
        fprintf(fid, 'DATASET STATISTICS REPORT - 4-CLASS CLASSIFICATION\n');
        fprintf(fid, '==================================================\n\n');
        fprintf(fid, 'Generated: %s\n\n', datestr(now));
        fprintf(fid, 'CLASS DISTRIBUTION:\n');
        fprintf(fid, '-------------------\n');
        fprintf(fid, 'Class 0 (No corrosion, 0%%):        %3d images (%.1f%%)\n', class0_total, class0_pct);
        fprintf(fid, 'Class 1 (Light, <10%%):             %3d images (%.1f%%)\n', class1_total, class1_pct);
        fprintf(fid, 'Class 2 (Moderate, 10-30%%):        %3d images (%.1f%%)\n', class2_total, class2_pct);
        fprintf(fid, 'Class 3 (Severe, >30%%):            %3d images (%.1f%%)\n', class3_total, class3_pct);
        fprintf(fid, 'Total:                              %3d images\n\n', total_images);
        fprintf(fid, 'DATA SPLITS (Stratified):\n');
        fprintf(fid, '-------------------------\n');
        fprintf(fid, 'Training set:   %3d images (70%%)\n', total_train);
        fprintf(fid, 'Validation set: %3d images (15%%)\n', total_val);
        fprintf(fid, 'Test set:       %3d images (15%%)\n\n', total_test);
        fprintf(fid, 'PER-CLASS SPLITS:\n');
        fprintf(fid, '-----------------\n');
        fprintf(fid, 'Class 0: Train=%d, Val=%d, Test=%d\n', class0_train, class0_val, class0_test);
        fprintf(fid, 'Class 1: Train=%d, Val=%d, Test=%d\n', class1_train, class1_val, class1_test);
        fprintf(fid, 'Class 2: Train=%d, Val=%d, Test=%d\n', class2_train, class2_val, class2_test);
        fprintf(fid, 'Class 3: Train=%d, Val=%d, Test=%d\n', class3_train, class3_val, class3_test);
        fclose(fid);
        
        fprintf('✓ Report saved: %s\n', reportFile);
        
        fprintf('\n========================================================================\n');
        fprintf('✓ TABLE 1 GENERATED SUCCESSFULLY!\n');
        fprintf('========================================================================\n');
        fprintf('Files created:\n');
        fprintf('  - %s\n', outputFile);
        fprintf('  - %s\n', dataFile);
        fprintf('  - %s\n', reportFile);
        fprintf('\n');
        
        sucesso = true;
        
    catch ME
        fprintf('\n❌ ERROR: %s\n', ME.message);
        fprintf('Stack trace:\n');
        for i = 1:length(ME.stack)
            fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        sucesso = false;
    end
end
