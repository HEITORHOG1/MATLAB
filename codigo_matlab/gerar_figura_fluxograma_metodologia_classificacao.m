% gerar_figura_fluxograma_metodologia_classificacao.m
% Generate methodology flowchart for classification article
%
% This script creates a comprehensive flowchart showing the complete
% classification pipeline from segmentation masks to model evaluation

function gerar_figura_fluxograma_metodologia_classificacao()
    % Create figure with proper paper size
    fig = figure('Position', [100, 100, 1200, 1600], 'Color', 'w');
    
    % Set paper properties for proper PDF output
    set(fig, 'PaperUnits', 'inches');
    set(fig, 'PaperSize', [8.5, 11]);
    set(fig, 'PaperPosition', [0, 0, 8.5, 11]);
    
    ax = axes('Parent', fig, 'Position', [0.05, 0.05, 0.9, 0.9]);
    axis(ax, 'off');
    hold(ax, 'on');
    
    % Define colors
    colorInput = [0.9, 0.95, 1.0];      % Light blue
    colorProcess = [1.0, 0.95, 0.8];    % Light yellow
    colorModel = [0.95, 0.9, 1.0];      % Light purple
    colorOutput = [0.9, 1.0, 0.9];      % Light green
    colorDecision = [1.0, 0.9, 0.9];    % Light red
    
    % Box dimensions
    boxWidth = 4.0;
    boxHeight = 1.0;
    
    % Starting position
    yPos = 20;
    xCenter = 5;
    
    % 1. Input: Segmentation Masks
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorInput, ...
        {'Segmentation Masks', '(414 images)'}, 'bold');
    yPos = yPos - 1.5;
    drawArrow(ax, xCenter, yPos + 0.7, xCenter, yPos + 0.2);
    
    % 2. Label Generation Process
    yPos = yPos - 0.5;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorProcess, ...
        {'Label Generation', 'Compute corroded percentage P_c'}, 'normal');
    yPos = yPos - 1.5;
    drawArrow(ax, xCenter, yPos + 0.7, xCenter, yPos + 0.2);
    
    % 3. Threshold-based Classification
    yPos = yPos - 0.5;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight*2.0, colorDecision, ...
        {'Threshold Classification', ...
         'Class 0: P_c < 10%', ...
         'Class 1: 10% ≤ P_c < 30%', ...
         'Class 2: P_c ≥ 30%'}, 'normal');
    yPos = yPos - 2.2;
    drawArrow(ax, xCenter, yPos + 0.5, xCenter, yPos + 0.2);
    
    % 4. Labeled Dataset
    yPos = yPos - 0.5;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorOutput, ...
        {'Labeled Dataset', '(414 images with severity labels)'}, 'bold');
    yPos = yPos - 1.5;
    drawArrow(ax, xCenter, yPos + 0.7, xCenter, yPos + 0.2);
    
    % 5. Dataset Split
    yPos = yPos - 0.5;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight*1.2, colorProcess, ...
        {'Stratified Data Split', ...
         'Train: 70% | Val: 15% | Test: 15%'}, 'normal');
    yPos = yPos - 1.8;
    
    % Split into three branches
    drawArrow(ax, xCenter, yPos + 0.6, xCenter - 2.5, yPos - 0.2);
    drawArrow(ax, xCenter, yPos + 0.6, xCenter, yPos - 0.2);
    drawArrow(ax, xCenter, yPos + 0.6, xCenter + 2.5, yPos - 0.2);
    
    % 6. Three model branches
    yPos = yPos - 1.0;
    
    % ResNet50 branch
    xLeft = xCenter - 2.5;
    drawBox(ax, xLeft, yPos, 2.2, boxHeight, colorModel, ...
        {'ResNet50', '(~25M params)'}, 'normal');
    
    % EfficientNet-B0 branch
    drawBox(ax, xCenter, yPos, 2.2, boxHeight, colorModel, ...
        {'EfficientNet-B0', '(~5M params)'}, 'normal');
    
    % Custom CNN branch
    xRight = xCenter + 2.5;
    drawBox(ax, xRight, yPos, 2.2, boxHeight, colorModel, ...
        {'Custom CNN', '(~2M params)'}, 'normal');
    
    yPos = yPos - 1.5;
    drawArrow(ax, xLeft, yPos + 0.7, xLeft, yPos + 0.2);
    drawArrow(ax, xCenter, yPos + 0.7, xCenter, yPos + 0.2);
    drawArrow(ax, xRight, yPos + 0.7, xRight, yPos + 0.2);
    
    % 7. Training with augmentation
    yPos = yPos - 0.5;
    drawBox(ax, xLeft, yPos, 2.2, boxHeight*1.2, colorProcess, ...
        {'Training', 'Data Augmentation'}, 'normal');
    drawBox(ax, xCenter, yPos, 2.2, boxHeight*1.2, colorProcess, ...
        {'Training', 'Data Augmentation'}, 'normal');
    drawBox(ax, xRight, yPos, 2.2, boxHeight*1.2, colorProcess, ...
        {'Training', 'Data Augmentation'}, 'normal');
    
    yPos = yPos - 1.8;
    drawArrow(ax, xLeft, yPos + 0.6, xLeft, yPos + 0.2);
    drawArrow(ax, xCenter, yPos + 0.6, xCenter, yPos + 0.2);
    drawArrow(ax, xRight, yPos + 0.6, xRight, yPos + 0.2);
    
    % 8. Trained models
    yPos = yPos - 0.5;
    drawBox(ax, xLeft, yPos, 2.2, boxHeight, colorModel, ...
        {'Trained', 'ResNet50'}, 'bold');
    drawBox(ax, xCenter, yPos, 2.2, boxHeight, colorModel, ...
        {'Trained', 'EfficientNet-B0'}, 'bold');
    drawBox(ax, xRight, yPos, 2.2, boxHeight, colorModel, ...
        {'Trained', 'Custom CNN'}, 'bold');
    
    yPos = yPos - 1.5;
    
    % Merge branches
    drawArrow(ax, xLeft, yPos + 0.7, xCenter, yPos - 0.2);
    drawArrow(ax, xCenter, yPos + 0.7, xCenter, yPos - 0.2);
    drawArrow(ax, xRight, yPos + 0.7, xCenter, yPos - 0.2);
    
    % 9. Evaluation on test set
    yPos = yPos - 1.0;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorProcess, ...
        {'Evaluation on Test Set'}, 'normal');
    
    yPos = yPos - 1.5;
    drawArrow(ax, xCenter, yPos + 0.7, xCenter, yPos + 0.2);
    
    % 10. Performance metrics
    yPos = yPos - 0.5;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight*1.8, colorOutput, ...
        {'Performance Metrics', ...
         'Accuracy, Precision, Recall, F1', ...
         'Confusion Matrix', ...
         'Inference Time'}, 'bold');
    
    % Set axis limits
    xlim(ax, [0, 10]);
    ylim(ax, [0, 22]);
    
    % Add title
    title(ax, 'Classification Methodology Flowchart', ...
        'FontSize', 16, 'FontWeight', 'bold');
    
    % Save figure
    outputDir = 'figuras_classificacao';
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Save as high-resolution PNG
    print(fig, fullfile(outputDir, 'figura_fluxograma_metodologia.png'), ...
        '-dpng', '-r300');
    
    % Save as PDF
    print(fig, fullfile(outputDir, 'figura_fluxograma_metodologia.pdf'), ...
        '-dpdf', '-r300');
    
    fprintf('Flowchart saved to %s/\n', outputDir);
    fprintf('  - figura_fluxograma_metodologia.png (300 DPI)\n');
    fprintf('  - figura_fluxograma_metodologia.pdf (vector)\n');
end

function drawBox(ax, x, y, width, height, color, textLines, fontWeight)
    % Draw a box with text
    rectangle(ax, 'Position', [x - width/2, y - height/2, width, height], ...
        'FaceColor', color, 'EdgeColor', 'k', 'LineWidth', 1.5);
    
    % Add text
    if ischar(textLines)
        textLines = {textLines};
    end
    
    % Calculate proper spacing based on number of lines and box height
    numLines = length(textLines);
    lineSpacing = height / (numLines + 1);
    
    for i = 1:numLines
        % Position each line evenly within the box
        yOffset = height/2 - i * lineSpacing;
        text(ax, x, y + yOffset, textLines{i}, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 9, ...
            'FontWeight', fontWeight, ...
            'Interpreter', 'tex');
    end
end

function drawArrow(ax, x1, y1, x2, y2)
    % Draw an arrow from (x1, y1) to (x2, y2)
    annotation('arrow', ...
        [(x1/10), (x2/10)], ...
        [(y1/22), (y2/22)], ...
        'LineWidth', 1.5, ...
        'HeadStyle', 'cback1', ...
        'HeadLength', 8, ...
        'HeadWidth', 8);
end
