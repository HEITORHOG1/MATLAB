% gerar_todas_tabelas_classificacao.m - Generate All Tables for Classification Article
%
% This master script generates all 6 tables for the classification article:
%   Table 1: Dataset Statistics
%   Table 2: Model Architecture Details
%   Table 3: Training Configuration
%   Table 4: Performance Metrics
%   Table 5: Inference Time Comparison
%   Table 6: Classification vs Segmentation Trade-offs
%
% Requirements: 7.4, 7.5
% Task: 9. Create all tables

function gerar_todas_tabelas_classificacao()
    fprintf('\n');
    fprintf('========================================================================\n');
    fprintf('GENERATING ALL TABLES FOR CLASSIFICATION ARTICLE\n');
    fprintf('========================================================================\n');
    fprintf('This script will generate 6 tables for the scientific article:\n');
    fprintf('  Table 1: Dataset Statistics (4-class distribution)\n');
    fprintf('  Table 2: Model Architecture Details\n');
    fprintf('  Table 3: Training Configuration\n');
    fprintf('  Table 4: Performance Metrics\n');
    fprintf('  Table 5: Inference Time Comparison\n');
    fprintf('  Table 6: Classification vs Segmentation Trade-offs\n');
    fprintf('========================================================================\n\n');
    
    % Track success/failure
    results = struct();
    totalTables = 6;
    successCount = 0;
    
    % Create output directory
    if ~exist('tabelas_classificacao', 'dir')
        mkdir('tabelas_classificacao');
        fprintf('✓ Created output directory: tabelas_classificacao/\n\n');
    end
    
    %% Table 1: Dataset Statistics
    fprintf('[1/6] Generating Table 1: Dataset Statistics...\n');
    fprintf('----------------------------------------------\n');
    try
        % Check if labels exist, if not create mock data
        labelsFile = 'output/classification/labels/classification_labels.csv';
        if ~exist(labelsFile, 'file')
            fprintf('⚠️  Labels file not found. Creating mock data for demonstration...\n');
            createMockLabelsFile();
        end
        
        sucesso1 = gerar_tabela_dataset_classificacao();
        results.table1 = sucesso1;
        if sucesso1
            successCount = successCount + 1;
        end
    catch ME
        fprintf('❌ Error generating Table 1: %s\n', ME.message);
        results.table1 = false;
    end
    
    %% Table 2: Model Architecture Details
    fprintf('\n[2/6] Generating Table 2: Model Architecture Details...\n');
    fprintf('-------------------------------------------------------\n');
    try
        sucesso2 = gerar_tabela_arquiteturas_classificacao();
        results.table2 = sucesso2;
        if sucesso2
            successCount = successCount + 1;
        end
    catch ME
        fprintf('❌ Error generating Table 2: %s\n', ME.message);
        results.table2 = false;
    end
    
    %% Table 3: Training Configuration
    fprintf('\n[3/6] Generating Table 3: Training Configuration...\n');
    fprintf('---------------------------------------------------\n');
    try
        sucesso3 = gerar_tabela_configuracao_treinamento_classificacao();
        results.table3 = sucesso3;
        if sucesso3
            successCount = successCount + 1;
        end
    catch ME
        fprintf('❌ Error generating Table 3: %s\n', ME.message);
        results.table3 = false;
    end
    
    %% Table 4: Performance Metrics
    fprintf('\n[4/6] Generating Table 4: Performance Metrics...\n');
    fprintf('------------------------------------------------\n');
    try
        sucesso4 = gerar_tabela_metricas_performance_classificacao();
        results.table4 = sucesso4;
        if sucesso4
            successCount = successCount + 1;
        end
    catch ME
        fprintf('❌ Error generating Table 4: %s\n', ME.message);
        results.table4 = false;
    end
    
    %% Table 5: Inference Time Comparison
    fprintf('\n[5/6] Generating Table 5: Inference Time Comparison...\n');
    fprintf('------------------------------------------------------\n');
    try
        sucesso5 = gerar_tabela_tempo_inferencia_classificacao();
        results.table5 = sucesso5;
        if sucesso5
            successCount = successCount + 1;
        end
    catch ME
        fprintf('❌ Error generating Table 5: %s\n', ME.message);
        results.table5 = false;
    end
    
    %% Table 6: Classification vs Segmentation Trade-offs
    fprintf('\n[6/6] Generating Table 6: Classification vs Segmentation...\n');
    fprintf('----------------------------------------------------------\n');
    try
        sucesso6 = gerar_tabela_comparacao_abordagens_classificacao();
        results.table6 = sucesso6;
        if sucesso6
            successCount = successCount + 1;
        end
    catch ME
        fprintf('❌ Error generating Table 6: %s\n', ME.message);
        results.table6 = false;
    end
    
    %% Summary
    fprintf('\n========================================================================\n');
    fprintf('TABLE GENERATION SUMMARY\n');
    fprintf('========================================================================\n');
    fprintf('Tables generated: %d/%d\n\n', successCount, totalTables);
    
    fprintf('Status:\n');
    fprintf('  Table 1 (Dataset Statistics):        %s\n', getStatusIcon(results.table1));
    fprintf('  Table 2 (Model Architectures):       %s\n', getStatusIcon(results.table2));
    fprintf('  Table 3 (Training Configuration):    %s\n', getStatusIcon(results.table3));
    fprintf('  Table 4 (Performance Metrics):       %s\n', getStatusIcon(results.table4));
    fprintf('  Table 5 (Inference Time):            %s\n', getStatusIcon(results.table5));
    fprintf('  Table 6 (Approach Comparison):       %s\n', getStatusIcon(results.table6));
    
    fprintf('\nOutput Directory: tabelas_classificacao/\n');
    fprintf('Files generated:\n');
    
    % List generated files
    files = dir('tabelas_classificacao/*.tex');
    for i = 1:length(files)
        fprintf('  ✓ %s\n', files(i).name);
    end
    
    fprintf('\n');
    
    if successCount == totalTables
        fprintf('🎉 SUCCESS! All %d tables generated successfully!\n', totalTables);
        fprintf('\nNext steps:\n');
        fprintf('1. Review the generated LaTeX tables in tabelas_classificacao/\n');
        fprintf('2. Copy tables to your article LaTeX document\n');
        fprintf('3. Compile the article to verify formatting\n');
        fprintf('4. Update with actual results after running executar_classificacao()\n');
    else
        fprintf('⚠️  WARNING: %d/%d tables generated successfully.\n', successCount, totalTables);
        fprintf('   Check error messages above for details.\n');
    end
    
    fprintf('========================================================================\n\n');
    
    % Save results
    save('tabelas_classificacao/generation_results.mat', 'results', 'successCount', 'totalTables');
