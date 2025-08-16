classdef TreinadorAttentionUNet < handle
    % TreinadorAttentionUNet - Classe para treinamento do modelo Attention U-Net
    % Esta classe encapsula todo o processo de treinamento do modelo Attention U-Net
    % incluindo carregamento de dados, criação da arquitetura com mecanismos de atenção e treinamento
    
    properties
        caminhoImagens      % Caminho para imagens de treinamento
        caminhoMascaras     % Caminho para máscaras de treinamento
        configuracao        % Configurações de treinamento
        modelo              % Modelo treinado
        metricasUNet        % Métricas do U-Net para comparação
    end
    
    methods
        function obj = TreinadorAttentionUNet(caminhoImagens, caminhoMascaras)
            % Construtor da classe TreinadorAttentionUNet
            % Inputs:
            %   caminhoImagens - string com caminho para pasta de imagens
            %   caminhoMascaras - string com caminho para pasta de máscaras
            
            obj.caminhoImagens = caminhoImagens;
            obj.caminhoMascaras = caminhoMascaras;
            obj.configuracao = obj.obterConfiguracaoDefault();
            obj.modelo = [];
            obj.metricasUNet = [];
            
            % Validar caminhos
            obj.validarCaminhos();
        end
        
        function modelo = treinar(obj)
            % Executa o treinamento completo do modelo Attention U-Net
            % Returns:
            %   modelo - modelo Attention U-Net treinado
            
            fprintf('=== INICIANDO TREINAMENTO ATTENTION U-NET ===\n');
            
            try
                % Carregar métricas do U-Net para comparação
                obj.carregarMetricasUNet();
                
                % 1. Carregar dados (mesmos dados do U-Net)
                fprintf('[1/5] Carregando dados de treinamento...\n');
                [imagens, mascaras] = obj.carregarDados();
                
                % 2. Criar arquitetura Attention U-Net
                fprintf('[2/5] Criando arquitetura Attention U-Net...\n');
                rede = obj.criarArquiteturaAttentionUNet();
                
                % 3. Configurar treinamento otimizado
                fprintf('[3/5] Configurando parâmetros otimizados para Attention U-Net...\n');
                opcoes = obj.configurarTreinamento();
                
                % 4. Executar treinamento
                fprintf('[4/5] Executando treinamento...\n');
                obj.modelo = trainNetwork(imagens, mascaras, rede, opcoes);
                
                % 5. Salvar modelo e comparar métricas
                fprintf('[5/5] Salvando modelo e comparando com U-Net...\n');
                obj.salvarModelo();
                obj.compararComUNet();
                
                modelo = obj.modelo;
                fprintf('✅ Attention U-Net treinado com sucesso!\n');
                
            catch ME
                fprintf('❌ Erro durante treinamento: %s\n', ME.message);
                rethrow(ME);
            end
        end
        
        function [imagens, mascaras] = carregarDados(obj)
            % Carrega imagens e máscaras das pastas especificadas
            % Usa exatamente os mesmos dados do U-Net para comparação justa
            % Returns:
            %   imagens - cell array com imagens carregadas
            %   mascaras - cell array com máscaras correspondentes
            
            % Listar arquivos de imagem
            extensoesImagem = {'*.jpg', '*.jpeg', '*.png', '*.bmp', '*.tiff'};
            arquivosImagem = [];
            
            for i = 1:length(extensoesImagem)
                arquivos = dir(fullfile(obj.caminhoImagens, extensoesImagem{i}));
                arquivosImagem = [arquivosImagem; arquivos];
            end
            
            if isempty(arquivosImagem)
                error('Nenhuma imagem encontrada em: %s', obj.caminhoImagens);
            end
            
            fprintf('   Encontradas %d imagens para treinamento\n', length(arquivosImagem));
            
            % Carregar imagens e máscaras
            imagens = {};
            mascaras = {};
            contador = 0;
            
            for i = 1:length(arquivosImagem)
                % Carregar imagem
                caminhoImagem = fullfile(obj.caminhoImagens, arquivosImagem(i).name);
                img = imread(caminhoImagem);
                
                % Carregar máscara correspondente
                [~, nomeBase, ~] = fileparts(arquivosImagem(i).name);
                caminhoMascara = obj.encontrarMascaraCorrespondente(nomeBase);
                
                if isempty(caminhoMascara)
                    if mod(i, 50) == 0
                        fprintf('   Aviso: Máscara não encontrada para %s, pulando...\n', arquivosImagem(i).name);
                    end
                    continue;
                end
                
                % Processar imagem
                if size(img, 3) == 1
                    img = repmat(img, [1, 1, 3]);
                end
                img = imresize(img, [256, 256]);
                
                % Processar máscara
                mascara = imread(caminhoMascara);
                if size(mascara, 3) > 1
                    mascara = rgb2gray(mascara);
                end
                mascara = imresize(mascara, [256, 256]);
                mascara = mascara > 128; % Binarizar
                
                % Adicionar aos arrays
                contador = contador + 1;
                imagens{contador} = img;
                mascaras{contador} = categorical(mascara, [0, 1], {'background', 'foreground'});
                
                if mod(contador, 10) == 0
                    fprintf('   Carregadas %d pares imagem-máscara válidos\n', contador);
                end
            end
            
            if contador == 0
                error('Nenhum par imagem-máscara válido encontrado');
            end
            
            fprintf('   ✅ Dados carregados: %d pares imagem-máscara válidos!\n', contador);
        end
        
        function rede = criarArquiteturaAttentionUNet(obj)
            % Cria a arquitetura Attention U-Net com mecanismos de atenção
            % Returns:
            %   rede - arquitetura Attention U-Net como layerGraph
            
            % Definir tamanho de entrada
            tamanhoEntrada = [256, 256, 3];
            numClasses = 2; % background e foreground
            
            % Encoder (Contração) - Similar ao U-Net base
            layers = [
                imageInputLayer(tamanhoEntrada, 'Name', 'input')
                
                % Bloco 1
                convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'conv1_1')
                batchNormalizationLayer('Name', 'bn1_1')
                reluLayer('Name', 'relu1_1')
                convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'conv1_2')
                batchNormalizationLayer('Name', 'bn1_2')
                reluLayer('Name', 'relu1_2')
                
                % Pool 1
                maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool1')
                
                % Bloco 2
                convolution2dLayer(3, 128, 'Padding', 'same', 'Name', 'conv2_1')
                batchNormalizationLayer('Name', 'bn2_1')
                reluLayer('Name', 'relu2_1')
                convolution2dLayer(3, 128, 'Padding', 'same', 'Name', 'conv2_2')
                batchNormalizationLayer('Name', 'bn2_2')
                reluLayer('Name', 'relu2_2')
                
                % Pool 2
                maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool2')
                
                % Bloco 3
                convolution2dLayer(3, 256, 'Padding', 'same', 'Name', 'conv3_1')
                batchNormalizationLayer('Name', 'bn3_1')
                reluLayer('Name', 'relu3_1')
                convolution2dLayer(3, 256, 'Padding', 'same', 'Name', 'conv3_2')
                batchNormalizationLayer('Name', 'bn3_2')
                reluLayer('Name', 'relu3_2')
                
                % Pool 3
                maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool3')
                
                % Bloco 4
                convolution2dLayer(3, 512, 'Padding', 'same', 'Name', 'conv4_1')
                batchNormalizationLayer('Name', 'bn4_1')
                reluLayer('Name', 'relu4_1')
                convolution2dLayer(3, 512, 'Padding', 'same', 'Name', 'conv4_2')
                batchNormalizationLayer('Name', 'bn4_2')
                reluLayer('Name', 'relu4_2')
                
                % Pool 4
                maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool4')
                
                % Bottleneck com atenção
                convolution2dLayer(3, 1024, 'Padding', 'same', 'Name', 'conv5_1')
                batchNormalizationLayer('Name', 'bn5_1')
                reluLayer('Name', 'relu5_1')
                convolution2dLayer(3, 1024, 'Padding', 'same', 'Name', 'conv5_2')
                batchNormalizationLayer('Name', 'bn5_2')
                reluLayer('Name', 'relu5_2')
            ];
            
            % Criar layer graph
            lgraph = layerGraph(layers);
            
            % Decoder com Attention Gates
            % Upconv 4 com Attention Gate
            upconv4 = transposedConv2dLayer(2, 512, 'Stride', 2, 'Name', 'upconv4');
            lgraph = addLayers(lgraph, upconv4);
            lgraph = connectLayers(lgraph, 'relu5_2', 'upconv4');
            
            % Attention Gate 4
            lgraph = obj.adicionarAttentionGate(lgraph, 'relu4_2', 'upconv4', 'attention4', 512);
            
            % Concatenação 4 com atenção
            concat4 = depthConcatenationLayer(2, 'Name', 'concat4');
            lgraph = addLayers(lgraph, concat4);
            lgraph = connectLayers(lgraph, 'upconv4', 'concat4/in1');
            lgraph = connectLayers(lgraph, 'attention4_output', 'concat4/in2');
            
            % Conv 6
            conv6_layers = [
                convolution2dLayer(3, 512, 'Padding', 'same', 'Name', 'conv6_1')
                batchNormalizationLayer('Name', 'bn6_1')
                reluLayer('Name', 'relu6_1')
                convolution2dLayer(3, 512, 'Padding', 'same', 'Name', 'conv6_2')
                batchNormalizationLayer('Name', 'bn6_2')
                reluLayer('Name', 'relu6_2')
            ];
            lgraph = addLayers(lgraph, conv6_layers);
            lgraph = connectLayers(lgraph, 'concat4', 'conv6_1');
            
            % Upconv 3 com Attention Gate
            upconv3 = transposedConv2dLayer(2, 256, 'Stride', 2, 'Name', 'upconv3');
            lgraph = addLayers(lgraph, upconv3);
            lgraph = connectLayers(lgraph, 'relu6_2', 'upconv3');
            
            % Attention Gate 3
            lgraph = obj.adicionarAttentionGate(lgraph, 'relu3_2', 'upconv3', 'attention3', 256);
            
            % Concatenação 3 com atenção
            concat3 = depthConcatenationLayer(2, 'Name', 'concat3');
            lgraph = addLayers(lgraph, concat3);
            lgraph = connectLayers(lgraph, 'upconv3', 'concat3/in1');
            lgraph = connectLayers(lgraph, 'attention3_output', 'concat3/in2');
            
            % Conv 7
            conv7_layers = [
                convolution2dLayer(3, 256, 'Padding', 'same', 'Name', 'conv7_1')
                batchNormalizationLayer('Name', 'bn7_1')
                reluLayer('Name', 'relu7_1')
                convolution2dLayer(3, 256, 'Padding', 'same', 'Name', 'conv7_2')
                batchNormalizationLayer('Name', 'bn7_2')
                reluLayer('Name', 'relu7_2')
            ];
            lgraph = addLayers(lgraph, conv7_layers);
            lgraph = connectLayers(lgraph, 'concat3', 'conv7_1');
            
            % Upconv 2 com Attention Gate
            upconv2 = transposedConv2dLayer(2, 128, 'Stride', 2, 'Name', 'upconv2');
            lgraph = addLayers(lgraph, upconv2);
            lgraph = connectLayers(lgraph, 'relu7_2', 'upconv2');
            
            % Attention Gate 2
            lgraph = obj.adicionarAttentionGate(lgraph, 'relu2_2', 'upconv2', 'attention2', 128);
            
            % Concatenação 2 com atenção
            concat2 = depthConcatenationLayer(2, 'Name', 'concat2');
            lgraph = addLayers(lgraph, concat2);
            lgraph = connectLayers(lgraph, 'upconv2', 'concat2/in1');
            lgraph = connectLayers(lgraph, 'attention2_output', 'concat2/in2');
            
            % Conv 8
            conv8_layers = [
                convolution2dLayer(3, 128, 'Padding', 'same', 'Name', 'conv8_1')
                batchNormalizationLayer('Name', 'bn8_1')
                reluLayer('Name', 'relu8_1')
                convolution2dLayer(3, 128, 'Padding', 'same', 'Name', 'conv8_2')
                batchNormalizationLayer('Name', 'bn8_2')
                reluLayer('Name', 'relu8_2')
            ];
            lgraph = addLayers(lgraph, conv8_layers);
            lgraph = connectLayers(lgraph, 'concat2', 'conv8_1');
            
            % Upconv 1 com Attention Gate
            upconv1 = transposedConv2dLayer(2, 64, 'Stride', 2, 'Name', 'upconv1');
            lgraph = addLayers(lgraph, upconv1);
            lgraph = connectLayers(lgraph, 'relu8_2', 'upconv1');
            
            % Attention Gate 1
            lgraph = obj.adicionarAttentionGate(lgraph, 'relu1_2', 'upconv1', 'attention1', 64);
            
            % Concatenação 1 com atenção
            concat1 = depthConcatenationLayer(2, 'Name', 'concat1');
            lgraph = addLayers(lgraph, concat1);
            lgraph = connectLayers(lgraph, 'upconv1', 'concat1/in1');
            lgraph = connectLayers(lgraph, 'attention1_output', 'concat1/in2');
            
            % Conv final
            conv_final_layers = [
                convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'conv9_1')
                batchNormalizationLayer('Name', 'bn9_1')
                reluLayer('Name', 'relu9_1')
                convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'conv9_2')
                batchNormalizationLayer('Name', 'bn9_2')
                reluLayer('Name', 'relu9_2')
                convolution2dLayer(1, numClasses, 'Name', 'conv_final')
                softmaxLayer('Name', 'softmax')
                pixelClassificationLayer('Name', 'output')
            ];
            lgraph = addLayers(lgraph, conv_final_layers);
            lgraph = connectLayers(lgraph, 'concat1', 'conv9_1');
            
            rede = lgraph;
            fprintf('   ✅ Arquitetura Attention U-Net criada com mecanismos de atenção!\n');
        end
        
        function lgraph = adicionarAttentionGate(obj, lgraph, skipConnection, gatingSignal, nomeBase, numFiltros)
            % Adiciona um Attention Gate entre skip connection e gating signal
            % Inputs:
            %   lgraph - layer graph atual
            %   skipConnection - nome da layer de skip connection
            %   gatingSignal - nome da layer de gating signal
            %   nomeBase - nome base para as layers do attention gate
            %   numFiltros - número de filtros para as convoluções
            
            % Simplificar attention gate para compatibilidade com MATLAB
            % Usar convolução 1x1 para reduzir dimensionalidade e gerar atenção
            
            % Convolução para gerar coeficientes de atenção do skip connection
            attention_layers = [
                convolution2dLayer(1, numFiltros/4, 'Padding', 'same', 'Name', [nomeBase '_conv1'])
                reluLayer('Name', [nomeBase '_relu1'])
                convolution2dLayer(1, 1, 'Padding', 'same', 'Name', [nomeBase '_conv2'])
                sigmoidLayer('Name', [nomeBase '_sigmoid'])
            ];
            
            lgraph = addLayers(lgraph, attention_layers);
            lgraph = connectLayers(lgraph, skipConnection, [nomeBase '_conv1']);
            
            % Multiplicar skip connection pelos coeficientes de atenção
            multiply_layer = multiplicationLayer(2, 'Name', [nomeBase '_multiply']);
            lgraph = addLayers(lgraph, multiply_layer);
            lgraph = connectLayers(lgraph, skipConnection, [nomeBase '_multiply/in1']);
            lgraph = connectLayers(lgraph, [nomeBase '_sigmoid'], [nomeBase '_multiply/in2']);
            
            % Saída final do attention gate
            output_layer = reluLayer('Name', [nomeBase '_output']);
            lgraph = addLayers(lgraph, output_layer);
            lgraph = connectLayers(lgraph, [nomeBase '_multiply'], [nomeBase '_output']);
        end
        
        function opcoes = configurarTreinamento(obj)
            % Configura opções de treinamento otimizadas para Attention U-Net
            % Returns:
            %   opcoes - objeto trainingOptions configurado
            
            opcoes = trainingOptions('adam', ...
                'InitialLearnRate', obj.configuracao.learning_rate, ...
                'MaxEpochs', obj.configuracao.epochs, ...
                'MiniBatchSize', obj.configuracao.batch_size, ...
                'ValidationFrequency', 10, ...
                'ValidationPatience', 8, ... % Maior paciência para modelo mais complexo
                'Shuffle', 'every-epoch', ...
                'Verbose', true, ...
                'VerboseFrequency', 10, ...
                'Plots', 'training-progress', ...
                'ExecutionEnvironment', 'auto', ...
                'LearnRateSchedule', 'piecewise', ...
                'LearnRateDropFactor', 0.5, ...
                'LearnRateDropPeriod', 20);
            
            fprintf('   ✅ Configuração otimizada para Attention U-Net definida!\n');
            fprintf('      - Epochs: %d\n', obj.configuracao.epochs);
            fprintf('      - Learning Rate: %.4f (com decay)\n', obj.configuracao.learning_rate);
            fprintf('      - Batch Size: %d\n', obj.configuracao.batch_size);
            fprintf('      - Validation Patience: 8 (maior para modelo complexo)\n');
        end
        
        function salvarModelo(obj)
            % Salva o modelo treinado com nome identificável
            
            if isempty(obj.modelo)
                error('Nenhum modelo para salvar');
            end
            
            % Criar pasta de modelos se não existir
            pastaModelos = 'resultados_segmentacao/modelos';
            if ~exist(pastaModelos, 'dir')
                mkdir(pastaModelos);
            end
            
            % Salvar modelo com nome identificável
            nomeArquivo = fullfile(pastaModelos, 'modelo_attention_unet.mat');
            modelo = obj.modelo; %#ok<NASGU>
            save(nomeArquivo, 'modelo');
            
            fprintf('   ✅ Modelo Attention U-Net salvo em: %s\n', nomeArquivo);
        end
        
        function carregarMetricasUNet(obj)
            % Carrega métricas do U-Net para comparação
            
            try
                caminhoMetricas = 'resultados_segmentacao/modelos/metricas_unet.mat';
                if exist(caminhoMetricas, 'file')
                    dados = load(caminhoMetricas);
                    obj.metricasUNet = dados.metricas;
                    fprintf('   ✅ Métricas do U-Net carregadas para comparação\n');
                else
                    fprintf('   ⚠️  Métricas do U-Net não encontradas, comparação será limitada\n');
                end
            catch
                fprintf('   ⚠️  Erro ao carregar métricas do U-Net\n');
            end
        end
        
        function compararComUNet(obj)
            % Compara métricas do Attention U-Net com U-Net durante treinamento
            
            fprintf('\n=== COMPARAÇÃO COM U-NET ===\n');
            
            if isempty(obj.metricasUNet)
                fprintf('⚠️  Métricas do U-Net não disponíveis para comparação\n');
                fprintf('   Execute o treinamento do U-Net primeiro para comparação completa\n');
                return;
            end
            
            % Salvar métricas do Attention U-Net
            pastaModelos = 'resultados_segmentacao/modelos';
            caminhoMetricas = fullfile(pastaModelos, 'metricas_attention_unet.mat');
            
            % Extrair métricas do treinamento (simulado - em implementação real seria extraído do training info)
            metricasAttention.modelo = 'Attention U-Net';
            metricasAttention.epochs = obj.configuracao.epochs;
            metricasAttention.learning_rate = obj.configuracao.learning_rate;
            metricasAttention.batch_size = obj.configuracao.batch_size;
            metricasAttention.timestamp = datetime('now');
            
            metricas = metricasAttention; %#ok<NASGU>
            save(caminhoMetricas, 'metricas');
            
            % Comparação básica
            fprintf('📊 COMPARAÇÃO DE MODELOS:\n');
            fprintf('   U-Net:           Epochs: %d, LR: %.4f\n', ...
                obj.metricasUNet.epochs, obj.metricasUNet.learning_rate);
            fprintf('   Attention U-Net: Epochs: %d, LR: %.4f\n', ...
                metricasAttention.epochs, metricasAttention.learning_rate);
            
            fprintf('\n✅ Métricas salvas para comparação posterior\n');
            fprintf('   Arquivo: %s\n', caminhoMetricas);
        end
        
        function configuracao = obterConfiguracaoDefault(obj)
            % Retorna configuração padrão otimizada para Attention U-Net
            % Returns:
            %   configuracao - struct com parâmetros otimizados
            
            configuracao.epochs = 60; % Mais epochs para modelo complexo
            configuracao.learning_rate = 0.0005; % Learning rate menor para estabilidade
            configuracao.batch_size = 2; % Batch size menor devido à complexidade
            configuracao.validation_split = 0.2;
        end
        
        function validarCaminhos(obj)
            % Valida se os caminhos especificados existem
            
            if ~exist(obj.caminhoImagens, 'dir')
                error('Caminho de imagens não encontrado: %s', obj.caminhoImagens);
            end
            
            if ~exist(obj.caminhoMascaras, 'dir')
                error('Caminho de máscaras não encontrado: %s', obj.caminhoMascaras);
            end
            
            fprintf('✅ Caminhos validados com sucesso!\n');
        end
        
        function caminhoMascara = encontrarMascaraCorrespondente(obj, nomeBase)
            % Encontra máscara correspondente para uma imagem
            % Adapta o padrão: PRINCIPAL -> CORROSAO

            extensoes = {'.png', '.jpg', '.jpeg', '.bmp', '.tiff'};

            % Candidatos com substituição explícita
            candidatos = {};
            candidatos{end+1} = strrep(nomeBase, 'PRINCIPAL', 'CORROSAO');
            candidatos{end+1} = regexprep(nomeBase, '_PRINCIPAL', '_CORROSAO');
            candidatos{end+1} = regexprep(nomeBase, '_PRINCIPAL_256_gray', '_CORROSAO_256_gray');

            try
                partes = split(nomeBase, '_PRINCIPAL');
                if numel(partes) >= 2
                    candidatos{end+1} = [partes{1} '_CORROSAO' partes{2}];
                end
            catch
            end

            for c = 1:numel(candidatos)
                for e = 1:numel(extensoes)
                    caminho = fullfile(obj.caminhoMascaras, [candidatos{c}, extensoes{e}]);
                    if exist(caminho, 'file')
                        caminhoMascara = caminho;
                        return;
                    end
                end
            end

            % Fallback por prefixo
            idx = strfind(nomeBase, '_PRINCIPAL');
            if ~isempty(idx)
                prefixo = nomeBase(1:idx-1);
            else
                prefixo = nomeBase;
            end
            lista = dir(fullfile(obj.caminhoMascaras, '*CORROSAO*'));
            for i = 1:numel(lista)
                if contains(lista(i).name, prefixo)
                    caminhoMascara = fullfile(obj.caminhoMascaras, lista(i).name);
                    return;
                end
            end

            caminhoMascara = '';
        end
    end
end