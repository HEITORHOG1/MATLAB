%% Demo: Sistema de Monitoramento de Otimização e Gradientes
% Este script demonstra o uso completo do sistema de monitoramento
% de gradientes e análise de otimização.

clear; clc; close all;

fprintf('=== DEMO: Sistema de Monitoramento de Otimização ===\n\n');

%% 1. Configuração Inicial
fprintf('1. Configurando sistema de monitoramento...\n');

% Criar diretório de saída se não existir
outputDir = 'output/demo_optimization';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Configuração de treinamento simulada
trainingConfig = struct();
trainingConfig.learning_rate = 0.001;
trainingConfig.batch_size = 32;
trainingConfig.optimizer = 'adam';
trainingConfig.epochs = 50;

fprintf('  - Diretório de saída: %s\n', outputDir);
fprintf('  - Learning rate: %.4f\n', trainingConfig.learning_rate);
fprintf('  - Batch size: %d\n', trainingConfig.batch_size);

%% 2. Criar Rede Neural Simulada
fprintf('\n2. Criando rede neural simulada...\n');

% Para demonstração, vamos simular uma rede simples
% Em uso real, isso seria sua rede U-Net ou Attention U-Net
try
    % Tentar criar uma rede simples para demonstração
    layers = [
        imageInputLayer([256 256 1], 'Name', 'input')
        convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'conv1')
        reluLayer('Name', 'relu1')
        convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'conv2')
        reluLayer('Name', 'relu2')
        convolution2dLayer(3, 1, 'Padding', 'same', 'Name', 'output')
        sigmoidLayer('Name', 'sigmoid')
    ];
    
    network = layerGraph(layers);
    fprintf('  - Rede criada com %d camadas\n', length(layers));
catch
    % Fallback para demonstração sem Deep Learning Toolbox
    fprintf('  - Usando rede simulada (Deep Learning Toolbox não disponível)\n');
    network = struct('type', 'simulated_network', 'layers', 7);
end

%% 3. Inicializar Sistema de Monitoramento
fprintf('\n3. Inicializando sistema de monitoramento...\n');

% Criar integração de treinamento
integration = TrainingIntegration(...
    'SaveDirectory', outputDir, ...
    'VerboseMode', true, ...
    'AlertsEnabled', true, ...
    'AutoSaveEnabled', true);

% Configurar monitoramento
integration.setupMonitoring(network, trainingConfig);

fprintf('  - GradientMonitor inicializado\n');
fprintf('  - OptimizationAnalyzer inicializado\n');
fprintf('  - TrainingIntegration configurada\n');

%% 4. Simular Treinamento com Diferentes Cenários
fprintf('\n4. Simulando treinamento com diferentes cenários...\n');

% Cenário 1: Treinamento normal (épocas 1-15)
fprintf('\n  Cenário 1: Treinamento normal\n');
for epoch = 1:15
    % Simular métricas de treinamento normal
    baseLoss = 1.0;
    metrics = struct();
    metrics.loss = baseLoss * exp(-epoch/20) + 0.1 * randn() * exp(-epoch/10);
    metrics.validation_loss = metrics.loss * (1.1 + 0.05 * randn());
    metrics.accuracy = 1 - metrics.loss + 0.02 * randn();
    metrics.validation_accuracy = metrics.accuracy * (0.95 + 0.05 * randn());
    
    % Registrar época
    integration.recordEpoch(network, epoch, metrics);
    
    if mod(epoch, 5) == 0
        fprintf('    Época %d: Loss=%.4f, Acc=%.3f\n', epoch, metrics.loss, metrics.accuracy);
    end
end

% Cenário 2: Gradientes explodindo (épocas 16-20)
fprintf('\n  Cenário 2: Simulando gradientes explodindo\n');
for epoch = 16:20
    % Simular gradientes explodindo
    metrics = struct();
    metrics.loss = 0.5 + (epoch-15) * 0.3 + 0.2 * randn(); % Loss aumentando
    metrics.validation_loss = metrics.loss * (1.2 + 0.1 * randn());
    metrics.accuracy = max(0.1, 0.8 - (epoch-15) * 0.1 + 0.05 * randn());
    metrics.validation_accuracy = metrics.accuracy * (0.9 + 0.1 * randn());
    
    integration.recordEpoch(network, epoch, metrics);
    
    fprintf('    Época %d: Loss=%.4f (aumentando!)\n', epoch, metrics.loss);
