% gerar_figura_arquiteturas.m - Generate model architecture comparison figure
%
% This script generates a visual comparison of the three model architectures:
% ResNet50, EfficientNet-B0, and Custom CNN, showing parameter counts and
% key layer structures.
%
% Requirements: Task 8.3 - Generate Figure 3: Model architecture comparison
%
% Output: figuras_classificacao/figura_arquiteturas.pdf

function gerar_figura_arquiteturas()
    % Create output directory if it doesn't exist
    if ~exist('figuras_classificacao', 'dir')
        mkdir('figuras_classificacao');
    end
    
    % Create figure
    fig = figure('Position', [100, 100, 1600, 600], 'Color', 'w');
    
    % Define colors
    colorInput = [0.9, 0.95, 1.0];      % Light blue
    colorConv = [1.0, 0.95, 0.8];       % Light yellow
    colorPool = [0.95, 0.9, 1.0];       % Light purple
    colorFC = [0.9, 1.0, 0.9];          % Light green
    colorOutput = [1.0, 0.9, 0.9];      % Light red
    
    % Subplot 1: ResNet50
    subplot(1, 3, 1);
    plotResNet50();
    title('(a) ResNet50', 'FontSize', 13, 'FontWeight', 'bold');
    
    % Subplot 2: EfficientNet-B0
    subplot(1, 3, 2);
    plotEfficientNetB0();
    title('(b) EfficientNet-B0', 'FontSize', 13, 'FontWeight', 'bold');
    
    % Subplot 3: Custom CNN
    subplot(1, 3, 3);
    plotCustomCNN();
    title('(c) Custom CNN', 'FontSize', 13, 'FontWeight', 'bold');
    
    % Add main title
    sgtitle('Model Architecture Comparison', 'FontSize', 15, 'FontWeight', 'bold');
    
    % Save as PDF
    outputFile = fullfile('figuras_classificacao', 'figura_arquiteturas.pdf');
    exportgraphics(fig, outputFile, 'ContentType', 'vector', 'Resolution', 300);
    
    % Also save as PNG for preview
    outputFilePNG = fullfile('figuras_classificacao', 'figura_arquiteturas.png');
    exportgraphics(fig, outputFilePNG, 'Resolution', 300);
    
    fprintf('Model architecture comparison figure saved to:\n');
    fprintf('  %s\n', outputFile);
    fprintf('  %s\n', outputFilePNG);
end

