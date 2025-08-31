#!/usr/bin/env python3
"""
Configuration settings for terminology validation system.
Allows customization of validation rules and thresholds.
"""

class ValidationConfig:
    """Configuration class for terminology validation settings."""
    
    def __init__(self):
        # Portuguese detection sensitivity
        self.portuguese_detection = {
            'check_word_endings': True,
            'check_common_words': True,
            'check_articles_prepositions': True,
            'case_sensitive': False,
            'min_word_length': 3  # Minimum word length to check
        }
        
        # Deep learning terminology validation
        self.deep_learning_validation = {
            'enforce_standard_terms': True,
            'check_consistency': True,
            'required_terms': [
                'convolutional neural networks',
                'deep learning',
                'semantic segmentation',
                'u-net',
                'attention u-net'
            ],
            'allow_abbreviations': True
        }
        
        # Structural engineering validation
        self.structural_engineering_validation = {
            'enforce_astm_standards': True,
            'check_material_specifications': True,
            'required_terms': [
                'astm a572 grade 50',
                'w-beams',
                'corrosion',
                'structural inspection'
            ],
            'case_sensitive_standards': True
        }
        
        # Academic writing quality thresholds
        self.academic_writing = {
            'min_passive_voice_methodology': 2,  # Minimum passive voice constructions
            'min_scientific_connectors': 5,      # Minimum scientific connectors
            'min_statistical_terms_results': 3,  # Minimum statistical terms in results
            'check_section_structure': True,
            'enforce_abstract_structure': True
        }
        
        # Report generation settings
        self.reporting = {
            'max_issues_display': 50,      # Maximum issues to display in summary
            'max_warnings_display': 20,    # Maximum warnings to display
            'include_statistics': True,
            'include_recommendations': True,
            'generate_detailed_report': True,
            'save_backup_reports': True
        }
        
        # Validation strictness levels
        self.strictness_levels = {
            'lenient': {
                'portuguese_detection': {'min_word_length': 4},
                'academic_writing': {
                    'min_passive_voice_methodology': 1,
                    'min_scientific_connectors': 3,
                    'min_statistical_terms_results': 2
                }
            },
            'standard': {
                # Use default settings
            },
            'strict': {
                'portuguese_detection': {'min_word_length': 2},
                'academic_writing': {
                    'min_passive_voice_methodology': 3,
                    'min_scientific_connectors': 8,
                    'min_statistical_terms_results': 5
                }
            }
        }
        
        # Custom validation rules
        self.custom_rules = {
            'enable_custom_patterns': False,
            'custom_portuguese_patterns': [],
            'custom_technical_terms': {},
            'custom_quality_checks': []
        }
        
        # File handling settings
        self.file_handling = {
            'encoding': 'utf-8',
            'backup_original': True,
            'create_temp_files': False,
            'cleanup_temp_files': True
        }
    
    def set_strictness_level(self, level: str):
        """
        Set validation strictness level.
        
        Args:
            level (str): 'lenient', 'standard', or 'strict'
        """
        if level not in self.strictness_levels:
            raise ValueError(f"Invalid strictness level: {level}")
        
        level_config = self.strictness_levels[level]
        
        # Apply level-specific settings
        for category, settings in level_config.items():
            if hasattr(self, category):
                category_config = getattr(self, category)
                category_config.update(settings)
    
    def add_custom_portuguese_pattern(self, pattern: str, description: str):
        """
        Add custom Portuguese detection pattern.
        
        Args:
            pattern (str): Regex pattern to detect Portuguese text
            description (str): Description of what the pattern detects
        """
        self.custom_rules['custom_portuguese_patterns'].append({
            'pattern': pattern,
            'description': description
        })
        self.custom_rules['enable_custom_patterns'] = True
    
    def add_custom_technical_term(self, portuguese: str, english: str, domain: str):
        """
        Add custom technical term mapping.
        
        Args:
            portuguese (str): Portuguese term
            english (str): English translation
            domain (str): Technical domain
        """
        if domain not in self.custom_rules['custom_technical_terms']:
            self.custom_rules['custom_technical_terms'][domain] = {}
        
        self.custom_rules['custom_technical_terms'][domain][portuguese] = english
    
    def get_config_summary(self) -> dict:
        """
        Get summary of current configuration settings.
        
        Returns:
            dict: Configuration summary
        """
        return {
            'portuguese_detection_enabled': self.portuguese_detection['check_word_endings'],
            'deep_learning_validation_enabled': self.deep_learning_validation['enforce_standard_terms'],
            'structural_validation_enabled': self.structural_engineering_validation['enforce_astm_standards'],
            'academic_writing_checks': self.academic_writing['check_section_structure'],
            'custom_rules_enabled': self.custom_rules['enable_custom_patterns'],
            'min_word_length': self.portuguese_detection['min_word_length'],
            'required_dl_terms': len(self.deep_learning_validation['required_terms']),
            'required_se_terms': len(self.structural_engineering_validation['required_terms'])
        }
    
    def load_from_file(self, config_file: str):
        """
        Load configuration from JSON file.
        
        Args:
            config_file (str): Path to configuration file
        """
        import json
        
        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                config_data = json.load(f)
            
            # Update configuration with loaded data
            for category, settings in config_data.items():
                if hasattr(self, category):
                    category_config = getattr(self, category)
                    if isinstance(category_config, dict):
                        category_config.update(settings)
            
        except Exception as e:
            raise ValueError(f"Error loading configuration file: {e}")
    
    def save_to_file(self, config_file: str):
        """
        Save current configuration to JSON file.
        
        Args:
            config_file (str): Path to save configuration
        """
        import json
        
        config_data = {
            'portuguese_detection': self.portuguese_detection,
            'deep_learning_validation': self.deep_learning_validation,
            'structural_engineering_validation': self.structural_engineering_validation,
            'academic_writing': self.academic_writing,
            'reporting': self.reporting,
            'custom_rules': self.custom_rules,
            'file_handling': self.file_handling
        }
        
        try:
            with open(config_file, 'w', encoding='utf-8') as f:
                json.dump(config_data, f, indent=2, ensure_ascii=False)
        except Exception as e:
            raise ValueError(f"Error saving configuration file: {e}")


# Default configuration instance
default_config = ValidationConfig()

# Predefined configurations for different use cases
research_config = ValidationConfig()
research_config.set_strictness_level('strict')
research_config.academic_writing['enforce_abstract_structure'] = True

publication_config = ValidationConfig()
publication_config.set_strictness_level('standard')
publication_config.reporting['generate_detailed_report'] = True
publication_config.reporting['include_recommendations'] = True

draft_config = ValidationConfig()
draft_config.set_strictness_level('lenient')
draft_config.portuguese_detection['check_articles_prepositions'] = False