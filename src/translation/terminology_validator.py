#!/usr/bin/env python3
"""
Terminology Consistency Validator for English Translation
Automated checker for technical term consistency and translation quality.
"""

import re
import os
from typing import Dict, List, Tuple, Set
from dataclasses import dataclass
from .terminology_dictionary import TerminologyDictionary
from .validation_config import ValidationConfig, default_config


@dataclass
class ValidationResult:
    """Result of terminology validation check."""
    is_valid: bool
    issues: List[str]
    warnings: List[str]
    statistics: Dict[str, int]


class TerminologyValidator:
    """
    Comprehensive validator for terminology consistency in English translation.
    Checks for proper English usage, technical term accuracy, and Portuguese remnants.
    """
    
    def __init__(self, config: ValidationConfig = None):
        self.terminology_dict = TerminologyDictionary()
        self.config = config or default_config
        
        # Portuguese language patterns to detect
        self.portuguese_patterns = {
            'endings': [
                r'\b\w*ção\b',      # -ção endings (segmentação, detecção)
                r'\b\w*são\b',      # -são endings (precisão, dimensão)
                r'\b\w*ões\b',      # -ões endings (configurações, aplicações)
                r'\b\w*mente\b',    # -mente endings (automaticamente)
                r'\b\w*dade\b',     # -dade endings (qualidade, capacidade)
                r'\b\w*agem\b',     # -agem endings (aprendizagem, imagem)
                r'\b\w*ncia\b',     # -ncia endings (importância, diferença)
                r'\b\w*ência\b',    # -ência endings (eficiência, experiência)
            ],
            'common_words': [
                r'\btreinamento\b', r'\baprendizado\b', r'\bsegmentação\b',
                r'\bdetecção\b', r'\bavaliação\b', r'\bcomparação\b',
                r'\bmetodologia\b', r'\bresultados\b', r'\bconclusões\b',
                r'\bintrodução\b', r'\bdiscussão\b', r'\breferências\b',
                r'\bfigura\b', r'\btabela\b', r'\bgráfico\b',
                r'\bprecisão\b', r'\bacurácia\b', r'\bmédia\b',
                r'\bdesvio\b', r'\bpadrão\b', r'\banálise\b',
                r'\bestudo\b', r'\bpesquisa\b', r'\bmétodo\b',
                r'\btécnica\b', r'\bferramenta\b', r'\bsistema\b',
                r'\bmodelo\b', r'\barquitetura\b', r'\brede\b',
                r'\btreinamento\b', r'\bvalidação\b', r'\bteste\b'
            ],
            'articles_prepositions': [
                r'\bda\b', r'\bdo\b', r'\bdas\b', r'\bdos\b',
                r'\bna\b', r'\bno\b', r'\bnas\b', r'\bnos\b',
                r'\bpara\b', r'\bcom\b', r'\bsem\b', r'\bpor\b',
                r'\bsobre\b', r'\bentre\b', r'\baté\b', r'\bdesde\b'
            ]
        }
        
        # Deep learning terminology validation
        self.deep_learning_terms = {
            'correct_english': {
                'convolutional neural networks', 'deep learning', 'machine learning',
                'artificial intelligence', 'computer vision', 'semantic segmentation',
                'u-net', 'attention u-net', 'encoder', 'decoder', 'skip connections',
                'attention mechanisms', 'attention gates', 'training', 'validation',
                'testing', 'optimization', 'hyperparameters', 'loss function',
                'learning rate', 'batch size', 'epochs', 'overfitting',
                'regularization', 'dropout', 'data augmentation', 'preprocessing',
                'normalization', 'cross-validation', 'early stopping'
            },
            'incorrect_usage': {
                'neural network training': 'should be "training neural networks"',
                'deep learning training': 'should be "training with deep learning"',
                'segmentation training': 'should be "training for segmentation"'
            }
        }
        
        # Structural engineering terminology validation
        self.structural_engineering_terms = {
            'correct_english': {
                'astm a572 grade 50', 'w-beams', 'steel beams', 'structural elements',
                'structural integrity', 'structural safety', 'structural inspection',
                'corrosion', 'atmospheric corrosion', 'uniform corrosion',
                'pitting corrosion', 'galvanic corrosion', 'corrosion products',
                'deterioration', 'oxidation', 'rust', 'visual inspection',
                'non-destructive testing', 'automated detection', 'monitoring',
                'mechanical properties', 'yield strength', 'tensile strength',
                'ductility', 'weldability', 'chemical composition', 'microstructure'
            },
            'common_mistakes': {
                'astm a572 grau 50': 'ASTM A572 Grade 50',
                'vigas w': 'W-beams',
                'aço': 'steel',
                'corrosão': 'corrosion',
                'inspeção': 'inspection'
            }
        }
        
        # Academic writing patterns
        self.academic_patterns = {
            'passive_voice_indicators': [
                r'was \w+ed', r'were \w+ed', r'has been \w+ed', r'have been \w+ed',
                r'was performed', r'were conducted', r'was implemented', r'were evaluated'
            ],
            'scientific_connectors': [
                'however', 'therefore', 'furthermore', 'moreover', 'consequently',
                'nevertheless', 'in addition', 'on the other hand', 'in contrast'
            ],
            'statistical_terms': [
                'p-value', 'confidence interval', 'standard deviation', 'mean',
                'median', 'significance level', 'null hypothesis', 'correlation'
            ]
        }
    
    def validate_document(self, tex_file_path: str) -> ValidationResult:
        """
        Validate terminology consistency in the entire LaTeX document.
        
        Args:
            tex_file_path (str): Path to the LaTeX file
            
        Returns:
            ValidationResult: Comprehensive validation results
        """
        try:
            with open(tex_file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            issues = []
            warnings = []
            statistics = {}
            
            # Check for Portuguese remnants
            portuguese_issues = self._check_portuguese_remnants(content)
            issues.extend(portuguese_issues)
            
            # Validate deep learning terminology
            dl_issues, dl_warnings = self._validate_deep_learning_terms(content)
            issues.extend(dl_issues)
            warnings.extend(dl_warnings)
            
            # Validate structural engineering terminology
            se_issues, se_warnings = self._validate_structural_engineering_terms(content)
            issues.extend(se_issues)
            warnings.extend(se_warnings)
            
            # Check academic writing quality
            academic_warnings = self._check_academic_writing_quality(content)
            warnings.extend(academic_warnings)
            
            # Generate statistics
            statistics = self._generate_statistics(content)
            
            is_valid = len(issues) == 0
            
            return ValidationResult(
                is_valid=is_valid,
                issues=issues,
                warnings=warnings,
                statistics=statistics
            )
            
        except Exception as e:
            return ValidationResult(
                is_valid=False,
                issues=[f"Error reading file: {str(e)}"],
                warnings=[],
                statistics={}
            )
    
    def _check_portuguese_remnants(self, content: str) -> List[str]:
        """Check for remaining Portuguese text in the document."""
        issues = []
        
        # Check for Portuguese word endings
        for pattern in self.portuguese_patterns['endings']:
            matches = re.findall(pattern, content, re.IGNORECASE)
            if matches:
                unique_matches = set(matches)
                for match in unique_matches:
                    issues.append(f"Portuguese word ending detected: '{match}'")
        
        # Check for common Portuguese words
        for pattern in self.portuguese_patterns['common_words']:
            matches = re.findall(pattern, content, re.IGNORECASE)
            if matches:
                unique_matches = set(matches)
                for match in unique_matches:
                    issues.append(f"Portuguese word detected: '{match}'")
        
        # Check for Portuguese articles and prepositions
        for pattern in self.portuguese_patterns['articles_prepositions']:
            matches = re.findall(pattern, content, re.IGNORECASE)
            if matches:
                unique_matches = set(matches)
                for match in unique_matches:
                    issues.append(f"Portuguese article/preposition detected: '{match}'")
        
        return issues
    
    def _validate_deep_learning_terms(self, content: str) -> Tuple[List[str], List[str]]:
        """Validate proper usage of deep learning terminology."""
        issues = []
        warnings = []
        
        content_lower = content.lower()
        
        # Check for incorrect usage patterns
        for incorrect, correction in self.deep_learning_terms['incorrect_usage'].items():
            if incorrect in content_lower:
                issues.append(f"Incorrect usage: '{incorrect}' - {correction}")
        
        # Check for presence of key deep learning terms
        expected_terms = [
            'convolutional neural networks', 'deep learning', 'semantic segmentation',
            'u-net', 'attention u-net', 'training', 'validation'
        ]
        
        missing_terms = []
        for term in expected_terms:
            if term not in content_lower:
                missing_terms.append(term)
        
        if missing_terms:
            warnings.append(f"Expected deep learning terms not found: {', '.join(missing_terms)}")
        
        # Check for consistent terminology usage
        inconsistencies = self._check_term_consistency(content, 'deep_learning')
        issues.extend(inconsistencies)
        
        return issues, warnings
    
    def _validate_structural_engineering_terms(self, content: str) -> Tuple[List[str], List[str]]:
        """Validate proper usage of structural engineering terminology."""
        issues = []
        warnings = []
        
        content_lower = content.lower()
        
        # Check for common mistakes
        for mistake, correction in self.structural_engineering_terms['common_mistakes'].items():
            if mistake in content_lower:
                issues.append(f"Incorrect term: '{mistake}' should be '{correction}'")
        
        # Check for presence of key structural engineering terms
        expected_terms = [
            'astm a572 grade 50', 'w-beams', 'corrosion', 'structural inspection'
        ]
        
        missing_terms = []
        for term in expected_terms:
            if term not in content_lower:
                missing_terms.append(term)
        
        if missing_terms:
            warnings.append(f"Expected structural engineering terms not found: {', '.join(missing_terms)}")
        
        # Check for consistent terminology usage
        inconsistencies = self._check_term_consistency(content, 'structural_engineering')
        issues.extend(inconsistencies)
        
        return issues, warnings
    
    def _check_term_consistency(self, content: str, domain: str) -> List[str]:
        """Check for consistent usage of terms within a domain."""
        issues = []
        
        domain_terms = self.terminology_dict.get_all_terms_by_domain(domain)
        content_lower = content.lower()
        
        # Track usage of different variations of the same concept
        term_variations = {}
        
        for portuguese_term, english_term in domain_terms.items():
            # Check if both Portuguese and English versions appear
            if portuguese_term in content_lower and english_term.lower() in content_lower:
                issues.append(f"Inconsistent usage: both '{portuguese_term}' and '{english_term}' found")
        
        return issues
    
    def _check_academic_writing_quality(self, content: str) -> List[str]:
        """Check for proper English academic writing conventions."""
        warnings = []
        
        content_lower = content.lower()
        
        # Check for passive voice in methodology section
        methodology_match = re.search(r'\\section\{methodology\}.*?(?=\\section|\Z)', content, re.DOTALL | re.IGNORECASE)
        if methodology_match:
            methodology_text = methodology_match.group(0).lower()
            passive_voice_found = False
            
            for pattern in self.academic_patterns['passive_voice_indicators']:
                if re.search(pattern, methodology_text):
                    passive_voice_found = True
                    break
            
            if not passive_voice_found:
                warnings.append("Methodology section should use more passive voice constructions")
        
        # Check for scientific connectors
        connector_count = 0
        for connector in self.academic_patterns['scientific_connectors']:
            connector_count += len(re.findall(r'\b' + re.escape(connector) + r'\b', content_lower))
        
        if connector_count < 5:
            warnings.append("Consider using more scientific connectors for better flow")
        
        # Check for statistical terms in results section
        results_match = re.search(r'\\section\{results\}.*?(?=\\section|\Z)', content, re.DOTALL | re.IGNORECASE)
        if results_match:
            results_text = results_match.group(0).lower()
            statistical_terms_found = 0
            
            for term in self.academic_patterns['statistical_terms']:
                if term in results_text:
                    statistical_terms_found += 1
            
            if statistical_terms_found < 3:
                warnings.append("Results section should include more statistical terminology")
        
        return warnings
    
    def _generate_statistics(self, content: str) -> Dict[str, int]:
        """Generate statistics about the document content."""
        statistics = {}
        
        # Count sections
        sections = re.findall(r'\\section\{([^}]+)\}', content)
        statistics['section_count'] = len(sections)
        
        # Count figures and tables
        figures = re.findall(r'\\begin\{figure\}', content)
        tables = re.findall(r'\\begin\{table\}', content)
        statistics['figure_count'] = len(figures)
        statistics['table_count'] = len(tables)
        
        # Count citations
        citations = re.findall(r'\\cite\{[^}]+\}', content)
        statistics['citation_count'] = len(citations)
        
        # Count mathematical equations
        equations = re.findall(r'\\begin\{equation\}', content)
        statistics['equation_count'] = len(equations)
        
        # Count words (approximate)
        # Remove LaTeX commands and count remaining words
        text_only = re.sub(r'\\[a-zA-Z]+\{[^}]*\}', '', content)
        text_only = re.sub(r'\\[a-zA-Z]+', '', text_only)
        text_only = re.sub(r'[{}%]', '', text_only)
        words = re.findall(r'\b\w+\b', text_only)
        statistics['word_count'] = len(words)
        
        # Count deep learning terms
        dl_term_count = 0
        content_lower = content.lower()
        for term in self.deep_learning_terms['correct_english']:
            dl_term_count += len(re.findall(r'\b' + re.escape(term) + r'\b', content_lower))
        statistics['deep_learning_terms'] = dl_term_count
        
        # Count structural engineering terms
        se_term_count = 0
        for term in self.structural_engineering_terms['correct_english']:
            se_term_count += len(re.findall(r'\b' + re.escape(term) + r'\b', content_lower))
        statistics['structural_engineering_terms'] = se_term_count
        
        return statistics
    
    def validate_section(self, section_content: str, section_name: str) -> ValidationResult:
        """
        Validate terminology consistency in a specific section.
        
        Args:
            section_content (str): Content of the section
            section_name (str): Name of the section
            
        Returns:
            ValidationResult: Validation results for the section
        """
        issues = []
        warnings = []
        
        # Check for Portuguese remnants
        portuguese_issues = self._check_portuguese_remnants(section_content)
        issues.extend([f"[{section_name}] {issue}" for issue in portuguese_issues])
        
        # Domain-specific validation based on section
        if section_name.lower() in ['methodology', 'methods']:
            dl_issues, dl_warnings = self._validate_deep_learning_terms(section_content)
            issues.extend([f"[{section_name}] {issue}" for issue in dl_issues])
            warnings.extend([f"[{section_name}] {warning}" for warning in dl_warnings])
        
        if section_name.lower() in ['introduction', 'methodology', 'results']:
            se_issues, se_warnings = self._validate_structural_engineering_terms(section_content)
            issues.extend([f"[{section_name}] {issue}" for issue in se_issues])
            warnings.extend([f"[{section_name}] {warning}" for warning in se_warnings])
        
        # Academic writing quality
        academic_warnings = self._check_academic_writing_quality(section_content)
        warnings.extend([f"[{section_name}] {warning}" for warning in academic_warnings])
        
        statistics = self._generate_statistics(section_content)
        
        return ValidationResult(
            is_valid=len(issues) == 0,
            issues=issues,
            warnings=warnings,
            statistics=statistics
        )
    
    def generate_validation_report(self, validation_result: ValidationResult, output_path: str = None) -> str:
        """
        Generate a comprehensive validation report.
        
        Args:
            validation_result (ValidationResult): Results from validation
            output_path (str, optional): Path to save the report
            
        Returns:
            str: Formatted validation report
        """
        report_lines = []
        report_lines.append("# Terminology Consistency Validation Report")
        report_lines.append("=" * 50)
        report_lines.append("")
        
        # Overall status
        status = "PASSED" if validation_result.is_valid else "FAILED"
        report_lines.append(f"**Overall Status:** {status}")
        report_lines.append("")
        
        # Statistics
        if validation_result.statistics:
            report_lines.append("## Document Statistics")
            report_lines.append("-" * 20)
            for key, value in validation_result.statistics.items():
                formatted_key = key.replace('_', ' ').title()
                report_lines.append(f"- {formatted_key}: {value}")
            report_lines.append("")
        
        # Issues
        if validation_result.issues:
            report_lines.append("## Critical Issues")
            report_lines.append("-" * 15)
            for i, issue in enumerate(validation_result.issues, 1):
                report_lines.append(f"{i}. {issue}")
            report_lines.append("")
        else:
            report_lines.append("## Critical Issues")
            report_lines.append("-" * 15)
            report_lines.append("No critical issues found.")
            report_lines.append("")
        
        # Warnings
        if validation_result.warnings:
            report_lines.append("## Warnings and Recommendations")
            report_lines.append("-" * 30)
            for i, warning in enumerate(validation_result.warnings, 1):
                report_lines.append(f"{i}. {warning}")
            report_lines.append("")
        else:
            report_lines.append("## Warnings and Recommendations")
            report_lines.append("-" * 30)
            report_lines.append("No warnings or recommendations.")
            report_lines.append("")
        
        # Recommendations
        report_lines.append("## Quality Recommendations")
        report_lines.append("-" * 25)
        
        if validation_result.is_valid:
            report_lines.append("- Document passes all terminology consistency checks")
            report_lines.append("- Technical terminology is properly translated")
            report_lines.append("- No Portuguese text remnants detected")
        else:
            report_lines.append("- Review and fix all critical issues before publication")
            report_lines.append("- Ensure consistent use of technical terminology")
            report_lines.append("- Verify complete translation of Portuguese content")
        
        report_lines.append("- Consider peer review by domain experts")
        report_lines.append("- Validate LaTeX compilation after any changes")
        report_lines.append("")
        
        report_content = "\n".join(report_lines)
        
        # Save report if path provided
        if output_path:
            try:
                with open(output_path, 'w', encoding='utf-8') as f:
                    f.write(report_content)
            except Exception as e:
                print(f"Warning: Could not save report to {output_path}: {e}")
        
        return report_content


def main():
    """Main function for command-line usage."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Validate terminology consistency in English translation')
    parser.add_argument('tex_file', help='Path to LaTeX file to validate')
    parser.add_argument('--output', '-o', help='Output path for validation report')
    parser.add_argument('--verbose', '-v', action='store_true', help='Verbose output')
    
    args = parser.parse_args()
    
    validator = TerminologyValidator()
    result = validator.validate_document(args.tex_file)
    
    # Generate and display report
    report = validator.generate_validation_report(result, args.output)
    
    if args.verbose:
        print(report)
    else:
        status = "PASSED" if result.is_valid else "FAILED"
        print(f"Validation {status}: {len(result.issues)} issues, {len(result.warnings)} warnings")
        
        if result.issues:
            print("\nCritical Issues:")
            for issue in result.issues[:5]:  # Show first 5 issues
                print(f"  - {issue}")
            if len(result.issues) > 5:
                print(f"  ... and {len(result.issues) - 5} more issues")
    
    return 0 if result.is_valid else 1


if __name__ == '__main__':
    exit(main())