end

% Cenário 3: Recuperação com learning rate reduzido (épocas 21-30)
fprintf('\n  Cenário 3: Recuperação com LR reduzido\n');
trainingConfig.learning_rate = trainingConfig.learning_rate * 0.5;
for epoch = 21:30
    % Simular recuperação
    metrics = struct();
    recoveryFactor = exp(-(epoch-20)/5);
    metrics.loss = 0.3 + 0.2 * recoveryFactor + 0.05 * randn();
    metrics.validation_loss = metrics.loss * (1.05 + 0.03 * randn());
    metrics.accuracy = 0.85 - 0.1 * recoveryFactor + 0.02 * randn();
    metrics.validation_accuracy = metrics.accuracy * (0.98 + 0.02 * randn());
    
    integration.recordEpoch(network, epoch, metrics);
    
    if mod(epoch, 3) == 0
        fprintf('    Época %d: Loss=%.4f (recuperando)\n', epoch, metrics.loss);
    end
end

% Cenário 4: Convergência final (épocas 31-40)
fprintf('\n  Cenário 4: Convergência final\n');
for epoch = 31:40
    % Simular convergência
    metrics = struct();
    metrics.loss = 0.15 + 0.05 * exp(-(epoch-30)/3) + 0.01 * randn();
    metrics.validation_loss = metrics.loss * (1.02 + 0.01 * randn());
    metrics.accuracy = 0.92 + 0.03 * (1 - exp(-(epoch-30)/5)) + 0.005 * randn();
    metrics.validation_accuracy = metrics.accuracy * (0.99 + 0.01 * randn());
    
    integration.recordEpoch(network, epoch, metrics);
    
    if mod(epoch, 3) == 0
        fprintf('    Época %d: Loss=%.4f, Acc=%.3f (convergindo)\n', ...
            epoch, metrics.loss, metrics.accuracy);
    end
end

%% 5. Análise de Otimização
fprintf('\n5. Gerando análise de otimização...\n');

% Obter sugestões atuais
suggestions = integration.getSuggestions();
fprintf('  - Sugestões geradas\n');

% Gerar relatório completo
report = integration.generateReport();
fprintf('  - Relatório completo gerado\n');

% Obter resumo do treinamento
summary = integration.getTrainingSummary();
fprintf('  - Resumo do treinamento obtido\n');

%% 6. Visualizações
fprintf('\n6. Gerando visualizações...\n');

% Gráfico de progresso do treinamento
integration.plotTrainingProgress('SavePlots', true, 'ShowPlots', true);
fprintf('  - Gráfico de progresso salvo\n');

% Salvar progresso final
integration.saveProgress();
fprintf('  - Progresso final salvo\n');

%% 7. Demonstrar Funcionalidades Específicas
fprintf('\n7. Demonstrando funcionalidades específicas...\n');

% Acessar diretamente o GradientMonitor
gradientMonitor = integration.gradientMonitor;
if ~isempty(gradientMonitor)
    % Gerar gráficos de evolução de gradientes
    gradientMonitor.plotGradientEvolution('SavePlots', true, 'ShowPlots', false);
    fprintf('  - Gráficos de gradientes salvos\n');
    
    % Detectar problemas de gradiente
    problems = gradientMonitor.detectGradientProblems();
    fprintf('  - Problemas detectados:\n');
    fprintf('    * Vanishing gradients: %d camadas\n', length(problems.vanishing_gradients));
    fprintf('    * Exploding gradients: %d camadas\n', length(problems.exploding_gradients));
    fprintf('    * Alta variância: %d camadas\n', length(problems.high_variance));
    fprintf('    * Estagnação: %d camadas\n', length(problems.stagnation));
    
    % Salvar histórico de gradientes
    gradientHistoryFile = fullfile(outputDir, 'demo_gradient_history.mat');
    gradientMonitor.saveGradientHistory(gradientHistoryFile);
    fprintf('  - Histórico de gradientes salvo em: %s\n', gradientHistoryFile);