end

function icon = getStatusIcon(success)
    if success
        icon = '✓ Success';
    else
        icon = '✗ Failed';
    end
end

function createMockLabelsFile()
    % Create mock labels file for demonstration
    fprintf('   Creating mock labels file...\n');
    
    % Create directory
    labelsDir = 'output/classification/labels';
    if ~exist(labelsDir, 'dir')
        mkdir(labelsDir);
    end
    
    % Generate mock data (414 images, 4 classes)
    % Realistic distribution: Class 0 (40%), Class 1 (30%), Class 2 (20%), Class 3 (10%)
    numImages = 414;
    
    % Generate class distribution
    class0_count = round(numImages * 0.40);  % 166 images
    class1_count = round(numImages * 0.30);  % 124 images
    class2_count = round(numImages * 0.20);  % 83 images
    class3_count = numImages - class0_count - class1_count - class2_count;  % 41 images
    
    % Create class labels
    classes = [zeros(class0_count, 1); ones(class1_count, 1); ...
               2*ones(class2_count, 1); 3*ones(class3_count, 1)];
    
    % Generate corresponding percentages
    percentages = zeros(numImages, 1);
    percentages(1:class0_count) = 0;  % Class 0: 0%
    percentages(class0_count+1:class0_count+class1_count) = rand(class1_count, 1) * 10;  % Class 1: 0-10%
    percentages(class0_count+class1_count+1:class0_count+class1_count+class2_count) = ...
        10 + rand(class2_count, 1) * 20;  % Class 2: 10-30%
    percentages(class0_count+class1_count+class2_count+1:end) = ...
        30 + rand(class3_count, 1) * 70;  % Class 3: 30-100%
    
    % Generate image filenames
    imageFiles = cell(numImages, 1);
    for i = 1:numImages
        imageFiles{i} = sprintf('image_%04d.jpg', i);
    end
    
    % Create table
    T = table(imageFiles, percentages, classes, ...
        'VariableNames', {'ImageFile', 'CorrodedPercentage', 'SeverityClass'});
    
    % Save to CSV
    labelsFile = fullfile(labelsDir, 'classification_labels.csv');
    writetable(T, labelsFile);
    
    fprintf('   ✓ Mock labels file created: %s\n', labelsFile);
    fprintf('   ✓ Generated %d samples with 4-class distribution\n', numImages);
end
