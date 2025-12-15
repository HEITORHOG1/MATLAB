function archive = create_publication_outputs()
% CREATE_PUBLICATION_OUTPUTS Organize all publication-ready materials
%
% This script creates a comprehensive publication archive with:
%   - Organized figures in publication directory
%   - Exported LaTeX tables
%   - Results summary document
%   - Supplementary materials archive
%
% Requirements: 9.1, 9.2, 9.3, 9.4, 9.5
%
% Output:
%   archive - Struct containing archive information and paths

    fprintf('=== CREATING PUBLICATION-READY OUTPUTS ===\n\n');
    
    % Initialize archive structure
    archive = struct();
    archive.timestamp = datetime('now');
    archive.status = 'RUNNING';
    
    try
        % Phase 1: Create publication directory structure
        fprintf('Phase 1: Creating publication directory structure...\n');
        pubDir = createPublicationDirectory();
        archive.publicationDir = pubDir;
        fprintf('  ✓ Publication directory created: %s\n', pubDir);
        
        % Phase 2: Organize figures
        fprintf('\nPhase 2: Organizing figures...\n');
        figureInfo = organizeFigures(pubDir);
        archive.figures = figureInfo;
        fprintf('  ✓ Organized %d figures\n', figureInfo.count);
        
        % Phase 3: Export LaTeX tables
        fprintf('\nPhase 3: Exporting LaTeX tables...\n');
        tableInfo = exportLatexTables(pubDir);
        archive.tables = tableInfo;
        fprintf('  ✓ Exported %d LaTeX tables\n', tableInfo.count);
        
        % Phase 4: Generate results summary
        fprintf('\nPhase 4: Generating results summary document...\n');
        summaryPath = generateResultsSummary(pubDir);
        archive.summaryDocument = summaryPath;
        fprintf('  ✓ Results summary created: %s\n', summaryPath);
        
        % Phase 5: Create supplementary materials
        fprintf('\nPhase 5: Creating supplementary materials archive...\n');
        suppPath = createSupplementaryMaterials(pubDir);
        archive.supplementaryMaterials = suppPath;
        fprintf('  ✓ Supplementary materials created: %s\n', suppPath);
        
        % Phase 6: Generate archive README
        fprintf('\nPhase 6: Generating archive documentation...\n');
        readmePath = generateArchiveReadme(pubDir, archive);
        archive.readme = readmePath;
        fprintf('  ✓ Archive README created: %s\n', readmePath);
        
        archive.status = 'COMPLETED';
        
        % Save archive information
        save(fullfile(pubDir, 'archive_info.mat'), 'archive');
        
        fprintf('\n=== PUBLICATION OUTPUTS CREATED SUCCESSFULLY ===\n');
        fprintf('Publication directory: %s\n', pubDir);
        fprintf('Total figures: %d\n', figureInfo.count);
        fprintf('Total tables: %d\n', tableInfo.count);
        
    catch ME
        archive.status = 'FAILED';
        archive.error = ME.message;
        fprintf('\n=== ERROR ===\n');
        fprintf('Publication output creation failed: %s\n', ME.message);
        rethrow(ME);
    end
end

function pubDir = createPublicationDirectory()
    % Create publication directory structure
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    pubDir = sprintf('publication_ready_%s', timestamp);
    
    % Create main directory
    if ~exist(pubDir, 'dir')
        mkdir(pubDir);
    end
    
    % Create subdirectories
    subdirs = {'figures', 'tables', 'supplementary', 'documentation'};
    for i = 1:length(subdirs)
        subdir = fullfile(pubDir, subdirs{i});
        if ~exist(subdir, 'dir')
            mkdir(subdir);
        end
    end
end

function figureInfo = organizeFigures(pubDir)
    % Organize figures from output directory
    figureInfo = struct();
    figureInfo.count = 0;
    figureInfo.files = {};
    
    sourceDir = fullfile('output', 'classification', 'figures');
    targetDir = fullfile(pubDir, 'figures');
    
    if ~exist(sourceDir, 'dir')
        warning('Source figures directory not found: %s', sourceDir);
        return;
    end
    
    % Copy PNG files
    pngFiles = dir(fullfile(sourceDir, '*.png'));
    for i = 1:length(pngFiles)
        sourcePath = fullfile(sourceDir, pngFiles(i).name);
        targetPath = fullfile(targetDir, pngFiles(i).name);
        copyfile(sourcePath, targetPath);
        figureInfo.files{end+1} = pngFiles(i).name;
        figureInfo.count = figureInfo.count + 1;
    end
    
    % Copy PDF files
    pdfFiles = dir(fullfile(sourceDir, '*.pdf'));
    for i = 1:length(pdfFiles)
        sourcePath = fullfile(sourceDir, pdfFiles(i).name);
        targetPath = fullfile(targetDir, pdfFiles(i).name);
        copyfile(sourcePath, targetPath);
        figureInfo.files{end+1} = pdfFiles(i).name;
        figureInfo.count = figureInfo.count + 1;
    end
    
    fprintf('    Copied %d PNG files\n', length(pngFiles));
    fprintf('    Copied %d PDF files\n', length(pdfFiles));
