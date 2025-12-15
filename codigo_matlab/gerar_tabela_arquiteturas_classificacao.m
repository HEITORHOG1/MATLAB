% gerar_tabela_arquiteturas_classificacao.m - Generate Table 2: Model Architecture Details
%
% This script generates Table 2 for the classification article showing:
% - Parameters, layers, input size for each model
% - Pre-training dataset information
% - Modifications for 4-class classification
%
% Requirements: 7.4
% Task: 9.2

function sucesso = gerar_tabela_arquiteturas_classificacao()
    fprintf('\n========================================================================\n');
    fprintf('GENERATING TABLE 2: MODEL ARCHITECTURE DETAILS\n');
    fprintf('========================================================================\n\n');
    
    try
        % Define model architectures
        models = {
            'ResNet50', '~25M', '50', '224×224', 'ImageNet (1.2M images)', 'Residual connections', 'Final FC layer → 4 classes';
            'EfficientNet-B0', '~5M', '237', '224×224', 'ImageNet (1.2M images)', 'Compound scaling', 'Final FC layer → 4 classes';
            'Custom CNN', '~2M', '12', '224×224', 'None (trained from scratch)', 'Lightweight design', '4 conv blocks + 2 FC layers'
        };
        
        fprintf('Model Architecture Summary:\n');
        fprintf('---------------------------\n');
        for i = 1:size(models, 1)
            fprintf('%s:\n', models{i,1});
            fprintf('  Parameters: %s\n', models{i,2});
            fprintf('  Depth: %s layers\n', models{i,3});
            fprintf('  Input Size: %s\n', models{i,4});
            fprintf('  Pre-training: %s\n', models{i,5});
            fprintf('  Key Feature: %s\n', models{i,6});
            fprintf('  Modification: %s\n\n', models{i,7});
        end
        
        % Generate LaTeX table
        fprintf('Generating LaTeX table...\n');
        
        latex = sprintf('\\begin{table}[htbp]\n');
        latex = [latex sprintf('\\caption{Model Architecture Characteristics for 4-Class Corrosion Classification}\n')];
        latex = [latex sprintf('\\label{tab:model_architectures_classification}\n')];
        latex = [latex sprintf('\\centering\n')];
        latex = [latex sprintf('\\small\n')];
        latex = [latex sprintf('\\renewcommand{\\arraystretch}{1.25}\n')];
        latex = [latex sprintf('\\begin{tabular}{lccccl}\n')];
        latex = [latex sprintf('\\hline\\hline\n')];
        latex = [latex sprintf('\\textbf{Model} & \\textbf{Parameters} & \\textbf{Depth} & \\textbf{Input Size} & \\textbf{Pre-training} & \\textbf{Key Feature} \\\\\n')];
        latex = [latex sprintf('\\hline\n')];
        latex = [latex sprintf('ResNet50 & $\\sim$25M & 50 & $224 \\times 224$ & ImageNet & Residual connections \\\\\n')];
        latex = [latex sprintf('EfficientNet-B0 & $\\sim$5M & 237 & $224 \\times 224$ & ImageNet & Compound scaling \\\\\n')];
        latex = [latex sprintf('Custom CNN & $\\sim$2M & 12 & $224 \\times 224$ & None & Lightweight design \\\\\n')];
        latex = [latex sprintf('\\hline\\hline\n')];
        latex = [latex sprintf('\\end{tabular}\n')];
        latex = [latex sprintf('\\normalsize\n')];
        latex = [latex sprintf('\\vspace{0.2cm}\n')];
        latex = [latex sprintf('\\\\\\textit{Note: All models modified with final fully connected layer outputting 4 classes}\n')];
        latex = [latex sprintf('\\\\\\textit{for hierarchical severity classification (No corrosion, Light, Moderate, Severe).}\n')];
        latex = [latex sprintf('\\end{table}\n')];
        
        % Create output directory
        if ~exist('tabelas_classificacao', 'dir')
            mkdir('tabelas_classificacao');
        end
        
        % Save LaTeX table
        outputFile = fullfile('tabelas_classificacao', 'tabela_arquiteturas_modelos.tex');
        fid = fopen(outputFile, 'w', 'n', 'UTF-8');
        fprintf(fid, '%s', latex);
        fclose(fid);
        
        fprintf('✓ LaTeX table saved: %s\n', outputFile);
        
        % Save data to MAT file
        dataFile = fullfile('tabelas_classificacao', 'tabela_arquiteturas_modelos_dados.mat');
        save(dataFile, 'models');
        
        fprintf('✓ Data saved: %s\n', dataFile);
        
        % Generate text report
        reportFile = fullfile('tabelas_classificacao', 'tabela_arquiteturas_modelos_relatorio.txt');
        fid = fopen(reportFile, 'w', 'n', 'UTF-8');
        fprintf(fid, 'MODEL ARCHITECTURE DETAILS REPORT\n');
        fprintf(fid, '==================================\n\n');
        fprintf(fid, 'Generated: %s\n\n', datestr(now));
        fprintf(fid, 'ARCHITECTURE COMPARISON:\n');
        fprintf(fid, '------------------------\n\n');
        for i = 1:size(models, 1)
            fprintf(fid, '%d. %s\n', i, models{i,1});
            fprintf(fid, '   Parameters:    %s\n', models{i,2});
            fprintf(fid, '   Depth:         %s layers\n', models{i,3});
            fprintf(fid, '   Input Size:    %s pixels\n', models{i,4});
            fprintf(fid, '   Pre-training:  %s\n', models{i,5});
            fprintf(fid, '   Key Feature:   %s\n', models{i,6});
            fprintf(fid, '   Modification:  %s\n\n', models{i,7});
        end
        fprintf(fid, 'DESIGN RATIONALE:\n');
        fprintf(fid, '-----------------\n');
        fprintf(fid, '- ResNet50: Deep architecture with residual connections for learning complex features\n');
        fprintf(fid, '- EfficientNet-B0: Balanced architecture optimizing depth, width, and resolution\n');
        fprintf(fid, '- Custom CNN: Lightweight design for resource-constrained deployment\n\n');
        fprintf(fid, 'All models adapted for 4-class hierarchical classification:\n');
        fprintf(fid, '  Class 0: No corrosion (0%% corroded area)\n');
        fprintf(fid, '  Class 1: Light corrosion (<10%% corroded area)\n');
        fprintf(fid, '  Class 2: Moderate corrosion (10-30%% corroded area)\n');
        fprintf(fid, '  Class 3: Severe corrosion (>30%% corroded area)\n');
        fclose(fid);
        
        fprintf('✓ Report saved: %s\n', reportFile);
        
        fprintf('\n========================================================================\n');
        fprintf('✓ TABLE 2 GENERATED SUCCESSFULLY!\n');
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