end

% Acessar diretamente o OptimizationAnalyzer
optimizationAnalyzer = integration.optimizationAnalyzer;
if ~isempty(optimizationAnalyzer)
    % Análise de convergência
    convergenceAnalysis = optimizationAnalyzer.analyzeConvergence(integration.trainingMetrics);
    fprintf('  - Análise de convergência:\n');
    fprintf('    * Convergindo: %s\n', mat2str(convergenceAnalysis.is_converging));
    fprintf('    * Taxa de convergência: %.6f\n', convergenceAnalysis.convergence_rate);
    fprintf('    * Qualidade: %s\n', convergenceAnalysis.convergence_quality);
    
    % Sugestões de hiperparâmetros
    hyperparamSuggestions = optimizationAnalyzer.suggestHyperparameters(...
        trainingConfig, integration.trainingMetrics);
    fprintf('  - Sugestões de hiperparâmetros geradas\n');
end

%% 8. Demonstrar Alertas em Tempo Real
fprintf('\n8. Demonstrando sistema de alertas...\n');

% Simular situação crítica
criticalMetrics = struct();
criticalMetrics.loss = 10.5; % Loss muito alta
criticalMetrics.accuracy = 0.1;

if ~isempty(optimizationAnalyzer)
    alerts = optimizationAnalyzer.checkRealTimeAlerts(41, criticalMetrics);
    
    fprintf('  - Alertas para situação crítica:\n');
    if ~isempty(alerts.critical)
        for i = 1:length(alerts.critical)
            fprintf('    CRÍTICO: %s\n', alerts.critical{i});
        end
    end
    if ~isempty(alerts.actions_required)
        for i = 1:length(alerts.actions_required)
            fprintf('    AÇÃO: %s\n', alerts.actions_required{i});
        end
    end
end

%% 9. Resumo Final
fprintf('\n9. Resumo final da demonstração...\n');

fprintf('  - Total de épocas simuladas: %d\n', summary.total_epochs);
fprintf('  - Loss final: %.4f\n', summary.final_loss);
fprintf('  - Melhor loss: %.4f\n', summary.best_loss);
fprintf('  - Accuracy final: %.3f\n', summary.final_accuracy);
fprintf('  - Melhor accuracy: %.3f\n', summary.best_accuracy);

if isfield(summary, 'optimization_issues')
    fprintf('  - Problemas de otimização detectados: %d\n', summary.optimization_issues);
end

fprintf('\n  Arquivos gerados em: %s\n', outputDir);
fprintf('  - Gráficos de progresso\n');
fprintf('  - Histórico de gradientes\n');
fprintf('  - Relatórios de otimização\n');
fprintf('  - Dados de progresso do treinamento\n');

%% 10. Exemplo de Integração com Scripts Existentes
fprintf('\n10. Exemplo de integração com scripts existentes...\n');

fprintf('Para integrar com seus scripts de treinamento existentes:\n\n');
fprintf('1. Adicione no início do treinamento:\n');
fprintf('   integration = TrainingIntegration();\n');
fprintf('   integration.setupMonitoring(network, config);\n\n');
fprintf('2. No loop de treinamento, adicione:\n');
fprintf('   integration.recordEpoch(network, epoch, metrics);\n\n');
fprintf('3. Ao final do treinamento:\n');
fprintf('   suggestions = integration.getSuggestions();\n');
fprintf('   report = integration.generateReport();\n');
fprintf('   integration.plotTrainingProgress();\n\n');

fprintf('=== DEMONSTRAÇÃO CONCLUÍDA ===\n');
fprintf('Verifique os arquivos gerados em: %s\n', outputDir);

%% Função auxiliar para verificar se Deep Learning Toolbox está disponível
function hasToolbox = checkDeepLearningToolbox()
    try
        ver('Deep Learning Toolbox');
        hasToolbox = true;
    catch
        hasToolbox = false;
    end
end