end

function tableInfo = exportLatexTables(pubDir)
    % Export LaTeX tables
    tableInfo = struct();
    tableInfo.count = 0;
    tableInfo.files = {};
    
    sourceDir = fullfile('output', 'classification', 'latex');
    targetDir = fullfile(pubDir, 'tables');
    
    if ~exist(sourceDir, 'dir')
        warning('Source LaTeX directory not found: %s', sourceDir);
        return;
    end
    
    % Copy all .tex files
    texFiles = dir(fullfile(sourceDir, '*.tex'));
    for i = 1:length(texFiles)
        sourcePath = fullfile(sourceDir, texFiles(i).name);
        targetPath = fullfile(targetDir, texFiles(i).name);
        copyfile(sourcePath, targetPath);
        tableInfo.files{end+1} = texFiles(i).name;
        tableInfo.count = tableInfo.count + 1;
    end
    
    fprintf('    Copied %d LaTeX table files\n', length(texFiles));
end

function summaryPath = generateResultsSummary(pubDir)
    % Generate comprehensive results summary document
    summaryPath = fullfile(pubDir, 'RESULTS_SUMMARY.md');
    fid = fopen(summaryPath, 'w');
    
    fprintf(fid, '# Classification System Results Summary\n\n');
    fprintf(fid, '**Generated:** %s\n\n', datestr(now));
    
    fprintf(fid, '## Overview\n\n');
    fprintf(fid, 'This document summarizes the results of the corrosion severity ');
    fprintf(fid, 'classification system for ASTM A572 Grade 50 steel structures.\n\n');
    
    fprintf(fid, '## Methodology\n\n');
    fprintf(fid, '### Dataset\n\n');
    fprintf(fid, '- **Source:** Segmentation dataset with binary masks\n');
    fprintf(fid, '- **Label Generation:** Automated from corroded area percentage\n');
    fprintf(fid, '- **Classes:** 3 severity levels (None/Light, Moderate, Severe)\n');
    fprintf(fid, '- **Split:** 70%% train, 15%% validation, 15%% test (stratified)\n\n');
    
    fprintf(fid, '### Models\n\n');
    fprintf(fid, '1. **ResNet50:** Pre-trained on ImageNet, fine-tuned\n');
    fprintf(fid, '2. **EfficientNet-B0:** Pre-trained on ImageNet, fine-tuned\n');
    fprintf(fid, '3. **Custom CNN:** Trained from scratch, optimized for task\n\n');
    
    fprintf(fid, '### Training Configuration\n\n');
    fprintf(fid, '- **Input Size:** 224×224×3\n');
    fprintf(fid, '- **Batch Size:** 32\n');
    fprintf(fid, '- **Max Epochs:** 50 (with early stopping)\n');
    fprintf(fid, '- **Learning Rate:** 1e-4 (piecewise schedule)\n');
    fprintf(fid, '- **Augmentation:** Rotation, flipping, brightness/contrast\n\n');
    
    fprintf(fid, '## Results\n\n');
    fprintf(fid, '### Performance Metrics\n\n');
    fprintf(fid, 'See `tables/metrics_comparison_table.tex` for detailed metrics.\n\n');
    fprintf(fid, '**Key Findings:**\n\n');
    fprintf(fid, '- All models achieved >XX%% accuracy on test set\n');
    fprintf(fid, '- Best model: [Model Name] with XX%% accuracy\n');
    fprintf(fid, '- Fastest inference: [Model Name] at XX ms/image\n\n');
    
    fprintf(fid, '### Figures\n\n');
    fprintf(fid, '#### Figure 1: Confusion Matrices\n\n');
    fprintf(fid, '![Confusion Matrix - ResNet50](figures/confusion_matrix_resnet50.png)\n\n');
    fprintf(fid, '*Figure 1a: Confusion matrix for ResNet50 classifier*\n\n');
    
    fprintf(fid, '#### Figure 2: Training Curves\n\n');
    fprintf(fid, '![Training Curves](figures/training_curves_comparison.png)\n\n');
    fprintf(fid, '*Figure 2: Training and validation curves for all models*\n\n');
    
    fprintf(fid, '#### Figure 3: ROC Curves\n\n');
    fprintf(fid, '![ROC Curves - ResNet50](figures/roc_curves_resnet50.png)\n\n');
    fprintf(fid, '*Figure 3: ROC curves with AUC scores for ResNet50*\n\n');
    
    fprintf(fid, '#### Figure 4: Inference Time Comparison\n\n');
    fprintf(fid, '![Inference Time](figures/inference_time_comparison.png)\n\n');
    fprintf(fid, '*Figure 4: Inference time comparison across models*\n\n');
    
    fprintf(fid, '## Discussion\n\n');
    fprintf(fid, '### Model Performance\n\n');
    fprintf(fid, '[Discuss model performance, strengths, and weaknesses]\n\n');
    
    fprintf(fid, '### Comparison with Segmentation\n\n');
    fprintf(fid, '[Compare classification vs segmentation approach]\n\n');
    
    fprintf(fid, '### Practical Applications\n\n');
    fprintf(fid, '[Discuss real-world applications and deployment]\n\n');
    
    fprintf(fid, '## Conclusion\n\n');
    fprintf(fid, '[Summarize key findings and contributions]\n\n');
    
    fprintf(fid, '## References\n\n');
    fprintf(fid, '[Add relevant citations]\n\n');
    
    fprintf(fid, '---\n');
    fprintf(fid, '*Generated by create_publication_outputs.m*\n');
    
    fclose(fid);
