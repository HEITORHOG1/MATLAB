classdef TreinadorUNet < handle
    % TreinadorUNet - Classe para treinamento do modelo U-Net
    % Esta classe encapsula todo o processo de treinamento do modelo U-Net
    % incluindo carregamento de dados, criação da arquitetura e treinamento
    
    properties
        caminhoImagens      % Caminho para imagens de treinamento
        caminhoMascaras     % Caminho para máscaras de treinamento
        configuracao        % Configurações de treinamento
        modelo              % Modelo treinado
    end
    
    methods
        function obj = TreinadorUNet(caminhoImagens, caminhoMascaras)
            % Construtor da classe TreinadorUNet
            % Inputs:
            %   caminhoImagens - string com caminho para pasta de imagens
            %   caminhoMascaras - string com caminho para pasta de máscaras
            
            obj.caminhoImagens = caminhoImagens;
            obj.caminhoMascaras = caminhoMascaras;
            obj.configuracao = obj.obterConfiguracaoDefault();
            obj.modelo = [];
            
            % Validar caminhos
            obj.validarCaminhos();
        end
        
        function modelo = treinar(obj)
            % Executa o treinamento completo do modelo U-Net
            % Returns:
            %   modelo - modelo U-Net treinado
            
            fprintf('=== INICIANDO TREINAMENTO U-NET ===\n');
            
            try
                % 1. Carregar dados
                fprintf('[1/5] Carregando dados de treinamento...\n');
                [imagens, mascaras] = obj.carregarDados();
                
                % 2. Criar arquitetura U-Net
                fprintf('[2/5] Criando arquitetura U-Net...\n');
                rede = obj.criarArquiteturaUNet();
                
                % 3. Configurar treinamento
                fprintf('[3/5] Configurando parâmetros de treinamento...\n');
                opcoes = obj.configurarTreinamento();
                
                % 4. Executar treinamento
                fprintf('[4/5] Executando treinamento...\n');
                
                % Combinar datastores
                ds = combine(imagens, mascaras);
                
                obj.modelo = trainNetwork(ds, rede, opcoes);
                
                % 5. Salvar modelo
                fprintf('[5/5] Salvando modelo treinado...\n');
                obj.salvarModelo();
                
                modelo = obj.modelo;
                fprintf('✅ U-Net treinado com sucesso!\n');
                
            catch ME
                fprintf('❌ Erro durante treinamento: %s\n', ME.message);
                rethrow(ME);
            end
        end
        
        function [imagens, mascaras] = carregarDados(obj)
            % Carrega imagens e máscaras das pastas especificadas
            % Returns:
            %   imagens - datastore de imagens
            %   mascaras - datastore de máscaras
            
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
            
            % Criar listas de caminhos válidos
            caminhosImagens = {};
            caminhosMascaras = {};
            contador = 0;
            
            for i = 1:length(arquivosImagem)
                % Caminho da imagem
                caminhoImagem = fullfile(obj.caminhoImagens, arquivosImagem(i).name);
                
                % Encontrar máscara correspondente
                [~, nomeBase, ~] = fileparts(arquivosImagem(i).name);
                caminhoMascara = obj.encontrarMascaraCorrespondente(nomeBase);
                
                if isempty(caminhoMascara)
                    if mod(i, 50) == 0
                        fprintf('   Aviso: Máscara não encontrada para %s, pulando...\n', arquivosImagem(i).name);
                    end
                    continue;
                end
                
                % Adicionar aos arrays de caminhos
                contador = contador + 1;
                caminhosImagens{contador} = caminhoImagem;
                caminhosMascaras{contador} = caminhoMascara;
                
                if mod(contador, 10) == 0
                    fprintf('   Carregadas %d pares imagem-máscara válidos\n', contador);
                end
            end
            
            if contador == 0
                error('Nenhum par imagem-máscara válido encontrado');
            end
            
            fprintf('   ✅ Dados carregados: %d pares imagem-máscara válidos!\n', contador);
            
            % Criar datastores
            imagens = imageDatastore(caminhosImagens);
            mascaras = pixelLabelDatastore(caminhosMascaras, {'background', 'foreground'}, [0, 1]);
            
            % Configurar transformações
            imagens.ReadFcn = @(filename) obj.preprocessarImagem(filename);
            mascaras.ReadFcn = @(filename) obj.preprocessarMascara(filename);
        end
        
        function img = preprocessarImagem(obj, filename)
            % Preprocessa uma imagem individual
            img = imread(filename);
            
            % Converter para RGB se necessário
            if size(img, 3) == 1
                img = repmat(img, [1, 1, 3]);
            end
            
            % Redimensionar
            img = imresize(img, [256, 256]);
            
            % Normalizar para [0, 1]
            img = im2double(img);
        end
        
        function mascara = preprocessarMascara(obj, filename)
            % Preprocessa uma máscara individual
            mascara = imread(filename);
            
            % Converter para grayscale se necessário
            if size(mascara, 3) > 1
                mascara = rgb2gray(mascara);
            end
            
            % Redimensionar
            mascara = imresize(mascara, [256, 256]);
            
            % Binarizar e converter para categorical
            mascara = mascara > 128;
            mascara = categorical(mascara, [0, 1], {'background', 'foreground'});
        end
        
        function rede = criarArquiteturaUNet(obj)
            % Cria a arquitetura U-Net otimizada para segmentação
            % Returns:
            %   rede - arquitetura U-Net como layerGraph
            
            % Definir tamanho de entrada
            tamanhoEntrada = [256, 256, 3];
            numClasses = 2; % background e foreground
            
            % Encoder (Contração)
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
                
                % Bottleneck
                convolution2dLayer(3, 1024, 'Padding', 'same', 'Name', 'conv5_1')
                batchNormalizationLayer('Name', 'bn5_1')
                reluLayer('Name', 'relu5_1')
                convolution2dLayer(3, 1024, 'Padding', 'same', 'Name', 'conv5_2')
                batchNormalizationLayer('Name', 'bn5_2')
                reluLayer('Name', 'relu5_2')
            ];
            
            % Criar layer graph
            lgraph = layerGraph(layers);
            
            % Decoder (Expansão) com skip connections
            % Upconv 4
            upconv4 = transposedConv2dLayer(2, 512, 'Stride', 2, 'Name', 'upconv4');
            lgraph = addLayers(lgraph, upconv4);
            lgraph = connectLayers(lgraph, 'relu5_2', 'upconv4');
            
            % Concatenação 4
            concat4 = depthConcatenationLayer(2, 'Name', 'concat4');
            lgraph = addLayers(lgraph, concat4);
            lgraph = connectLayers(lgraph, 'upconv4', 'concat4/in1');
            lgraph = connectLayers(lgraph, 'relu4_2', 'concat4/in2');
            
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
            
            % Upconv 3
            upconv3 = transposedConv2dLayer(2, 256, 'Stride', 2, 'Name', 'upconv3');
            lgraph = addLayers(lgraph, upconv3);
            lgraph = connectLayers(lgraph, 'relu6_2', 'upconv3');
            
            % Concatenação 3
            concat3 = depthConcatenationLayer(2, 'Name', 'concat3');
            lgraph = addLayers(lgraph, concat3);
            lgraph = connectLayers(lgraph, 'upconv3', 'concat3/in1');
            lgraph = connectLayers(lgraph, 'relu3_2', 'concat3/in2');
            
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
            
            % Upconv 2
            upconv2 = transposedConv2dLayer(2, 128, 'Stride', 2, 'Name', 'upconv2');
            lgraph = addLayers(lgraph, upconv2);
            lgraph = connectLayers(lgraph, 'relu7_2', 'upconv2');
            
            % Concatenação 2
            concat2 = depthConcatenationLayer(2, 'Name', 'concat2');
            lgraph = addLayers(lgraph, concat2);
            lgraph = connectLayers(lgraph, 'upconv2', 'concat2/in1');
            lgraph = connectLayers(lgraph, 'relu2_2', 'concat2/in2');
            
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
            
            % Upconv 1
            upconv1 = transposedConv2dLayer(2, 64, 'Stride', 2, 'Name', 'upconv1');
            lgraph = addLayers(lgraph, upconv1);
            lgraph = connectLayers(lgraph, 'relu8_2', 'upconv1');
            
            % Concatenação 1
            concat1 = depthConcatenationLayer(2, 'Name', 'concat1');
            lgraph = addLayers(lgraph, concat1);
            lgraph = connectLayers(lgraph, 'upconv1', 'concat1/in1');
            lgraph = connectLayers(lgraph, 'relu1_2', 'concat1/in2');
            
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
            fprintf('   ✅ Arquitetura U-Net criada com sucesso!\n');
        end
        
        function opcoes = configurarTreinamento(obj)
            % Configura opções de treinamento
            % Returns:
            %   opcoes - objeto trainingOptions configurado
            
            opcoes = trainingOptions('adam', ...
                'InitialLearnRate', obj.configuracao.learning_rate, ...
                'MaxEpochs', obj.configuracao.epochs, ...
                'MiniBatchSize', obj.configuracao.batch_size, ...
                'ValidationFrequency', 10, ...
                'ValidationPatience', 5, ...
                'Shuffle', 'every-epoch', ...
                'Verbose', true, ...
                'VerboseFrequency', 10, ...
                'Plots', 'training-progress', ...
                'ExecutionEnvironment', 'auto');
            
            fprintf('   ✅ Configuração de treinamento definida!\n');
            fprintf('      - Epochs: %d\n', obj.configuracao.epochs);
            fprintf('      - Learning Rate: %.4f\n', obj.configuracao.learning_rate);
            fprintf('      - Batch Size: %d\n', obj.configuracao.batch_size);
        end
        
        function salvarModelo(obj)
            % Salva o modelo treinado
            
            if isempty(obj.modelo)
                error('Nenhum modelo para salvar');
            end
            
            % Criar pasta de modelos se não existir
            pastaModelos = 'resultados_segmentacao/modelos';
            if ~exist(pastaModelos, 'dir')
                mkdir(pastaModelos);
            end
            
            % Salvar modelo
            nomeArquivo = fullfile(pastaModelos, 'modelo_unet.mat');
            modelo = obj.modelo; %#ok<NASGU>
            save(nomeArquivo, 'modelo');
            
            fprintf('   ✅ Modelo salvo em: %s\n', nomeArquivo);
        end
        
        function configuracao = obterConfiguracaoDefault(obj)
            % Retorna configuração padrão de treinamento
            % Returns:
            %   configuracao - struct com parâmetros padrão
            
            configuracao.epochs = 50;
            configuracao.learning_rate = 0.001;
            configuracao.batch_size = 4; % Reduzido para evitar problemas de memória
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
            % Adapta especificamente o padrão: PRINCIPAL -> CORROSAO

            extensoes = {'.png', '.jpg', '.jpeg', '.bmp', '.tiff'};

            % Candidatos base com substituição explícita
            candidatos = {};
            candidatos{end+1} = strrep(nomeBase, 'PRINCIPAL', 'CORROSAO');
            candidatos{end+1} = regexprep(nomeBase, '_PRINCIPAL', '_CORROSAO');
            candidatos{end+1} = regexprep(nomeBase, '_PRINCIPAL_256_gray', '_CORROSAO_256_gray');

            % Também tentar remover sufixos numéricos longos e manter o id base
            % Ex: Whisk_xxx_1_PRINCIPAL_256_gray -> Whisk_xxx_1_CORROSAO_256_gray
            try
                partes = split(nomeBase, '_PRINCIPAL');
                if numel(partes) >= 2
                    candidatos{end+1} = [partes{1} '_CORROSAO' partes{2}];
                end
            catch
            end

            % Tentar candidatos com extensões
            for c = 1:numel(candidatos)
                for e = 1:numel(extensoes)
                    caminho = fullfile(obj.caminhoMascaras, [candidatos{c}, extensoes{e}]);
                    if exist(caminho, 'file')
                        caminhoMascara = caminho;
                        return;
                    end
                end
            end

            % Fallback: procurar por correspondência forte usando o prefixo até '_1_'
            idx = strfind(nomeBase, '_PRINCIPAL');
            if ~isempty(idx)
                prefixo = nomeBase(1:idx-1); % até antes de _PRINCIPAL
            else
                prefixo = nomeBase;
            end
            % Preferir arquivos que contenham o prefixo e 'CORROSAO'
            lista = dir(fullfile(obj.caminhoMascaras, '*CORROSAO*'));
            for i = 1:numel(lista)
                if contains(lista(i).name, prefixo)
                    caminhoMascara = fullfile(obj.caminhoMascaras, lista(i).name);
                    return;
                end
            end

            % Não encontrado
            caminhoMascara = '';
        end
    end
end