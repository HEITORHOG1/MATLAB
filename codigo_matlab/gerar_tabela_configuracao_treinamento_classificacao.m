% gerar_tabela_configuracao_treinamento_classificacao.m - Generate Table 3: Training Configuration
%
% This script generates Table 3 for the classification article showing:
% - Hyperparameters for all models
% - Data augmentation settings
% - Hardware specifications
%
% Requirements: 7.4
% Task: 9.3

function sucesso = gerar_tabela_configuracao_treinamento_classificacao()
    fprintf('\n========================================================================\n');
    fprintf('GENERATING TABLE 3: TRAINING CONFIGURATION\n');
    fprintf('========================================================================\n\n');
    
    try
        % Define training configuration
        config = {
            'Optimizer', 'Adam';
            'Learning Rate (from scratch)', '$1 \\times 10^{-4}$';
            'Learning Rate (transfer learning)', '$1 \\times 10^{-5}$';
            'Mini-batch Size', '32';
            'Maximum Epochs', '100';
            'Early Stopping Patience', '10 epochs';
            'Loss Function', 'Categorical Cross-Entropy';
            'Class Weighting', 'Inverse Frequency';
            'Train/Val/Test Split', '70\\%/15\\%/15\\%';
            'Input Image Size', '$224 \\times 224$ pixels';
            'Data Augmentation', 'Enabled (5 techniques)';
            'Hardware', 'NVIDIA RTX 3060 (12 GB)';
            'Software', 'MATLAB R2023b';
            'Deep Learning Toolbox', 'Version 14.6'
        };
        
        % Define augmentation techniques
        augmentation = {
            'Horizontal Flip', '50\\% probability';
            'Vertical Flip', '50\\% probability';
            'Rotation', '$\\pm 15^\\circ$';
            'Brightness Adjustment', '$\\pm 20\\%$';
            'Contrast Adjustment', '$\\pm 20\\%$'
        };
        
        fprintf('Training Configuration Summary:\n');
        fprintf('-------------------------------\n');
        for i = 1:size(config, 1)
            fprintf('%s: %s\n', config{i,1}, strrep(config{i,2}, '\\', ''));
        end
        fprintf('\nData Augmentation Techniques:\n');
        for i = 1:size(augmentation, 1)
            fprintf('  %s: %s\n', augmentation{i,1}, strrep(augmentation{i,2}, '\\', ''));
        end
        fprintf('\n');
        
        % Generate LaTeX table
        fprintf('Generating LaTeX table...\n');
        
        latex = sprintf('\\begin{table}[htbp]\n');
        latex = [latex sprintf('\\caption{Training Configuration Parameters for 4-Class Classification Models}\n')];
        latex = [latex sprintf('\\label{tab:training_config_classification}\n')];
        latex = [latex sprintf('\\centering\n')];
        latex = [latex sprintf('\\small\n')];
        latex = [latex sprintf('\\renewcommand{\\arraystretch}{1.25}\n')];
        latex = [latex sprintf('\\begin{tabular}{ll}\n')];
        latex = [latex sprintf('\\hline\\hline\n')];
        latex = [latex sprintf('\\textbf{Parameter} & \\textbf{Value} \\\\\n')];
        latex = [latex sprintf('\\hline\n')];
        
        % Add configuration parameters
        for i = 1:size(config, 1)
            latex = [latex sprintf('%s & %s \\\\\n', config{i,1}, config{i,2})];
        end
        
        latex = [latex sprintf('\\hline\n')];
        latex = [latex sprintf('\\multicolumn{2}{l}{\\textbf{Data Augmentation Techniques:}} \\\\\n')];
        
        % Add augmentation techniques
        for i = 1:size(augmentation, 1)
            latex = [latex sprintf('\\quad %s & %s \\\\\n', augmentation{i,1}, augmentation{i,2})];
        end
        
        latex = [latex sprintf('\\hline\\hline\n')];
        latex = [latex sprintf('\\end{tabular}\n')];
        latex = [latex sprintf('\\normalsize\n')];
        latex = [latex sprintf('\\end{table}\n')];
        
        % Create output directory
        if ~exist('tabelas_classificacao', 'dir')
            mkdir('tabelas_classificacao');
        end
        
        % Save LaTeX table
        outputFile = fullfile('tabelas_classificacao', 'tabela_configuracao_treinamento.tex');
        fid = fopen(outputFile, 'w', 'n', 'UTF-8');
        fprintf(fid, '%s', latex);
        fclose(fid);
        
        fprintf('✓ LaTeX table saved: %s\n', outputFile);
        
        % Save data to MAT file
        dataFile = fullfile('tabelas_classificacao', 'tabela_configuracao_treinamento_dados.mat');
        save(dataFile, 'config', 'augmentation');
        
        fprintf('✓ Data saved: %s\n', dataFile);
        
        % Generate text report
        reportFile = fullfile('tabelas_classificacao', 'tabela_configuracao_treinamento_relatorio.txt');
        fid = fopen(reportFile, 'w', 'n', 'UTF-8');
        fprintf(fid, 'TRAINING CONFIGURATION REPORT\n');
        fprintf(fid, '=============================\n\n');
        fprintf(fid, 'Generated: %s\n\n', datestr(now));
        fprintf(fid, 'HYPERPARAMETERS:\n');
        fprintf(fid, '----------------\n');
        for i = 1:size(config, 1)
            fprintf(fid, '%-35s: %s\n', config{i,1}, strrep(config{i,2}, '\\', ''));
        end
        fprintf(fid, '\nDATA AUGMENTATION:\n');
        fprintf(fid, '------------------\n');
        for i = 1:size(augmentation, 1)
            fprintf(fid, '%-25s: %s\n', augmentation{i,1}, strrep(augmentation{i,2}, '\\', ''));
        end
        fprintf(fid, '\nTRAINING STRATEGY:\n');
        fprintf(fid, '------------------\n');
        fprintf(fid, '- Transfer learning models use lower learning rate to preserve pre-trained features\n');
        fprintf(fid, '- Custom CNN trained from scratch with higher learning rate\n');
        fprintf(fid, '- Early stopping prevents overfitting by monitoring validation loss\n');
        fprintf(fid, '- Class weighting addresses imbalance in 4-class dataset\n');
        fprintf(fid, '- Stratified sampling maintains class proportions across splits\n');
        fprintf(fid, '\nCOMPUTATIONAL RESOURCES:\n');
        fprintf(fid, '------------------------\n');
        fprintf(fid, '- GPU: NVIDIA RTX 3060 with 12 GB VRAM\n');
        fprintf(fid, '- Software: MATLAB R2023b with Deep Learning Toolbox 14.6\n');
        fprintf(fid, '- Training time: ~2-4 hours per model (depending on architecture)\n');
        fclose(fid);
        
        fprintf('✓ Report saved: %s\n', reportFile);
        
        fprintf('\n========================================================================\n');
        fprintf('✓ TABLE 3 GENERATED SUCCESSFULLY!\n');
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