end

function suppPath = createSupplementaryMaterials(pubDir)
    % Create supplementary materials archive
    suppDir = fullfile(pubDir, 'supplementary');
    suppPath = suppDir;
    
    % Copy result files
    sourceResultsDir = fullfile('output', 'classification', 'results');
    if exist(sourceResultsDir, 'dir')
        matFiles = dir(fullfile(sourceResultsDir, '*.mat'));
        for i = 1:length(matFiles)
            sourcePath = fullfile(sourceResultsDir, matFiles(i).name);
            targetPath = fullfile(suppDir, matFiles(i).name);
            copyfile(sourcePath, targetPath);
        end
        fprintf('    Copied %d result files\n', length(matFiles));
    end
    
    % Copy execution logs
    sourceLogsDir = fullfile('output', 'classification', 'logs');
    if exist(sourceLogsDir, 'dir')
        logFiles = dir(fullfile(sourceLogsDir, '*.txt'));
        if ~isempty(logFiles)
            % Copy most recent log
            [~, idx] = max([logFiles.datenum]);
            sourcePath = fullfile(sourceLogsDir, logFiles(idx).name);
            targetPath = fullfile(suppDir, 'execution_log.txt');
            copyfile(sourcePath, targetPath);
            fprintf('    Copied execution log\n');
        end
    end
    
    % Copy labels CSV
    labelsFile = fullfile('output', 'classification', 'labels.csv');
    if exist(labelsFile, 'file')
        copyfile(labelsFile, fullfile(suppDir, 'labels.csv'));
        fprintf('    Copied labels file\n');
    end
    
    % Create supplementary README
    createSupplementaryReadme(suppDir);
end

function createSupplementaryReadme(suppDir)
    % Create README for supplementary materials
    fid = fopen(fullfile(suppDir, 'README.md'), 'w');
    
    fprintf(fid, '# Supplementary Materials\n\n');
    fprintf(fid, 'This directory contains supplementary materials for the ');
    fprintf(fid, 'corrosion classification system.\n\n');
    
    fprintf(fid, '## Contents\n\n');
    fprintf(fid, '### Result Files (.mat)\n\n');
    fprintf(fid, 'MATLAB data files containing:\n');
    fprintf(fid, '- Complete evaluation metrics\n');
    fprintf(fid, '- Confusion matrices\n');
    fprintf(fid, '- ROC curve data\n');
    fprintf(fid, '- Training histories\n\n');
    
    fprintf(fid, '### Labels (labels.csv)\n\n');
    fprintf(fid, 'Generated severity labels with columns:\n');
    fprintf(fid, '- `filename`: Image filename\n');
    fprintf(fid, '- `corroded_percentage`: Percentage of corroded pixels\n');
    fprintf(fid, '- `severity_class`: Assigned class (0, 1, or 2)\n\n');
    
    fprintf(fid, '### Execution Log (execution_log.txt)\n\n');
    fprintf(fid, 'Complete execution log including:\n');
    fprintf(fid, '- Configuration parameters\n');
    fprintf(fid, '- Training progress\n');
    fprintf(fid, '- Evaluation results\n');
    fprintf(fid, '- Error messages (if any)\n\n');
    
    fprintf(fid, '## Usage\n\n');
    fprintf(fid, 'Load result files in MATLAB:\n');
    fprintf(fid, '```matlab\n');
    fprintf(fid, 'load(''resnet50_results.mat'');\n');
    fprintf(fid, '```\n\n');
    
    fclose(fid);
end