function plotResNet50()
    % Plot ResNet50 architecture
    ax = gca;
    axis(ax, 'off');
    hold(ax, 'on');
    
    % Define colors
    colorInput = [0.9, 0.95, 1.0];
    colorConv = [1.0, 0.95, 0.8];
    colorResBlock = [0.95, 0.9, 1.0];
    colorFC = [0.9, 1.0, 0.9];
    colorOutput = [1.0, 0.9, 0.9];
    
    yPos = 10;
    xCenter = 2.5;
    boxWidth = 2.0;
    boxHeight = 0.6;
    
    % Input
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorInput, ...
        {'Input', '224×224×3'}, 'normal', 9);
    yPos = yPos - 1.0;
    drawArrow(ax, xCenter, yPos + 0.4, xCenter, yPos + 0.1);
    
    % Conv1
    yPos = yPos - 0.3;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorConv, ...
        {'Conv 7×7', '64 filters'}, 'normal', 9);
    yPos = yPos - 1.0;
    drawArrow(ax, xCenter, yPos + 0.4, xCenter, yPos + 0.1);
    
    % Residual blocks
    yPos = yPos - 0.3;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight*1.2, colorResBlock, ...
        {'Residual Blocks', 'Stage 1-4', '(16 blocks total)'}, 'normal', 8);
    yPos = yPos - 1.5;
    drawArrow(ax, xCenter, yPos + 0.5, xCenter, yPos + 0.1);
    
    % Global Average Pooling
    yPos = yPos - 0.3;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorResBlock, ...
        {'Global Avg Pool', '2048 features'}, 'normal', 9);
    yPos = yPos - 1.0;
    drawArrow(ax, xCenter, yPos + 0.4, xCenter, yPos + 0.1);
    
    % Fully Connected
    yPos = yPos - 0.3;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorFC, ...
        {'FC Layer', '4 classes'}, 'normal', 9);
    yPos = yPos - 1.0;
    drawArrow(ax, xCenter, yPos + 0.4, xCenter, yPos + 0.1);
    
    % Output
    yPos = yPos - 0.3;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorOutput, ...
        {'Softmax', 'Output'}, 'bold', 9);
    
    % Add parameter count
    text(xCenter, 0.5, '~25M parameters', ...
        'HorizontalAlignment', 'center', 'FontSize', 10, ...
        'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.8]);
    
    xlim([0, 5]);
    ylim([0, 11]);
end

function plotEfficientNetB0()
    % Plot EfficientNet-B0 architecture
    ax = gca;
    axis(ax, 'off');
    hold(ax, 'on');
    
    % Define colors
    colorInput = [0.9, 0.95, 1.0];
    colorConv = [1.0, 0.95, 0.8];
    colorMBConv = [0.95, 0.9, 1.0];
    colorFC = [0.9, 1.0, 0.9];
    colorOutput = [1.0, 0.9, 0.9];
    
    yPos = 10;
    xCenter = 2.5;
    boxWidth = 2.0;
    boxHeight = 0.6;
    
    % Input
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorInput, ...
        {'Input', '224×224×3'}, 'normal', 9);
    yPos = yPos - 1.0;
    drawArrow(ax, xCenter, yPos + 0.4, xCenter, yPos + 0.1);
    
    % Stem Conv
    yPos = yPos - 0.3;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorConv, ...
        {'Stem Conv 3×3', '32 filters'}, 'normal', 9);
    yPos = yPos - 1.0;
    drawArrow(ax, xCenter, yPos + 0.4, xCenter, yPos + 0.1);
    
    % MBConv blocks
    yPos = yPos - 0.3;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight*1.2, colorMBConv, ...
        {'MBConv Blocks', 'Stage 1-7', '(16 blocks total)'}, 'normal', 8);
    yPos = yPos - 1.5;
    drawArrow(ax, xCenter, yPos + 0.5, xCenter, yPos + 0.1);
    
    % Head Conv
    yPos = yPos - 0.3;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorConv, ...
        {'Head Conv 1×1', '1280 features'}, 'normal', 9);
    yPos = yPos - 1.0;
    drawArrow(ax, xCenter, yPos + 0.4, xCenter, yPos + 0.1);
    
    % Global Average Pooling
    yPos = yPos - 0.3;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorMBConv, ...
        {'Global Avg Pool'}, 'normal', 9);
    yPos = yPos - 1.0;
    drawArrow(ax, xCenter, yPos + 0.4, xCenter, yPos + 0.1);
    
    % Fully Connected
    yPos = yPos - 0.3;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorFC, ...
        {'FC Layer', '4 classes'}, 'normal', 9);
    yPos = yPos - 1.0;
    drawArrow(ax, xCenter, yPos + 0.4, xCenter, yPos + 0.1);
    
    % Output
    yPos = yPos - 0.3;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorOutput, ...
        {'Softmax', 'Output'}, 'bold', 9);
    
    % Add parameter count
    text(xCenter, 0.5, '~5M parameters', ...
        'HorizontalAlignment', 'center', 'FontSize', 10, ...
        'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.8]);
    
    xlim([0, 5]);
    ylim([0, 11]);
end

function plotCustomCNN()
    % Plot Custom CNN architecture
    ax = gca;
    axis(ax, 'off');
    hold(ax, 'on');
    
    % Define colors
    colorInput = [0.9, 0.95, 1.0];
    colorConv = [1.0, 0.95, 0.8];
    colorPool = [0.95, 0.9, 1.0];
    colorFC = [0.9, 1.0, 0.9];
    colorOutput = [1.0, 0.9, 0.9];
    
    yPos = 10;
    xCenter = 2.5;
    boxWidth = 2.0;
    boxHeight = 0.6;
    
    % Input
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorInput, ...
        {'Input', '224×224×3'}, 'normal', 9);
    yPos = yPos - 1.0;
    drawArrow(ax, xCenter, yPos + 0.4, xCenter, yPos + 0.1);
    
    % Conv Block 1
    yPos = yPos - 0.3;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorConv, ...
        {'Conv 3×3 + ReLU', '32 filters'}, 'normal', 8);
    yPos = yPos - 0.8;
    drawArrow(ax, xCenter, yPos + 0.2, xCenter, yPos + 0.1);
    yPos = yPos - 0.2;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight*0.8, colorPool, ...
        {'MaxPool 2×2'}, 'normal', 8);
    yPos = yPos - 0.9;
    drawArrow(ax, xCenter, yPos + 0.3, xCenter, yPos + 0.1);
    
    % Conv Block 2
    yPos = yPos - 0.2;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorConv, ...
        {'Conv 3×3 + ReLU', '64 filters'}, 'normal', 8);
    yPos = yPos - 0.8;
    drawArrow(ax, xCenter, yPos + 0.2, xCenter, yPos + 0.1);
    yPos = yPos - 0.2;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight*0.8, colorPool, ...
        {'MaxPool 2×2'}, 'normal', 8);
    yPos = yPos - 0.9;
    drawArrow(ax, xCenter, yPos + 0.3, xCenter, yPos + 0.1);
    
    % Conv Block 3
    yPos = yPos - 0.2;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorConv, ...
        {'Conv 3×3 + ReLU', '128 filters'}, 'normal', 8);
    yPos = yPos - 0.8;
    drawArrow(ax, xCenter, yPos + 0.2, xCenter, yPos + 0.1);
    yPos = yPos - 0.2;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight*0.8, colorPool, ...
        {'MaxPool 2×2'}, 'normal', 8);
    yPos = yPos - 0.9;
    drawArrow(ax, xCenter, yPos + 0.3, xCenter, yPos + 0.1);
    
    % Flatten
    yPos = yPos - 0.2;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight*0.8, colorPool, ...
        {'Flatten'}, 'normal', 8);
    yPos = yPos - 0.9;
    drawArrow(ax, xCenter, yPos + 0.3, xCenter, yPos + 0.1);
    
    % FC Layer 1
    yPos = yPos - 0.2;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorFC, ...
        {'FC + ReLU', '256 units'}, 'normal', 8);
    yPos = yPos - 0.8;
    drawArrow(ax, xCenter, yPos + 0.2, xCenter, yPos + 0.1);
    
    % FC Layer 2
    yPos = yPos - 0.2;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorFC, ...
        {'FC Layer', '4 classes'}, 'normal', 8);
    yPos = yPos - 0.8;
    drawArrow(ax, xCenter, yPos + 0.2, xCenter, yPos + 0.1);
    
    % Output
    yPos = yPos - 0.2;
    drawBox(ax, xCenter, yPos, boxWidth, boxHeight, colorOutput, ...
        {'Softmax', 'Output'}, 'bold', 9);
    
    % Add parameter count
    text(xCenter, 0.5, '~2M parameters', ...
        'HorizontalAlignment', 'center', 'FontSize', 10, ...
        'FontWeight', 'bold', 'Color', [0.2, 0.2, 0.8]);
    
    xlim([0, 5]);
    ylim([0, 11]);
