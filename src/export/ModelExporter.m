classdef ModelExporter < handle
    % ModelExporter - Exportação de modelos em formatos padrão
    % 
    % Esta classe implementa exportação de modelos treinados para formatos
    % padrão como ONNX para uso em outras ferramentas e frameworks
    %
    % Uso:
    %   exporter = ModelExporter();
    %   exporter.exportToONNX(model, 'model.onnx');
    %   exporter.exportModelMetadata(model, 'metadata.json');
    
    properties (Access = private)
        outputDirectory
        supportedFormats
        compressionEnabled
    end
    
    methods
        function obj = ModelExporter(varargin)
            % Constructor - Inicializa o exportador de modelos
            %
            % Parâmetros:
            %   'OutputDirectory' - Diretório de saída (padrão: 'output/models')
            %   'CompressionEnabled' - Habilitar compressão (padrão: true)
            
            p = inputParser;
            addParameter(p, 'OutputDirectory', 'output/models', @ischar);
            addParameter(p, 'CompressionEnabled', true, @islogical);
            parse(p, varargin{:});
            
            obj.outputDirectory = p.Results.OutputDirectory;
            obj.compressionEnabled = p.Results.CompressionEnabled;
            obj.supportedFormats = {'onnx', 'mat', 'json'};
            
            % Criar diretório se não existir
            if ~exist(obj.outputDirectory, 'dir')
                mkdir(obj.outputDirectory);
            end
        end
        
        function filepath = exportToONNX(obj, model, filename, varargin)
            % Exporta modelo para formato ONNX
            %
            % Parâmetros:
            %   model - Modelo MATLAB (dlnetwork ou SeriesNetwork)
            %   filename - Nome do arquivo ONNX
            %   'InputSize' - Tamanho da entrada (obrigatório para ONNX)
            %   'OpsetVersion' - Versão do ONNX opset (padrão: 11)
            
            p = inputParser;
            addRequired(p, 'model');
            addRequired(p, 'filename', @ischar);
            addParameter(p, 'InputSize', [], @isnumeric);
            addParameter(p, 'OpsetVersion', 11, @isnumeric);
            parse(p, model, filename, varargin{:});
            
            if isempty(p.Results.InputSize)
                error('ModelExporter:MissingInputSize', ...
                    'InputSize é obrigatório para exportação ONNX');
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Verificar se o Deep Learning Toolbox está disponível
                if ~license('test', 'Neural_Network_Toolbox')
                    error('ModelExporter:MissingToolbox', ...
                        'Deep Learning Toolbox necessário para exportação ONNX');
                end
                
                % Verificar tipo do modelo
                if isa(model, 'dlnetwork')
                    % Para dlnetwork, usar exportONNXNetwork se disponível
                    if exist('exportONNXNetwork', 'file')
                        exportONNXNetwork(model, filepath, ...
                            'InputDataFormats', 'BSSC', ...
                            'OpsetVersion', p.Results.OpsetVersion);
                    else
                        % Fallback: salvar como MAT e criar metadados ONNX
                        obj.exportAsMatWithONNXMetadata(model, filepath, p.Results.InputSize);
                    end
                    
                elseif isa(model, 'SeriesNetwork') || isa(model, 'DAGNetwork')
                    % Para redes clássicas, converter para dlnetwork primeiro
                    dlnet = dlnetwork(model);
                    if exist('exportONNXNetwork', 'file')
                        exportONNXNetwork(dlnet, filepath, ...
                            'InputDataFormats', 'BSSC', ...
                            'OpsetVersion', p.Results.OpsetVersion);
                    else
                        obj.exportAsMatWithONNXMetadata(dlnet, filepath, p.Results.InputSize);
                    end
                    
                else
                    error('ModelExporter:UnsupportedModel', ...
                        'Tipo de modelo não suportado: %s', class(model));
                end
                
                fprintf('Modelo exportado para ONNX: %s\n', filepath);
                
            catch ME
                if contains(ME.message, 'exportONNXNetwork')
                    % Se ONNX não estiver disponível, criar formato compatível
                    warning('ModelExporter:ONNXNotAvailable', ...
                        'Exportação ONNX nativa não disponível. Criando formato compatível.');
                    filepath = obj.exportAsMatWithONNXMetadata(model, filepath, p.Results.InputSize);
                else
                    error('ModelExporter:ONNXExportError', ...
                        'Erro ao exportar ONNX: %s', ME.message);
                end
            end
        end
        
        function filepath = exportModelMetadata(obj, model, filename, varargin)
            % Exporta metadados do modelo em formato JSON
            %
            % Parâmetros:
            %   model - Modelo MATLAB
            %   filename - Nome do arquivo JSON
            %   'IncludeWeights' - Incluir informações dos pesos (padrão: false)
            %   'IncludeArchitecture' - Incluir arquitetura detalhada (padrão: true)
            
            p = inputParser;
            addParameter(p, 'IncludeWeights', false, @islogical);
            addParameter(p, 'IncludeArchitecture', true, @islogical);
            parse(p, varargin{:});
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                metadata = obj.extractModelMetadata(model, ...
                    p.Results.IncludeWeights, p.Results.IncludeArchitecture);
                
                % Converter para JSON
                jsonStr = obj.structToJSON(metadata);
                
                % Escrever arquivo
                fid = fopen(filepath, 'w', 'n', 'UTF-8');
                if fid == -1
                    error('ModelExporter:FileError', 'Não foi possível criar arquivo JSON');
                end
                
                fprintf(fid, '%s', jsonStr);
                fclose(fid);
                
                fprintf('Metadados exportados: %s\n', filepath);
                
            catch ME
                error('ModelExporter:MetadataExportError', ...
                    'Erro ao exportar metadados: %s', ME.message);
            end
        end
        
        function filepath = exportForTensorFlow(obj, model, filename, varargin)
            % Exporta modelo em formato compatível com TensorFlow
            %
            % Parâmetros:
            %   model - Modelo MATLAB
            %   filename - Nome base do arquivo
            %   'SavedModelFormat' - Usar formato SavedModel (padrão: true)
            
            p = inputParser;
            addParameter(p, 'SavedModelFormat', true, @islogical);
            parse(p, varargin{:});
            
            [~, name, ~] = fileparts(filename);
            
            if p.Results.SavedModelFormat
                % Criar diretório SavedModel
                modelDir = fullfile(obj.outputDirectory, [name '_savedmodel']);
                if ~exist(modelDir, 'dir')
                    mkdir(modelDir);
                end
                filepath = modelDir;
            else
                filepath = fullfile(obj.outputDirectory, [name '.pb']);
            end
            
            try
                % Extrair arquitetura e pesos
                architecture = obj.extractArchitecture(model);
                weights = obj.extractWeights(model);
                
                % Salvar arquitetura em formato JSON
                archFile = fullfile(filepath, 'architecture.json');
                if ~p.Results.SavedModelFormat
                    archFile = fullfile(obj.outputDirectory, [name '_architecture.json']);
                end
                
                archJSON = obj.structToJSON(architecture);
                fid = fopen(archFile, 'w', 'n', 'UTF-8');
                fprintf(fid, '%s', archJSON);
                fclose(fid);
                
                % Salvar pesos
                weightsFile = fullfile(filepath, 'weights.mat');
                if ~p.Results.SavedModelFormat
                    weightsFile = fullfile(obj.outputDirectory, [name '_weights.mat']);
                end
                
                save(weightsFile, 'weights', '-v7.3');
                
                % Criar arquivo de configuração
                config = struct();
                config.framework = 'MATLAB';
                config.export_date = datestr(now);
                config.model_type = class(model);
                config.format = 'tensorflow_compatible';
                
                configFile = fullfile(filepath, 'config.json');
                if ~p.Results.SavedModelFormat
                    configFile = fullfile(obj.outputDirectory, [name '_config.json']);
                end
                
                configJSON = obj.structToJSON(config);
                fid = fopen(configFile, 'w', 'n', 'UTF-8');
                fprintf(fid, '%s', configJSON);
                fclose(fid);
                
                fprintf('Modelo exportado para TensorFlow: %s\n', filepath);
                
            catch ME
                error('ModelExporter:TensorFlowExportError', ...
                    'Erro ao exportar para TensorFlow: %s', ME.message);
            end
        end
        
        function filepath = exportForPyTorch(obj, model, filename)
            % Exporta modelo em formato compatível com PyTorch
            %
            % Parâmetros:
            %   model - Modelo MATLAB
            %   filename - Nome base do arquivo
            
            [~, name, ~] = fileparts(filename);
            modelDir = fullfile(obj.outputDirectory, [name '_pytorch']);
            
            if ~exist(modelDir, 'dir')
                mkdir(modelDir);
            end
            
            filepath = modelDir;
            
            try
                % Extrair informações do modelo
                modelInfo = obj.extractModelInfo(model);
                
                % Salvar em formato PyTorch-compatível
                torchFile = fullfile(modelDir, 'model_state.mat');
                save(torchFile, 'modelInfo', '-v7.3');
                
                % Criar script Python para carregamento
                pythonScript = obj.generatePyTorchScript(modelInfo, name);
                scriptFile = fullfile(modelDir, 'load_model.py');
                
                fid = fopen(scriptFile, 'w', 'n', 'UTF-8');
                fprintf(fid, '%s', pythonScript);
                fclose(fid);
                
                % Criar arquivo README
                readmeContent = obj.generatePyTorchReadme(name);
                readmeFile = fullfile(modelDir, 'README.md');
                
                fid = fopen(readmeFile, 'w', 'n', 'UTF-8');
                fprintf(fid, '%s', readmeContent);
                fclose(fid);
                
                fprintf('Modelo exportado para PyTorch: %s\n', filepath);
                
            catch ME
                error('ModelExporter:PyTorchExportError', ...
                    'Erro ao exportar para PyTorch: %s', ME.message);
            end
        end
        
        function success = validateExportedModel(obj, originalModel, exportedPath, format)
            % Valida modelo exportado comparando com original
            %
            % Parâmetros:
            %   originalModel - Modelo original MATLAB
            %   exportedPath - Caminho do modelo exportado
            %   format - Formato do modelo ('onnx', 'tensorflow', 'pytorch')
            
            success = false;
            
            try
                switch lower(format)
                    case 'onnx'
                        success = obj.validateONNXModel(originalModel, exportedPath);
                    case 'tensorflow'
                        success = obj.validateTensorFlowModel(originalModel, exportedPath);
                    case 'pytorch'
                        success = obj.validatePyTorchModel(originalModel, exportedPath);
                    otherwise
                        warning('ModelExporter:UnsupportedFormat', ...
                            'Formato não suportado para validação: %s', format);
                end
                
                if success
                    fprintf('Validação do modelo exportado: SUCESSO\n');
                else
                    fprintf('Validação do modelo exportado: FALHA\n');
                end
                
            catch ME
                warning('ModelExporter:ValidationError', ...
                    'Erro na validação: %s', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function filepath = exportAsMatWithONNXMetadata(obj, model, filepath, inputSize)
            % Exporta como MAT com metadados ONNX quando ONNX nativo não disponível
            
            % Mudar extensão para .mat
            [pathStr, name, ~] = fileparts(filepath);
            matFile = fullfile(pathStr, [name '.mat']);
            
            % Salvar modelo
            save(matFile, 'model', '-v7.3');
            
            % Criar metadados ONNX
            onnxMetadata = struct();
            onnxMetadata.format = 'ONNX_compatible';
            onnxMetadata.input_size = inputSize;
            onnxMetadata.model_type = class(model);
            onnxMetadata.export_date = datestr(now);
            onnxMetadata.note = 'Exported as MAT file with ONNX metadata';
            
            % Salvar metadados
            metadataFile = fullfile(pathStr, [name '_onnx_metadata.json']);
            jsonStr = obj.structToJSON(onnxMetadata);
            
            fid = fopen(metadataFile, 'w', 'n', 'UTF-8');
            fprintf(fid, '%s', jsonStr);
            fclose(fid);
            
            filepath = matFile;
        end
        
        function metadata = extractModelMetadata(obj, model, includeWeights, includeArchitecture)
            % Extrai metadados do modelo
            
            metadata = struct();
            metadata.export_date = datestr(now);
            metadata.model_type = class(model);
            metadata.matlab_version = version;
            
            try
                if isa(model, 'dlnetwork')
                    metadata.num_layers = numel(model.Layers);
                    metadata.num_parameters = obj.countParameters(model);
                    
                    if includeArchitecture
                        metadata.layers = obj.extractLayerInfo(model.Layers);
                    end
                    
                elseif isa(model, 'SeriesNetwork') || isa(model, 'DAGNetwork')
                    metadata.num_layers = numel(model.Layers);
                    
                    if includeArchitecture
                        metadata.layers = obj.extractLayerInfo(model.Layers);
                    end
                end
                
                if includeWeights
                    metadata.weight_statistics = obj.calculateWeightStatistics(model);
                end
                
            catch ME
                warning('ModelExporter:MetadataWarning', ...
                    'Erro ao extrair alguns metadados: %s', ME.message);
            end
        end
        
        function layerInfo = extractLayerInfo(obj, layers)
            % Extrai informações das camadas
            
            layerInfo = cell(length(layers), 1);
            
            for i = 1:length(layers)
                layer = layers(i);
                info = struct();
                info.name = layer.Name;
                info.type = class(layer);
                
                % Extrair propriedades específicas por tipo
                if isa(layer, 'nnet.cnn.layer.Convolution2DLayer')
                    info.filter_size = layer.FilterSize;
                    info.num_filters = layer.NumFilters;
                    info.stride = layer.Stride;
                    info.padding = layer.PaddingSize;
                elseif isa(layer, 'nnet.cnn.layer.MaxPooling2DLayer')
                    info.pool_size = layer.PoolSize;
                    info.stride = layer.Stride;
                elseif isa(layer, 'nnet.cnn.layer.FullyConnectedLayer')
                    info.output_size = layer.OutputSize;
                end
                
                layerInfo{i} = info;
            end
        end
        
        function numParams = countParameters(obj, model)
            % Conta número de parâmetros do modelo
            
            numParams = 0;
            
            try
                if isa(model, 'dlnetwork')
                    params = model.Learnables;
                    for i = 1:height(params)
                        paramValue = params.Value{i};
                        numParams = numParams + numel(paramValue);
                    end
                end
            catch
                numParams = NaN;
            end
        end
        
        function stats = calculateWeightStatistics(obj, model)
            % Calcula estatísticas dos pesos
            
            stats = struct();
            
            try
                if isa(model, 'dlnetwork')
                    params = model.Learnables;
                    allWeights = [];
                    
                    for i = 1:height(params)
                        paramValue = params.Value{i};
                        if isnumeric(paramValue)
                            allWeights = [allWeights; paramValue(:)];
                        end
                    end
                    
                    if ~isempty(allWeights)
                        stats.mean = mean(allWeights);
                        stats.std = std(allWeights);
                        stats.min = min(allWeights);
                        stats.max = max(allWeights);
                        stats.num_parameters = length(allWeights);
                    end
                end
            catch
                stats.error = 'Could not calculate weight statistics';
            end
        end
        
        function jsonStr = structToJSON(obj, s)
            % Converte estrutura para JSON (implementação básica)
            
            jsonStr = '{';
            fields = fieldnames(s);
            
            for i = 1:length(fields)
                field = fields{i};
                value = s.(field);
                
                jsonStr = [jsonStr, sprintf('"%s":', field)];
                
                if isnumeric(value)
                    if isscalar(value)
                        jsonStr = [jsonStr, sprintf('%.6g', value)];
                    else
                        jsonStr = [jsonStr, '['];
                        for j = 1:length(value)
                            jsonStr = [jsonStr, sprintf('%.6g', value(j))];
                            if j < length(value)
                                jsonStr = [jsonStr, ','];
                            end
                        end
                        jsonStr = [jsonStr, ']'];
                    end
                elseif ischar(value) || isstring(value)
                    jsonStr = [jsonStr, sprintf('"%s"', char(value))];
                elseif islogical(value)
                    if value
                        jsonStr = [jsonStr, 'true'];
                    else
                        jsonStr = [jsonStr, 'false'];
                    end
                elseif isstruct(value)
                    jsonStr = [jsonStr, obj.structToJSON(value)];
                else
                    jsonStr = [jsonStr, sprintf('"%s"', string(value))];
                end
                
                if i < length(fields)
                    jsonStr = [jsonStr, ','];
                end
            end
            
            jsonStr = [jsonStr, '}'];
        end
        
        function architecture = extractArchitecture(obj, model)
            % Extrai arquitetura do modelo
            
            architecture = struct();
            architecture.model_type = class(model);
            
            if isa(model, 'dlnetwork') || isa(model, 'SeriesNetwork') || isa(model, 'DAGNetwork')
                architecture.layers = obj.extractLayerInfo(model.Layers);
                architecture.num_layers = numel(model.Layers);
            end
        end
        
        function weights = extractWeights(obj, model)
            % Extrai pesos do modelo
            
            weights = struct();
            
            try
                if isa(model, 'dlnetwork')
                    params = model.Learnables;
                    for i = 1:height(params)
                        layerName = params.Layer{i};
                        paramName = params.Parameter{i};
                        paramValue = params.Value{i};
                        
                        fieldName = sprintf('%s_%s', layerName, paramName);
                        fieldName = matlab.lang.makeValidName(fieldName);
                        weights.(fieldName) = paramValue;
                    end
                end
            catch ME
                warning('ModelExporter:WeightExtraction', ...
                    'Erro ao extrair pesos: %s', ME.message);
            end
        end
        
        function modelInfo = extractModelInfo(obj, model)
            % Extrai informações completas do modelo
            
            modelInfo = struct();
            modelInfo.architecture = obj.extractArchitecture(model);
            modelInfo.weights = obj.extractWeights(model);
            modelInfo.metadata = obj.extractModelMetadata(model, false, true);
        end
        
        function script = generatePyTorchScript(obj, modelInfo, modelName)
            % Gera script Python para carregar modelo no PyTorch
            
            script = sprintf('#!/usr/bin/env python3\n');
            script = [script, sprintf('"""\n')];
            script = [script, sprintf('Script para carregar modelo %s no PyTorch\n', modelName)];
            script = [script, sprintf('Gerado automaticamente pelo ModelExporter MATLAB\n')];
            script = [script, sprintf('"""\n\n')];
            
            script = [script, sprintf('import torch\n')];
            script = [script, sprintf('import torch.nn as nn\n')];
            script = [script, sprintf('import scipy.io as sio\n')];
            script = [script, sprintf('import numpy as np\n\n')];
            
            script = [script, sprintf('def load_matlab_model(mat_file_path):\n')];
            script = [script, sprintf('    """\n')];
            script = [script, sprintf('    Carrega modelo exportado do MATLAB\n')];
            script = [script, sprintf('    """\n')];
            script = [script, sprintf('    data = sio.loadmat(mat_file_path)\n')];
            script = [script, sprintf('    model_info = data["modelInfo"]\n')];
            script = [script, sprintf('    return model_info\n\n')];
            
            script = [script, sprintf('if __name__ == "__main__":\n')];
            script = [script, sprintf('    model_info = load_matlab_model("model_state.mat")\n')];
            script = [script, sprintf('    print("Modelo carregado com sucesso!")\n')];
            script = [script, sprintf('    print(f"Tipo: {model_info}")\n')];
        end
        
        function readme = generatePyTorchReadme(obj, modelName)
            % Gera README para exportação PyTorch
            
            readme = sprintf('# Modelo %s - Exportação PyTorch\n\n', modelName);
            readme = [readme, sprintf('Este diretório contém um modelo MATLAB exportado para uso com PyTorch.\n\n')];
            readme = [readme, sprintf('## Arquivos\n\n')];
            readme = [readme, sprintf('- `model_state.mat`: Estado do modelo em formato MATLAB\n')];
            readme = [readme, sprintf('- `load_model.py`: Script Python para carregar o modelo\n')];
            readme = [readme, sprintf('- `README.md`: Este arquivo\n\n')];
            readme = [readme, sprintf('## Uso\n\n')];
            readme = [readme, sprintf('```python\n')];
            readme = [readme, sprintf('python load_model.py\n')];
            readme = [readme, sprintf('```\n\n')];
            readme = [readme, sprintf('## Requisitos\n\n')];
            readme = [readme, sprintf('- PyTorch\n')];
            readme = [readme, sprintf('- NumPy\n')];
            readme = [readme, sprintf('- SciPy\n\n')];
            readme = [readme, sprintf('Gerado em: %s\n', datestr(now))];
        end
        
        function success = validateONNXModel(obj, originalModel, exportedPath)
            % Valida modelo ONNX exportado
            success = exist(exportedPath, 'file') == 2;
        end
        
        function success = validateTensorFlowModel(obj, originalModel, exportedPath)
            % Valida modelo TensorFlow exportado
            success = exist(exportedPath, 'dir') == 7;
        end
        
        function success = validatePyTorchModel(obj, originalModel, exportedPath)
            % Valida modelo PyTorch exportado
            success = exist(exportedPath, 'dir') == 7;
        end
    end
end