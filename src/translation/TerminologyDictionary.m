classdef TerminologyDictionary < handle
    % TerminologyDictionary - Manages consistent technical translations
    % between Portuguese and English for scientific articles
    %
    % This class provides a comprehensive mapping of technical terms
    % used in structural engineering, deep learning, and materials science
    % to ensure consistent translation throughout the document.
    
    properties (Access = private)
        structural_engineering_terms
        deep_learning_terms
        materials_science_terms
        statistics_terms
        general_academic_terms
        abbreviations_map
        units_map
    end
    
    methods
        function obj = TerminologyDictionary()
            % Constructor - Initialize all terminology mappings
            obj.initializeStructuralEngineeringTerms();
            obj.initializeDeepLearningTerms();
            obj.initializeMaterialsScienceTerms();
            obj.initializeStatisticsTerms();
            obj.initializeGeneralAcademicTerms();
            obj.initializeAbbreviationsMap();
            obj.initializeUnitsMap();
        end
        
        function english_term = translateTerm(obj, portuguese_term, domain)
            % Translate a Portuguese term to English within specified domain
            %
            % Args:
            %   portuguese_term (string): Portuguese term to translate
            %   domain (string): Domain category ('structural', 'deep_learning', 
            %                   'materials', 'statistics', 'academic', 'abbreviations', 'units')
            %
            % Returns:
            %   english_term (string): English translation or original term if not found
            
            switch lower(domain)
                case 'structural'
                    term_map = obj.structural_engineering_terms;
                case 'deep_learning'
                    term_map = obj.deep_learning_terms;
                case 'materials'
                    term_map = obj.materials_science_terms;
                case 'statistics'
                    term_map = obj.statistics_terms;
                case 'academic'
                    term_map = obj.general_academic_terms;
                case 'abbreviations'
                    term_map = obj.abbreviations_map;
                case 'units'
                    term_map = obj.units_map;
                otherwise
                    error('Unknown domain: %s', domain);
            end
            
            if isKey(term_map, portuguese_term)
                english_term = term_map(portuguese_term);
            else
                english_term = portuguese_term; % Return original if not found
                warning('Term not found in dictionary: %s (domain: %s)', portuguese_term, domain);
            end
        end
        
        function all_terms = getAllTerms(obj, domain)
            % Get all terms for a specific domain
            %
            % Args:
            %   domain (string): Domain category
            %
            % Returns:
            %   all_terms (containers.Map): All terms in the specified domain
            
            switch lower(domain)
                case 'structural'
                    all_terms = obj.structural_engineering_terms;
                case 'deep_learning'
                    all_terms = obj.deep_learning_terms;
                case 'materials'
                    all_terms = obj.materials_science_terms;
                case 'statistics'
                    all_terms = obj.statistics_terms;
                case 'academic'
                    all_terms = obj.general_academic_terms;
                case 'abbreviations'
                    all_terms = obj.abbreviations_map;
                case 'units'
                    all_terms = obj.units_map;
                otherwise
                    error('Unknown domain: %s', domain);
            end
        end
        
        function consistency_report = checkConsistency(obj, text, domain)
            % Check terminology consistency in a text
            %
            % Args:
            %   text (string): Text to check for consistency
            %   domain (string): Primary domain for checking
            %
            % Returns:
            %   consistency_report (struct): Report with inconsistencies found
            
            term_map = obj.getAllTerms(domain);
            portuguese_terms = keys(term_map);
            english_terms = values(term_map);
            
            inconsistencies = {};
            mixed_usage = {};
            
            for i = 1:length(portuguese_terms)
                pt_term = portuguese_terms{i};
                en_term = english_terms{i};
                
                pt_found = contains(text, pt_term, 'IgnoreCase', true);
                en_found = contains(text, en_term, 'IgnoreCase', true);
                
                if pt_found && en_found
                    mixed_usage{end+1} = sprintf('%s / %s', pt_term, en_term);
                elseif pt_found
                    inconsistencies{end+1} = sprintf('Portuguese term found: %s (should be: %s)', pt_term, en_term);
                end
            end
            
            consistency_report.inconsistencies = inconsistencies;
            consistency_report.mixed_usage = mixed_usage;
            consistency_report.is_consistent = isempty(inconsistencies) && isempty(mixed_usage);
        end
    end
    
    methods (Access = private)
        function initializeStructuralEngineeringTerms(obj)
            % Initialize structural engineering terminology mappings
            obj.structural_engineering_terms = containers.Map();
            
            % Basic structural terms
            obj.structural_engineering_terms('vigas W') = 'W-beams';
            obj.structural_engineering_terms('viga W') = 'W-beam';
            obj.structural_engineering_terms('aço ASTM A572 Grau 50') = 'ASTM A572 Grade 50 steel';
            obj.structural_engineering_terms('aço ASTM A572') = 'ASTM A572 steel';
            obj.structural_engineering_terms('corrosão') = 'corrosion';
            obj.structural_engineering_terms('inspeção estrutural') = 'structural inspection';
            obj.structural_engineering_terms('integridade estrutural') = 'structural integrity';
            obj.structural_engineering_terms('deterioração') = 'deterioration';
            obj.structural_engineering_terms('patologia estrutural') = 'structural pathology';
            
            % Corrosion-specific terms
            obj.structural_engineering_terms('corrosão atmosférica') = 'atmospheric corrosion';
            obj.structural_engineering_terms('corrosão uniforme') = 'uniform corrosion';
            obj.structural_engineering_terms('corrosão por pites') = 'pitting corrosion';
            obj.structural_engineering_terms('corrosão galvânica') = 'galvanic corrosion';
            obj.structural_engineering_terms('produtos de corrosão') = 'corrosion products';
            obj.structural_engineering_terms('óxidos de ferro') = 'iron oxides';
            obj.structural_engineering_terms('ferrugem') = 'rust';
            
            % Structural elements
            obj.structural_engineering_terms('elementos estruturais') = 'structural elements';
            obj.structural_engineering_terms('perfis estruturais') = 'structural profiles';
            obj.structural_engineering_terms('soldabilidade') = 'weldability';
            obj.structural_engineering_terms('ductilidade') = 'ductility';
            obj.structural_engineering_terms('resistência mecânica') = 'mechanical strength';
            obj.structural_engineering_terms('tensão de escoamento') = 'yield strength';
            obj.structural_engineering_terms('tensão de ruptura') = 'ultimate tensile strength';
        end
        
        function initializeDeepLearningTerms(obj)
            % Initialize deep learning terminology mappings
            obj.deep_learning_terms = containers.Map();
            
            % Neural network architectures
            obj.deep_learning_terms('redes neurais convolucionais') = 'convolutional neural networks';
            obj.deep_learning_terms('rede neural convolucional') = 'convolutional neural network';
            obj.deep_learning_terms('segmentação semântica') = 'semantic segmentation';
            obj.deep_learning_terms('aprendizado profundo') = 'deep learning';
            obj.deep_learning_terms('mecanismos de atenção') = 'attention mechanisms';
            obj.deep_learning_terms('mecanismo de atenção') = 'attention mechanism';
            obj.deep_learning_terms('gates de atenção') = 'attention gates';
            
            % Training and optimization
            obj.deep_learning_terms('treinamento') = 'training';
            obj.deep_learning_terms('validação cruzada') = 'cross-validation';
            obj.deep_learning_terms('hiperparâmetros') = 'hyperparameters';
            obj.deep_learning_terms('função de perda') = 'loss function';
            obj.deep_learning_terms('otimizador') = 'optimizer';
            obj.deep_learning_terms('taxa de aprendizado') = 'learning rate';
            obj.deep_learning_terms('regularização') = 'regularization';
            obj.deep_learning_terms('dropout') = 'dropout';
            obj.deep_learning_terms('early stopping') = 'early stopping';
            
            % Architecture components
            obj.deep_learning_terms('encoder') = 'encoder';
            obj.deep_learning_terms('decoder') = 'decoder';
            obj.deep_learning_terms('skip connections') = 'skip connections';
            obj.deep_learning_terms('feature maps') = 'feature maps';
            obj.deep_learning_terms('convolução') = 'convolution';
            obj.deep_learning_terms('max pooling') = 'max pooling';
            obj.deep_learning_terms('upsampling') = 'upsampling';
            obj.deep_learning_terms('bottleneck') = 'bottleneck';
            
            % Data processing
            obj.deep_learning_terms('augmentação de dados') = 'data augmentation';
            obj.deep_learning_terms('pré-processamento') = 'preprocessing';
            obj.deep_learning_terms('normalização') = 'normalization';
            obj.deep_learning_terms('dataset') = 'dataset';
            obj.deep_learning_terms('conjunto de dados') = 'dataset';
            obj.deep_learning_terms('anotação manual') = 'manual annotation';
            obj.deep_learning_terms('máscaras binárias') = 'binary masks';
        end
        
        function initializeMaterialsScienceTerms(obj)
            % Initialize materials science terminology mappings
            obj.materials_science_terms = containers.Map();
            
            % Material properties
            obj.materials_science_terms('composição química') = 'chemical composition';
            obj.materials_science_terms('microestrutura') = 'microstructure';
            obj.materials_science_terms('ferrita-perlita') = 'ferrite-pearlite';
            obj.materials_science_terms('laminação controlada') = 'controlled rolling';
            obj.materials_science_terms('grãos refinados') = 'refined grains';
            
            % Corrosion mechanisms
            obj.materials_science_terms('mecanismos de corrosão') = 'corrosion mechanisms';
            obj.materials_science_terms('processo eletroquímico') = 'electrochemical process';
            obj.materials_science_terms('potencial eletroquímico') = 'electrochemical potential';
            obj.materials_science_terms('ambientes agressivos') = 'aggressive environments';
            obj.materials_science_terms('poluentes atmosféricos') = 'atmospheric pollutants';
            
            % Material standards
            obj.materials_science_terms('especificação ASTM') = 'ASTM specification';
            obj.materials_science_terms('norma ASTM') = 'ASTM standard';
            obj.materials_science_terms('propriedades mecânicas') = 'mechanical properties';
            obj.materials_science_terms('relação resistência-peso') = 'strength-to-weight ratio';
        end
        
        function initializeStatisticsTerms(obj)
            % Initialize statistics terminology mappings
            obj.statistics_terms = containers.Map();
            
            % Statistical measures
            obj.statistics_terms('média') = 'mean';
            obj.statistics_terms('desvio padrão') = 'standard deviation';
            obj.statistics_terms('variância') = 'variance';
            obj.statistics_terms('mediana') = 'median';
            obj.statistics_terms('intervalo de confiança') = 'confidence interval';
            obj.statistics_terms('nível de significância') = 'significance level';
            obj.statistics_terms('teste t de Student') = "Student's t-test";
            obj.statistics_terms('teste de hipótese') = 'hypothesis test';
            
            % Evaluation metrics
            obj.statistics_terms('precisão') = 'precision';
            obj.statistics_terms('revocação') = 'recall';
            obj.statistics_terms('acurácia') = 'accuracy';
            obj.statistics_terms('coeficiente Dice') = 'Dice coefficient';
            obj.statistics_terms('índice Jaccard') = 'Jaccard index';
            obj.statistics_terms('verdadeiros positivos') = 'true positives';
            obj.statistics_terms('falsos positivos') = 'false positives';
            obj.statistics_terms('verdadeiros negativos') = 'true negatives';
            obj.statistics_terms('falsos negativos') = 'false negatives';
            
            % Statistical analysis
            obj.statistics_terms('análise estatística') = 'statistical analysis';
            obj.statistics_terms('significância estatística') = 'statistical significance';
            obj.statistics_terms('correlação') = 'correlation';
            obj.statistics_terms('distribuição normal') = 'normal distribution';
            obj.statistics_terms('teste de normalidade') = 'normality test';
        end
        
        function initializeGeneralAcademicTerms(obj)
            % Initialize general academic terminology mappings
            obj.general_academic_terms = containers.Map();
            
            % Research methodology
            obj.general_academic_terms('metodologia') = 'methodology';
            obj.general_academic_terms('objetivo geral') = 'general objective';
            obj.general_academic_terms('objetivos específicos') = 'specific objectives';
            obj.general_academic_terms('revisão da literatura') = 'literature review';
            obj.general_academic_terms('estado da arte') = 'state of the art';
            obj.general_academic_terms('trabalhos relacionados') = 'related work';
            
            % Document structure
            obj.general_academic_terms('resumo') = 'abstract';
            obj.general_academic_terms('palavras-chave') = 'keywords';
            obj.general_academic_terms('introdução') = 'introduction';
            obj.general_academic_terms('conclusões') = 'conclusions';
            obj.general_academic_terms('discussão') = 'discussion';
            obj.general_academic_terms('resultados') = 'results';
            obj.general_academic_terms('referências') = 'references';
            
            % Academic writing
            obj.general_academic_terms('contribuição científica') = 'scientific contribution';
            obj.general_academic_terms('relevância científica') = 'scientific relevance';
            obj.general_academic_terms('impacto prático') = 'practical impact';
            obj.general_academic_terms('limitações do estudo') = 'study limitations';
            obj.general_academic_terms('trabalhos futuros') = 'future work';
            obj.general_academic_terms('implicações práticas') = 'practical implications';
        end
        
        function initializeAbbreviationsMap(obj)
            % Initialize abbreviations and acronyms mappings
            obj.abbreviations_map = containers.Map();
            
            % Technical abbreviations
            obj.abbreviations_map('IoU') = 'Intersection over Union (IoU)';
            obj.abbreviations_map('CNN') = 'Convolutional Neural Network (CNN)';
            obj.abbreviations_map('ReLU') = 'Rectified Linear Unit (ReLU)';
            obj.abbreviations_map('GPU') = 'Graphics Processing Unit (GPU)';
            obj.abbreviations_map('CPU') = 'Central Processing Unit (CPU)';
            obj.abbreviations_map('RAM') = 'Random Access Memory (RAM)';
            
            % Standards and organizations
            obj.abbreviations_map('ASTM') = 'American Society for Testing and Materials (ASTM)';
            obj.abbreviations_map('AISC') = 'American Institute of Steel Construction (AISC)';
            obj.abbreviations_map('ISO') = 'International Organization for Standardization (ISO)';
            
            % File formats and software
            obj.abbreviations_map('JPEG') = 'Joint Photographic Experts Group (JPEG)';
            obj.abbreviations_map('RGB') = 'Red, Green, Blue (RGB)';
            obj.abbreviations_map('TIFF') = 'Tagged Image File Format (TIFF)';
            obj.abbreviations_map('PDF') = 'Portable Document Format (PDF)';
        end
        
        function initializeUnitsMap(obj)
            % Initialize units and measurements mappings
            obj.units_map = containers.Map();
            
            % Mechanical properties units
            obj.units_map('MPa') = 'MPa';
            obj.units_map('ksi') = 'ksi';
            obj.units_map('GPa') = 'GPa';
            obj.units_map('N/mm²') = 'N/mm²';
            
            % Dimensional units
            obj.units_map('mm') = 'mm';
            obj.units_map('cm') = 'cm';
            obj.units_map('m') = 'm';
            obj.units_map('pixels') = 'pixels';
            
            % Temperature and other units
            obj.units_map('°C') = '°C';
            obj.units_map('K') = 'K';
            obj.units_map('%') = '%';
            obj.units_map('anos') = 'years';
            obj.units_map('meses') = 'months';
        end
    end
end