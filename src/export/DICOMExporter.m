classdef DICOMExporter < handle
    % DICOMExporter - Geração de metadados compatíveis com padrões médicos
    % 
    % Esta classe implementa exportação de dados e metadados compatíveis
    % com padrões médicos como DICOM quando aplicável
    %
    % Uso:
    %   exporter = DICOMExporter();
    %   exporter.exportSegmentationAsDICOM(segmentation, 'seg.dcm');
    %   exporter.createDICOMMetadata(imageData, metadata);
    
    properties (Access = private)
        outputDirectory
        institutionName
        manufacturerName
        softwareVersion
        studyDescription
    end
    
    methods
        function obj = DICOMExporter(varargin)
            % Constructor - Inicializa o exportador DICOM
            %
            % Parâmetros:
            %   'OutputDirectory' - Diretório de saída (padrão: 'output/dicom')
            %   'InstitutionName' - Nome da instituição
            %   'ManufacturerName' - Nome do fabricante (padrão: 'MATLAB System')
            %   'SoftwareVersion' - Versão do software
            %   'StudyDescription' - Descrição do estudo
            
            p = inputParser;
            addParameter(p, 'OutputDirectory', 'output/dicom', @ischar);
            addParameter(p, 'InstitutionName', 'Research Institution', @ischar);
            addParameter(p, 'ManufacturerName', 'MATLAB System', @ischar);
            addParameter(p, 'SoftwareVersion', version, @ischar);
            addParameter(p, 'StudyDescription', 'Image Segmentation Study', @ischar);
            parse(p, varargin{:});
            
            obj.outputDirectory = p.Results.OutputDirectory;
            obj.institutionName = p.Results.InstitutionName;
            obj.manufacturerName = p.Results.ManufacturerName;
            obj.softwareVersion = p.Results.SoftwareVersion;
            obj.studyDescription = p.Results.StudyDescription;
            
            % Criar diretório se não existir
            if ~exist(obj.outputDirectory, 'dir')
                mkdir(obj.outputDirectory);
            end
        end
        
        function filepath = exportSegmentationAsDICOM(obj, segmentation, filename, varargin)
            % Exporta segmentação como arquivo DICOM
            %
            % Parâmetros:
            %   segmentation - Máscara de segmentação
            %   filename - Nome do arquivo DICOM
            %   'PatientName' - Nome do paciente (padrão: 'Anonymous')
            %   'StudyID' - ID do estudo
            %   'SeriesDescription' - Descrição da série
            %   'OriginalImage' - Imagem original para referência
            
            p = inputParser;
            addParameter(p, 'PatientName', 'Anonymous', @ischar);
            addParameter(p, 'StudyID', datestr(now, 'yyyymmdd'), @ischar);
            addParameter(p, 'SeriesDescription', 'Segmentation Mask', @ischar);
            addParameter(p, 'OriginalImage', [], @isnumeric);
            parse(p, varargin{:});
            
            if isempty(filename)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                filename = sprintf('segmentation_%s.dcm', timestamp);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Verificar se Image Processing Toolbox está disponível
                if ~license('test', 'Image_Toolbox')
                    warning('DICOMExporter:MissingToolbox', ...
                        'Image Processing Toolbox necessário para DICOM. Exportando como MAT.');
                    filepath = obj.exportAsMatWithDICOMMetadata(segmentation, filepath, p.Results);
                    return;
                end
                
                % Preparar dados da imagem
                imageData = obj.prepareImageData(segmentation);
                
                % Criar metadados DICOM
                metadata = obj.createDICOMMetadata(imageData, p.Results);
                
                % Tentar escrever arquivo DICOM
                if exist('dicomwrite', 'file')
                    dicomwrite(imageData, filepath, metadata);
                    fprintf('Segmentação exportada como DICOM: %s\n', filepath);
                else
                    % Fallback: exportar como MAT com metadados DICOM
                    filepath = obj.exportAsMatWithDICOMMetadata(segmentation, filepath, p.Results);
                end
                
            catch ME
                warning('DICOMExporter:DICOMError', ...
                    'Erro ao exportar DICOM: %s. Exportando como MAT.', ME.message);
                filepath = obj.exportAsMatWithDICOMMetadata(segmentation, filepath, p.Results);
            end
        end
        
        function metadata = createDICOMMetadata(obj, imageData, params)
            % Cria metadados DICOM padrão
            
            metadata = struct();
            
            % Patient Information
            metadata.PatientName = params.PatientName;
            metadata.PatientID = sprintf('ID_%s', datestr(now, 'yyyymmddHHMMSS'));
            metadata.PatientBirthDate = '';
            metadata.PatientSex = '';
            
            % Study Information
            metadata.StudyInstanceUID = obj.generateUID();
            metadata.StudyID = params.StudyID;
            metadata.StudyDate = datestr(now, 'yyyymmdd');
            metadata.StudyTime = datestr(now, 'HHMMSS');
            metadata.StudyDescription = obj.studyDescription;
            
            % Series Information
            metadata.SeriesInstanceUID = obj.generateUID();
            metadata.SeriesNumber = 1;
            metadata.SeriesDate = datestr(now, 'yyyymmdd');
            metadata.SeriesTime = datestr(now, 'HHMMSS');
            metadata.SeriesDescription = params.SeriesDescription;
            metadata.Modality = 'SEG'; % Segmentation
            
            % Instance Information
            metadata.SOPInstanceUID = obj.generateUID();
            metadata.SOPClassUID = '1.2.840.10008.5.1.4.1.1.66.4'; % Segmentation Storage
            metadata.InstanceNumber = 1;
            
            % Image Information
            metadata.ImageType = 'DERIVED\SECONDARY\SEGMENTATION';
            metadata.Rows = size(imageData, 1);
            metadata.Columns = size(imageData, 2);
            metadata.BitsAllocated = 16;
            metadata.BitsStored = 16;
            metadata.HighBit = 15;
            metadata.PixelRepresentation = 0;
            metadata.SamplesPerPixel = 1;
            metadata.PhotometricInterpretation = 'MONOCHROME2';
            
            % Equipment Information
            metadata.Manufacturer = obj.manufacturerName;
            metadata.InstitutionName = obj.institutionName;
            metadata.SoftwareVersions = obj.softwareVersion;
            metadata.ManufacturerModelName = 'MATLAB Segmentation System';
            
            % Acquisition Information
            metadata.AcquisitionDate = datestr(now, 'yyyymmdd');
            metadata.AcquisitionTime = datestr(now, 'HHMMSS');
            metadata.ContentDate = datestr(now, 'yyyymmdd');
            metadata.ContentTime = datestr(now, 'HHMMSS');
            
            % Pixel Spacing (assumindo 1mm por pixel se não especificado)
            metadata.PixelSpacing = [1.0, 1.0];
            metadata.SliceThickness = 1.0;
            
            % Segmentation specific
            metadata.SegmentationType = 'BINARY';
            metadata.ContentLabel = 'SEGMENTATION';
            metadata.ContentDescription = 'Automated segmentation result';
            metadata.ContentCreatorName = 'MATLAB System';
        end
        
        function filepath = exportImageWithDICOMHeaders(obj, image, originalDICOMPath, filename)
            % Exporta imagem preservando headers DICOM originais
            %
            % Parâmetros:
            %   image - Imagem processada
            %   originalDICOMPath - Caminho do DICOM original
            %   filename - Nome do arquivo de saída
            
            if isempty(filename)
                timestamp = datestr(now, 'yyyyMMdd_HHmmss');
                filename = sprintf('processed_image_%s.dcm', timestamp);
            end
            
            filepath = fullfile(obj.outputDirectory, filename);
            
            try
                % Ler metadados do DICOM original
                if exist(originalDICOMPath, 'file') && exist('dicominfo', 'file')
                    originalInfo = dicominfo(originalDICOMPath);
                    
                    % Atualizar campos necessários
                    originalInfo.SeriesDescription = [originalInfo.SeriesDescription, ' - Processed'];
                    originalInfo.SeriesInstanceUID = obj.generateUID();
                    originalInfo.SOPInstanceUID = obj.generateUID();
                    originalInfo.ContentDate = datestr(now, 'yyyymmdd');
                    originalInfo.ContentTime = datestr(now, 'HHMMSS');
                    
                    % Preparar dados da imagem
                    imageData = obj.prepareImageData(image);
                    
                    % Escrever DICOM
                    if exist('dicomwrite', 'file')
                        dicomwrite(imageData, filepath, originalInfo);
                        fprintf('Imagem processada exportada como DICOM: %s\n', filepath);
                    else
                        filepath = obj.exportAsMatWithDICOMMetadata(image, filepath, struct());
                    end
                else
                    % Se não conseguir ler o original, criar novo
                    params = struct('PatientName', 'Anonymous', 'StudyID', datestr(now, 'yyyymmdd'), ...
                                  'SeriesDescription', 'Processed Image');
                    filepath = obj.exportSegmentationAsDICOM(image, filename, params);
                end
                
            catch ME
                warning('DICOMExporter:ProcessedImageError', ...
                    'Erro ao exportar imagem processada: %s', ME.message);
                filepath = obj.exportAsMatWithDICOMMetadata(image, filepath, struct());
            end
        end
        
        function success = validateDICOMCompliance(obj, filepath)
            % Valida conformidade DICOM do arquivo exportado
            
            success = false;
            
            try
                if exist('dicominfo', 'file') && exist(filepath, 'file')
                    info = dicominfo(filepath);
                    
                    % Verificar campos obrigatórios
                    requiredFields = {'PatientName', 'StudyInstanceUID', 'SeriesInstanceUID', ...
                                    'SOPInstanceUID', 'Modality', 'Rows', 'Columns'};
                    
                    for i = 1:length(requiredFields)
                        field = requiredFields{i};
                        if ~isfield(info, field) || isempty(info.(field))
                            fprintf('Campo DICOM obrigatório ausente: %s\n', field);
                            return;
                        end
                    end
                    
                    success = true;
                    fprintf('Arquivo DICOM válido: %s\n', filepath);
                else
                    fprintf('Não foi possível validar arquivo DICOM: %s\n', filepath);
                end
                
            catch ME
                warning('DICOMExporter:ValidationError', ...
                    'Erro na validação DICOM: %s', ME.message);
            end
        end
        
        function metadataFile = exportDICOMMetadataAsJSON(obj, dicomPath, jsonFilename)
            % Exporta metadados DICOM como JSON
            %
            % Parâmetros:
            %   dicomPath - Caminho do arquivo DICOM
            %   jsonFilename - Nome do arquivo JSON de saída
            
            if isempty(jsonFilename)
                [~, name, ~] = fileparts(dicomPath);
                jsonFilename = sprintf('%s_metadata.json', name);
            end
            
            metadataFile = fullfile(obj.outputDirectory, jsonFilename);
            
            try
                if exist('dicominfo', 'file') && exist(dicomPath, 'file')
                    info = dicominfo(dicomPath);
                    
                    % Converter estrutura DICOM para formato JSON-friendly
                    jsonMetadata = obj.convertDICOMInfoToJSON(info);
                    
                    % Escrever JSON
                    jsonStr = jsonencode(jsonMetadata);
                    fid = fopen(metadataFile, 'w', 'n', 'UTF-8');
                    fprintf(fid, '%s', jsonStr);
                    fclose(fid);
                    
                    fprintf('Metadados DICOM exportados como JSON: %s\n', metadataFile);
                else
                    error('DICOMExporter:MetadataError', 'Não foi possível ler arquivo DICOM');
                end
                
            catch ME
                error('DICOMExporter:JSONExportError', ...
                    'Erro ao exportar metadados JSON: %s', ME.message);
            end
        end
        
        function reportFile = generateDICOMComplianceReport(obj, dicomFiles)
            % Gera relatório de conformidade DICOM
            %
            % Parâmetros:
            %   dicomFiles - Cell array com caminhos dos arquivos DICOM
            
            timestamp = datestr(now, 'yyyyMMdd_HHmmss');
            reportFile = fullfile(obj.outputDirectory, sprintf('dicom_compliance_report_%s.html', timestamp));
            
            try
                % Iniciar HTML
                html = sprintf('<!DOCTYPE html>\n<html>\n<head>\n');
                html = [html, sprintf('<meta charset="UTF-8">\n')];
                html = [html, sprintf('<title>Relatório de Conformidade DICOM</title>\n')];
                html = [html, obj.getDICOMReportCSS()];
                html = [html, sprintf('</head>\n<body>\n')];
                
                html = [html, sprintf('<h1>Relatório de Conformidade DICOM</h1>\n')];
                html = [html, sprintf('<p>Gerado em: %s</p>\n', datestr(now))];
                
                % Tabela de resultados
                html = [html, sprintf('<table class="compliance-table">\n')];
                html = [html, sprintf('<tr><th>Arquivo</th><th>Status</th><th>Observações</th></tr>\n')];
                
                for i = 1:length(dicomFiles)
                    file = dicomFiles{i};
                    [~, name, ext] = fileparts(file);
                    
                    isCompliant = obj.validateDICOMCompliance(file);
                    status = 'Conforme';
                    observations = 'Arquivo DICOM válido';
                    
                    if ~isCompliant
                        status = 'Não Conforme';
                        observations = 'Problemas de conformidade detectados';
                    end
                    
                    html = [html, sprintf('<tr><td>%s%s</td><td>%s</td><td>%s</td></tr>\n', ...
                        name, ext, status, observations)];
                end
                
                html = [html, sprintf('</table>\n')];
                html = [html, sprintf('</body>\n</html>\n')];
                
                % Escrever arquivo
                fid = fopen(reportFile, 'w', 'n', 'UTF-8');
                fprintf(fid, '%s', html);
                fclose(fid);
                
                fprintf('Relatório de conformidade DICOM gerado: %s\n', reportFile);
                
            catch ME
                error('DICOMExporter:ReportError', ...
                    'Erro ao gerar relatório: %s', ME.message);
            end
        end
    end
    
    methods (Access = private)
        function filepath = exportAsMatWithDICOMMetadata(obj, data, filepath, params)
            % Exporta como MAT com metadados DICOM quando DICOM nativo não disponível
            
            % Mudar extensão para .mat
            [pathStr, name, ~] = fileparts(filepath);
            matFile = fullfile(pathStr, [name '.mat']);
            
            % Criar metadados DICOM-compatíveis
            dicomMetadata = obj.createDICOMMetadata(data, params);
            
            % Salvar dados e metadados
            save(matFile, 'data', 'dicomMetadata', '-v7.3');
            
            % Criar arquivo de metadados JSON
            jsonFile = fullfile(pathStr, [name '_dicom_metadata.json']);
            jsonStr = jsonencode(dicomMetadata);
            
            fid = fopen(jsonFile, 'w', 'n', 'UTF-8');
            fprintf(fid, '%s', jsonStr);
            fclose(fid);
            
            fprintf('Dados exportados como MAT com metadados DICOM: %s\n', matFile);
            filepath = matFile;
        end
        
        function imageData = prepareImageData(obj, image)
            % Prepara dados da imagem para DICOM
            
            % Normalizar para uint16
            if isa(image, 'logical')
                imageData = uint16(image) * 65535;
            elseif isfloat(image)
                imageData = uint16(image * 65535);
            else
                imageData = uint16(image);
            end
            
            % Garantir que seja 2D
            if ndims(imageData) > 2
                imageData = rgb2gray(imageData);
            end
        end
        
        function uid = generateUID(obj)
            % Gera UID único para DICOM
            
            % Usar timestamp e número aleatório para gerar UID único
            timestamp = datestr(now, 'yyyymmddHHMMSSFFF');
            randomNum = randi([1000, 9999]);
            
            % Formato básico de UID (não oficialmente registrado)
            uid = sprintf('1.2.826.0.1.3680043.8.498.%s.%d', timestamp, randomNum);
        end
        
        function jsonMetadata = convertDICOMInfoToJSON(obj, dicomInfo)
            % Converte estrutura DICOM para formato JSON-friendly
            
            jsonMetadata = struct();
            fields = fieldnames(dicomInfo);
            
            for i = 1:length(fields)
                field = fields{i};
                value = dicomInfo.(field);
                
                % Converter tipos não suportados pelo JSON
                if isnumeric(value) || islogical(value) || ischar(value)
                    jsonMetadata.(field) = value;
                elseif isstring(value)
                    jsonMetadata.(field) = char(value);
                elseif iscell(value)
                    % Tentar converter cell array
                    try
                        if all(cellfun(@ischar, value))
                            jsonMetadata.(field) = value;
                        else
                            jsonMetadata.(field) = 'Complex cell array - not exported';
                        end
                    catch
                        jsonMetadata.(field) = 'Cell array - conversion failed';
                    end
                else
                    % Para outros tipos, converter para string
                    jsonMetadata.(field) = sprintf('Type: %s', class(value));
                end
            end
        end
        
        function css = getDICOMReportCSS(obj)
            % CSS para relatório DICOM
            
            css = sprintf('<style>\n');
            css = [css, sprintf('body { font-family: Arial, sans-serif; margin: 40px; }\n')];
            css = [css, sprintf('h1 { color: #333; text-align: center; }\n')];
            css = [css, sprintf('.compliance-table { width: 100%%; border-collapse: collapse; margin: 20px 0; }\n')];
            css = [css, sprintf('.compliance-table th, .compliance-table td { border: 1px solid #ddd; padding: 12px; text-align: left; }\n')];
            css = [css, sprintf('.compliance-table th { background-color: #f2f2f2; font-weight: bold; }\n')];
            css = [css, sprintf('.compliance-table tr:nth-child(even) { background-color: #f9f9f9; }\n')];
            css = [css, sprintf('</style>\n')];
        end
    end
end