end

function drawBox(ax, x, y, width, height, color, textLines, fontWeight, fontSize)
    % Draw a box with text
    rectangle(ax, 'Position', [x - width/2, y - height/2, width, height], ...
        'FaceColor', color, 'EdgeColor', 'k', 'LineWidth', 1.2);
    
    % Add text
    if ischar(textLines)
        textLines = {textLines};
    end
    
    lineSpacing = 0.15;
    totalHeight = (length(textLines) - 1) * lineSpacing;
    
    for i = 1:length(textLines)
        yOffset = totalHeight / 2 - (i - 1) * lineSpacing;
        text(ax, x, y + yOffset, textLines{i}, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', fontSize, ...
            'FontWeight', fontWeight, ...
            'Interpreter', 'none');
    end
end

function drawArrow(ax, x1, y1, x2, y2)
    % Draw an arrow from (x1, y1) to (x2, y2)
    arrow([x1, y1], [x2, y2], 'Width', 1.5, 'Length', 8);
end

function h = arrow(start, stop, varargin)
    % Simple arrow drawing function
    x = [start(1), stop(1)];
    y = [start(2), stop(2)];
    h = plot(x, y, 'k-', 'LineWidth', 1.5);
    
    % Add arrowhead
    dx = stop(1) - start(1);
    dy = stop(2) - start(2);
    len = sqrt(dx^2 + dy^2);
    if len > 0
        dx = dx / len;
        dy = dy / len;
        arrowSize = 0.1;
        plot([stop(1), stop(1) - arrowSize*dx - arrowSize*dy], ...
             [stop(2), stop(2) - arrowSize*dy + arrowSize*dx], 'k-', 'LineWidth', 1.5);
        plot([stop(1), stop(1) - arrowSize*dx + arrowSize*dy], ...
             [stop(2), stop(2) - arrowSize*dy - arrowSize*dx], 'k-', 'LineWidth', 1.5);
    end
end