function readmePath = generateArchiveReadme(pubDir, archive)
    % Generate main README for publication archive
    readmePath = fullfile(pubDir, 'README.md');
    fid = fopen(readmePath, 'w');
    
    fprintf(fid, '# Publication-Ready Outputs\n\n');
    fprintf(fid, '**Generated:** %s\n\n', datestr(archive.timestamp));
    
    fprintf(fid, '## Overview\n\n');
    fprintf(fid, 'This archive contains all publication-ready materials for the ');
    fprintf(fid, 'corrosion severity classification system.\n\n');
    
    fprintf(fid, '## Directory Structure\n\n');
    fprintf(fid, '```\n');
    fprintf(fid, '%s/\n', pubDir);
    fprintf(fid, '├── figures/              # High-resolution figures (PNG + PDF)\n');
    fprintf(fid, '├── tables/               # LaTeX-formatted tables\n');
    fprintf(fid, '├── supplementary/        # Supplementary materials\n');
    fprintf(fid, '├── documentation/        # System documentation\n');
    fprintf(fid, '├── RESULTS_SUMMARY.md    # Comprehensive results summary\n');
    fprintf(fid, '├── README.md             # This file\n');
    fprintf(fid, '└── archive_info.mat      # Archive metadata\n');
    fprintf(fid, '```\n\n');
    
    fprintf(fid, '## Figures\n\n');
    fprintf(fid, 'All figures are provided in two formats:\n');
    fprintf(fid, '- **PNG (300 DPI):** For presentations and web\n');
    fprintf(fid, '- **PDF (vector):** For LaTeX documents and print\n\n');
    
    fprintf(fid, '### Available Figures\n\n');
    fprintf(fid, '1. **Confusion Matrices:** One per model (ResNet50, EfficientNet-B0, Custom CNN)\n');
    fprintf(fid, '2. **Training Curves:** Comparison of all models\n');
    fprintf(fid, '3. **ROC Curves:** One per model with AUC values\n');
    fprintf(fid, '4. **Inference Time Comparison:** Bar chart across models\n\n');
    
    fprintf(fid, '## Tables\n\n');
    fprintf(fid, 'LaTeX-formatted tables ready for direct inclusion:\n\n');
    fprintf(fid, '- `metrics_comparison_table.tex`: Model performance comparison\n');
    fprintf(fid, '- `confusion_matrix_*.tex`: Confusion matrices for each model\n');
    fprintf(fid, '- `results_summary.tex`: Complete results summary\n\n');
    
    fprintf(fid, '### Usage in LaTeX\n\n');
    fprintf(fid, '```latex\n');
    fprintf(fid, '\\input{tables/metrics_comparison_table.tex}\n');
    fprintf(fid, '```\n\n');
    
    fprintf(fid, '## Supplementary Materials\n\n');
    fprintf(fid, 'Additional materials for reviewers and reproducibility:\n\n');
    fprintf(fid, '- MATLAB result files (.mat)\n');
    fprintf(fid, '- Generated labels (labels.csv)\n');
    fprintf(fid, '- Execution log\n');
    fprintf(fid, '- Supplementary README\n\n');
    
    fprintf(fid, '## Documentation\n\n');
    fprintf(fid, 'System documentation and guides:\n\n');
    fprintf(fid, '- User guide\n');
    fprintf(fid, '- Configuration examples\n');
    fprintf(fid, '- Requirements validation report\n');
    fprintf(fid, '- Design document\n\n');
    
    fprintf(fid, '## Citation\n\n');
    fprintf(fid, 'If you use these results in your research, please cite:\n\n');
    fprintf(fid, '```bibtex\n');
    fprintf(fid, '@article{corrosion_classification_2025,\n');
    fprintf(fid, '  title={Automated Corrosion Severity Classification in ASTM A572 Grade 50 Steel},\n');
    fprintf(fid, '  author={[Your Name]},\n');
    fprintf(fid, '  journal={[Journal Name]},\n');
    fprintf(fid, '  year={2025}\n');
    fprintf(fid, '}\n');
    fprintf(fid, '```\n\n');
    
    fprintf(fid, '## Contact\n\n');
    fprintf(fid, 'For questions or issues, please contact:\n');
    fprintf(fid, '- Email: [your.email@institution.edu]\n');
    fprintf(fid, '- GitHub: [repository URL]\n\n');
    
    fprintf(fid, '---\n');
    fprintf(fid, '*Generated by create_publication_outputs.m*\n');
    
    fclose(fid);
    
    % Copy documentation files
    docDir = fullfile(pubDir, 'documentation');
    docFiles = {
        'src/classification/USER_GUIDE.md', ...
        'src/classification/CONFIGURATION_EXAMPLES.md', ...
        'REQUIREMENTS_VALIDATION_REPORT.md', ...
        '.kiro/specs/corrosion-classification-system/design.md'
    };
    
    for i = 1:length(docFiles)
        if exist(docFiles{i}, 'file')
            [~, name, ext] = fileparts(docFiles{i});
            copyfile(docFiles{i}, fullfile(docDir, [name ext]));
        end
    end
end
