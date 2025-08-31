#!/usr/bin/env python3
"""
Terminology Dictionary for Portuguese-English Technical Translation
Provides consistent technical translations for scientific article content.
"""

class TerminologyDictionary:
    """
    Comprehensive dictionary for technical term translations between Portuguese and English.
    Organized by domain for consistent translation across the scientific article.
    """
    
    def __init__(self):
        self.terminology_map = {
            'structural_engineering': {
                # Steel and Materials
                'aço ASTM A572 Grau 50': 'ASTM A572 Grade 50 steel',
                'vigas W': 'W-beams',
                'vigas de aço': 'steel beams',
                'estruturas metálicas': 'metal structures',
                'elementos estruturais': 'structural elements',
                'integridade estrutural': 'structural integrity',
                'segurança estrutural': 'structural safety',
                'inspeção estrutural': 'structural inspection',
                'monitoramento estrutural': 'structural monitoring',
                'patologia estrutural': 'structural pathology',
                
                # Corrosion Terms
                'corrosão': 'corrosion',
                'corrosão atmosférica': 'atmospheric corrosion',
                'corrosão uniforme': 'uniform corrosion',
                'corrosão por pites': 'pitting corrosion',
                'corrosão galvânica': 'galvanic corrosion',
                'produtos de corrosão': 'corrosion products',
                'processos corrosivos': 'corrosive processes',
                'deterioração': 'deterioration',
                'oxidação': 'oxidation',
                'ferrugem': 'rust',
                
                # Inspection and Testing
                'inspeção visual': 'visual inspection',
                'ensaios não destrutivos': 'non-destructive testing',
                'detecção automatizada': 'automated detection',
                'monitoramento': 'monitoring',
                'avaliação': 'assessment',
                'diagnóstico': 'diagnosis',
                
                # Properties and Characteristics
                'propriedades mecânicas': 'mechanical properties',
                'tensão de escoamento': 'yield strength',
                'tensão de ruptura': 'tensile strength',
                'resistência': 'strength',
                'ductilidade': 'ductility',
                'soldabilidade': 'weldability',
                'composição química': 'chemical composition',
                'microestrutura': 'microstructure'
            },
            
            'deep_learning': {
                # Neural Networks
                'redes neurais convolucionais': 'convolutional neural networks',
                'redes neurais profundas': 'deep neural networks',
                'aprendizado profundo': 'deep learning',
                'inteligência artificial': 'artificial intelligence',
                'visão computacional': 'computer vision',
                'processamento de imagens': 'image processing',
                
                # Architectures
                'U-Net': 'U-Net',
                'Attention U-Net': 'Attention U-Net',
                'arquitetura': 'architecture',
                'encoder': 'encoder',
                'decoder': 'decoder',
                'bottleneck': 'bottleneck',
                'skip connections': 'skip connections',
                'attention gates': 'attention gates',
                'mecanismos de atenção': 'attention mechanisms',
                
                # Training and Optimization
                'treinamento': 'training',
                'otimização': 'optimization',
                'otimizador': 'optimizer',
                'função de perda': 'loss function',
                'taxa de aprendizado': 'learning rate',
                'hiperparâmetros': 'hyperparameters',
                'épocas': 'epochs',
                'batch size': 'batch size',
                'validação cruzada': 'cross-validation',
                'early stopping': 'early stopping',
                'overfitting': 'overfitting',
                'regularização': 'regularization',
                'dropout': 'dropout',
                
                # Data Processing
                'pré-processamento': 'preprocessing',
                'augmentação de dados': 'data augmentation',
                'normalização': 'normalization',
                'redimensionamento': 'resizing',
                'dataset': 'dataset',
                'conjunto de dados': 'dataset',
                'anotação manual': 'manual annotation',
                'máscaras binárias': 'binary masks',
                'ground truth': 'ground truth'
            },
            
            'segmentation_metrics': {
                # Evaluation Metrics
                'segmentação semântica': 'semantic segmentation',
                'Intersection over Union': 'Intersection over Union (IoU)',
                'IoU': 'IoU',
                'Coeficiente Dice': 'Dice coefficient',
                'Dice': 'Dice coefficient',
                'precisão': 'precision',
                'revocação': 'recall',
                'recall': 'recall',
                'F1-Score': 'F1-Score',
                'acurácia': 'accuracy',
                'especificidade': 'specificity',
                'sensibilidade': 'sensitivity',
                
                # Statistical Terms
                'verdadeiros positivos': 'true positives',
                'falsos positivos': 'false positives',
                'verdadeiros negativos': 'true negatives',
                'falsos negativos': 'false negatives',
                'matriz de confusão': 'confusion matrix',
                'curva ROC': 'ROC curve',
                'área sob a curva': 'area under the curve',
                'AUC': 'AUC'
            },
            
            'statistics': {
                # Statistical Analysis
                'análise estatística': 'statistical analysis',
                'teste t de Student': "Student's t-test",
                'teste de significância': 'significance test',
                'intervalo de confiança': 'confidence interval',
                'nível de significância': 'significance level',
                'valor p': 'p-value',
                'hipótese nula': 'null hypothesis',
                'hipótese alternativa': 'alternative hypothesis',
                'média': 'mean',
                'desvio padrão': 'standard deviation',
                'mediana': 'median',
                'quartis': 'quartiles',
                'distribuição normal': 'normal distribution',
                'correlação': 'correlation',
                'regressão': 'regression'
            },
            
            'academic_writing': {
                # Document Structure
                'resumo': 'abstract',
                'palavras-chave': 'keywords',
                'introdução': 'introduction',
                'revisão da literatura': 'literature review',
                'metodologia': 'methodology',
                'resultados': 'results',
                'discussão': 'discussion',
                'conclusões': 'conclusions',
                'referências': 'references',
                'bibliografia': 'bibliography',
                
                # Academic Terms
                'objetivo geral': 'general objective',
                'objetivos específicos': 'specific objectives',
                'justificativa': 'rationale',
                'relevância científica': 'scientific relevance',
                'contribuição': 'contribution',
                'limitações': 'limitations',
                'trabalhos futuros': 'future work',
                'estado da arte': 'state of the art',
                'lacuna de conhecimento': 'knowledge gap',
                
                # Research Terms
                'pesquisa': 'research',
                'estudo': 'study',
                'investigação': 'investigation',
                'experimento': 'experiment',
                'protocolo experimental': 'experimental protocol',
                'procedimento': 'procedure',
                'método': 'method',
                'abordagem': 'approach',
                'técnica': 'technique',
                'ferramenta': 'tool'
            },
            
            'figures_tables': {
                # Figure References
                'Figura': 'Figure',
                'Tabela': 'Table',
                'Gráfico': 'Graph',
                'Diagrama': 'Diagram',
                'Fluxograma': 'Flowchart',
                'Esquema': 'Scheme',
                
                # Figure Descriptions
                'arquitetura da rede': 'network architecture',
                'fluxograma da metodologia': 'methodology flowchart',
                'comparação de segmentações': 'segmentation comparison',
                'gráficos de performance': 'performance graphs',
                'curvas de aprendizado': 'learning curves',
                'mapas de atenção': 'attention maps',
                'características do dataset': 'dataset characteristics',
                'configurações de treinamento': 'training configurations',
                'resultados quantitativos': 'quantitative results',
                'análise computacional': 'computational analysis'
            }
        }
        
        # Abbreviations and acronyms
        self.abbreviations = {
            'CNN': 'CNN',
            'GPU': 'GPU',
            'CPU': 'CPU',
            'RAM': 'RAM',
            'RGB': 'RGB',
            'JPEG': 'JPEG',
            'TIFF': 'TIFF',
            'PDF': 'PDF',
            'LaTeX': 'LaTeX',
            'ASTM': 'ASTM',
            'ISO': 'ISO',
            'AISC': 'AISC',
            'MPa': 'MPa',
            'ksi': 'ksi',
            'mm': 'mm',
            'cm': 'cm',
            'kg': 'kg',
            'GPU': 'GPU',
            'CUDA': 'CUDA',
            'cuDNN': 'cuDNN'
        }
        
        # Units and measurements
        self.units = {
            'pixels': 'pixels',
            'megapixels': 'megapixels',
            'bits': 'bits',
            'bytes': 'bytes',
            'MB': 'MB',
            'GB': 'GB',
            'Hz': 'Hz',
            'MHz': 'MHz',
            'GHz': 'GHz',
            'segundos': 'seconds',
            'minutos': 'minutes',
            'horas': 'hours',
            'graus': 'degrees',
            '°C': '°C',
            '%': '%'
        }
    
    def get_translation(self, term, domain=None):
        """
        Get English translation for a Portuguese term.
        
        Args:
            term (str): Portuguese term to translate
            domain (str, optional): Specific domain to search in
            
        Returns:
            str: English translation or original term if not found
        """
        term_lower = term.lower()
        
        if domain and domain in self.terminology_map:
            if term_lower in self.terminology_map[domain]:
                return self.terminology_map[domain][term_lower]
        
        # Search across all domains if not found in specific domain
        for domain_dict in self.terminology_map.values():
            if term_lower in domain_dict:
                return domain_dict[term_lower]
        
        # Check abbreviations
        if term in self.abbreviations:
            return self.abbreviations[term]
        
        # Check units
        if term_lower in self.units:
            return self.units[term_lower]
        
        # Return original term if no translation found
        return term
    
    def get_all_terms_by_domain(self, domain):
        """
        Get all terms for a specific domain.
        
        Args:
            domain (str): Domain name
            
        Returns:
            dict: Dictionary of Portuguese-English term pairs
        """
        return self.terminology_map.get(domain, {})
    
    def add_term(self, portuguese_term, english_term, domain):
        """
        Add a new term to the dictionary.
        
        Args:
            portuguese_term (str): Portuguese term
            english_term (str): English translation
            domain (str): Domain category
        """
        if domain not in self.terminology_map:
            self.terminology_map[domain] = {}
        
        self.terminology_map[domain][portuguese_term.lower()] = english_term
    
    def validate_consistency(self, text):
        """
        Check for terminology consistency in translated text.
        
        Args:
            text (str): Text to validate
            
        Returns:
            list: List of potential consistency issues
        """
        issues = []
        
        # Check for remaining Portuguese terms
        portuguese_indicators = [
            'ção', 'são', 'ões', 'ção', 'mente', 'dade', 'agem',
            'treinamento', 'aprendizado', 'segmentação', 'detecção'
        ]
        
        for indicator in portuguese_indicators:
            if indicator in text.lower():
                issues.append(f"Potential Portuguese text found: '{indicator}'")
        
        return issues