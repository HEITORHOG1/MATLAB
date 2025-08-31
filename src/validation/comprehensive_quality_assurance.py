#!/usr/bin/env python3
"""
Comprehensive Quality Assurance System for English Translation
Performs final quality review of the translated scientific article
"""

import re
import os
import sys
import subprocess
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Any
import json

class ComprehensiveQualityAssurance:
    """Main quality assurance system for translation validation"""
    
    def __init__(self, tex_file_path: str = "artigo_cientifico_corrosao.tex"):
        self.tex_file_path = tex_file_path
        self.report_data = {
            'timestamp': datetime.now().strftime('%Y%m%d_%H%M%S'),
            'tests_performed': [],
            'quality_scores': {},
            'issues_found': [],
            'recommendations': []
        }
        
        # Technical terminology dictionary for validation
        self.technical_terms = {
            'structural_engineering': [
                'ASTM A572 Grade 50', 'W-beams', 'structural inspection',
                'corrosion', 'structural integrity', 'deterioration',
                'structural pathology', 'non-destructive testing'
            ],
            'deep_learning': [
                'convolutional neural networks', 'semantic segmentation',
                'deep learning', 'attention mechanisms', 'U-Net',
                'Attention U-Net', 'training', 'validation', 'hyperparameters'
            ],
            'evaluation_metrics': [
                'Intersection over Union', 'IoU', 'Dice coefficient',
                'precision', 'recall', 'F1-score', 'accuracy'
            ]
        }
        
        # Portuguese terms that should NOT appear in English translation
        self.portuguese_terms = [
            'aço', 'corrosão', 'viga', 'treinamento', 'validação',
            'precisão', 'revocação', 'acurácia', 'segmentação',
            'aprendizado', 'rede neural', 'convolucional'
        ]
        
        # Academic writing indicators
        self.academic_indicators = {
            'abstract_structure': [
                'background', 'objective', 'method', 'result', 'conclusion'
            ],
            'methodology_passive': [
                'was performed', 'were conducted', 'was implemented',
                'was used', 'were analyzed', 'was applied'
            ],
            'statistical_terms': [
                'p <', 'confidence interval', 'standard deviation',
                'significant', 'correlation', 'regression'
            ]
        }

    def read_tex_file(self) -> str:
        """Read the LaTeX file content"""
        try:
            with open(self.tex_file_path, 'r', encoding='utf-8') as f:
                return f.read()
        except FileNotFoundError:
            self.report_data['issues_found'].append(
                f"ERROR: LaTeX file not found: {self.tex_file_path}"
            )
            return ""
        except Exception as e:
            self.report_data['issues_found'].append(
                f"ERROR: Failed to read LaTeX file: {str(e)}"
            )
            return ""

    def test_technical_terminology_accuracy(self, content: str) -> float:
        """Test technical terminology accuracy and consistency"""
        print("Testing technical terminology accuracy...")
        
        issues = []
        term_count = 0
        correct_terms = 0
        
        # Check for presence of required technical terms
        for category, terms in self.technical_terms.items():
            for term in terms:
                if term.lower() in content.lower():
                    term_count += 1
                    correct_terms += 1
                    
        # Check for Portuguese terms (should not be present)
        portuguese_found = []
        for term in self.portuguese_terms:
            if re.search(r'\b' + re.escape(term) + r'\b', content, re.IGNORECASE):
                portuguese_found.append(term)
                issues.append(f"Portuguese term found: {term}")
        
        # Calculate accuracy score
        if term_count > 0:
            accuracy = correct_terms / term_count
        else:
            accuracy = 0.0
            issues.append("No technical terms found in document")
        
        # Penalize for Portuguese terms
        if portuguese_found:
            accuracy *= 0.5  # Significant penalty for Portuguese terms
            
        self.report_data['issues_found'].extend(issues)
        self.report_data['quality_scores']['technical_terminology'] = accuracy
        
        print(f"Technical terminology accuracy: {accuracy:.2%}")
        return accuracy

    def test_academic_writing_quality(self, content: str) -> float:
        """Test academic writing quality and conventions"""
        print("Testing academic writing quality...")
        
        issues = []
        quality_indicators = 0
        total_checks = 0
        
        # Check abstract structure
        abstract_match = re.search(r'\\begin{abstract}(.*?)\\end{abstract}', 
                                 content, re.DOTALL | re.IGNORECASE)
        if abstract_match:
            abstract_text = abstract_match.group(1).lower()
            abstract_score = 0
            for indicator in self.academic_indicators['abstract_structure']:
                if indicator in abstract_text:
                    abstract_score += 1
            quality_indicators += abstract_score / len(self.academic_indicators['abstract_structure'])
            total_checks += 1
        else:
            issues.append("Abstract section not found or improperly formatted")
        
        # Check methodology passive voice usage
        methodology_sections = re.findall(r'\\section\{.*?methodology.*?\}(.*?)(?=\\section|\Z)', 
                                        content, re.DOTALL | re.IGNORECASE)
        if methodology_sections:
            methodology_text = ' '.join(methodology_sections).lower()
            passive_count = sum(1 for indicator in self.academic_indicators['methodology_passive'] 
                              if indicator in methodology_text)
            if passive_count > 0:
                quality_indicators += min(passive_count / 3, 1.0)  # Normalize to max 1.0
            total_checks += 1
        else:
            issues.append("Methodology section not found")
        
        # Check statistical terminology in results
        results_sections = re.findall(r'\\section\{.*?result.*?\}(.*?)(?=\\section|\Z)', 
                                    content, re.DOTALL | re.IGNORECASE)
        if results_sections:
            results_text = ' '.join(results_sections).lower()
            stats_count = sum(1 for term in self.academic_indicators['statistical_terms'] 
                            if term in results_text)
            if stats_count > 0:
                quality_indicators += min(stats_count / 2, 1.0)  # Normalize to max 1.0
            total_checks += 1
        else:
            issues.append("Results section not found")
        
        # Calculate overall academic quality score
        if total_checks > 0:
            quality_score = quality_indicators / total_checks
        else:
            quality_score = 0.0
            issues.append("No academic sections found for quality assessment")
        
        self.report_data['issues_found'].extend(issues)
        self.report_data['quality_scores']['academic_writing'] = quality_score
        
        print(f"Academic writing quality: {quality_score:.2%}")
        return quality_score

    def test_translation_completeness(self, content: str) -> float:
        """Test translation completeness and content preservation"""
        print("Testing translation completeness...")
        
        issues = []
        completeness_score = 0
        total_sections = 0
        
        # Required sections for scientific article
        required_sections = [
            'abstract', 'introduction', 'methodology', 'results', 
            'discussion', 'conclusion', 'references'
        ]
        
        sections_found = 0
        for section in required_sections:
            section_pattern = rf'\\section\{{.*?{section}.*?\}}'
            if re.search(section_pattern, content, re.IGNORECASE):
                sections_found += 1
            else:
                issues.append(f"Required section missing or improperly formatted: {section}")
        
        completeness_score += sections_found / len(required_sections)
        total_sections += 1
        
        # Check figure references
        figure_refs = ['Figure 1', 'Figure 2', 'Figure 3', 'Figure 4', 
                      'Figure 5', 'Figure 6', 'Figure 7']
        figures_found = 0
        for fig_ref in figure_refs:
            if fig_ref in content:
                figures_found += 1
            else:
                issues.append(f"Figure reference missing: {fig_ref}")
        
        completeness_score += figures_found / len(figure_refs)
        total_sections += 1
        
        # Check table references
        table_refs = ['Table 1', 'Table 2', 'Table 3', 'Table 4']
        tables_found = 0
        for table_ref in table_refs:
            if table_ref in content:
                tables_found += 1
            else:
                issues.append(f"Table reference missing: {table_ref}")
        
        completeness_score += tables_found / len(table_refs)
        total_sections += 1
        
        # Final completeness score
        final_score = completeness_score / total_sections if total_sections > 0 else 0.0
        
        self.report_data['issues_found'].extend(issues)
        self.report_data['quality_scores']['completeness'] = final_score
        
        print(f"Translation completeness: {final_score:.2%}")
        return final_score

    def test_latex_integrity(self, content: str) -> float:
        """Test LaTeX structure integrity and compilation readiness"""
        print("Testing LaTeX integrity...")
        
        issues = []
        integrity_checks = 0
        passed_checks = 0
        
        # Essential LaTeX commands
        essential_commands = [
            r'\\documentclass', r'\\begin{document}', r'\\end{document}',
            r'\\section', r'\\subsection', r'\\cite', r'\\ref'
        ]
        
        for command in essential_commands:
            if re.search(command, content):
                passed_checks += 1
            else:
                issues.append(f"Essential LaTeX command missing: {command}")
            integrity_checks += 1
        
        # Mathematical environments
        math_environments = [r'\\begin{equation}', r'\\end{equation}']
        math_found = 0
        for env in math_environments:
            if re.search(env, content):
                math_found += 1
        
        if math_found == len(math_environments):
            passed_checks += 1
        elif math_found > 0:
            issues.append("Incomplete mathematical environments found")
        integrity_checks += 1
        
        # Bibliography
        if re.search(r'\\bibliography\{', content) or re.search(r'\\bibitem', content):
            passed_checks += 1
        else:
            issues.append("Bibliography section missing or improperly formatted")
        integrity_checks += 1
        
        # Calculate integrity score
        integrity_score = passed_checks / integrity_checks if integrity_checks > 0 else 0.0
        
        self.report_data['issues_found'].extend(issues)
        self.report_data['quality_scores']['latex_integrity'] = integrity_score
        
        print(f"LaTeX integrity: {integrity_score:.2%}")
        return integrity_score

    def test_latex_compilation(self) -> bool:
        """Test actual LaTeX compilation"""
        print("Testing LaTeX compilation...")
        
        try:
            # Run pdflatex compilation
            result = subprocess.run(
                ['pdflatex', '-interaction=nonstopmode', self.tex_file_path],
                capture_output=True,
                text=True,
                timeout=120,
                cwd='.'
            )
            
            if result.returncode == 0:
                print("LaTeX compilation successful")
                self.report_data['quality_scores']['latex_compilation'] = 1.0
                return True
            else:
                error_msg = f"LaTeX compilation failed: {result.stderr}"
                self.report_data['issues_found'].append(error_msg)
                self.report_data['quality_scores']['latex_compilation'] = 0.0
                print(f"LaTeX compilation failed: {result.returncode}")
                return False
                
        except subprocess.TimeoutExpired:
            error_msg = "LaTeX compilation timed out"
            self.report_data['issues_found'].append(error_msg)
            self.report_data['quality_scores']['latex_compilation'] = 0.0
            print("LaTeX compilation timed out")
            return False
        except FileNotFoundError:
            error_msg = "pdflatex not found - LaTeX not installed"
            self.report_data['issues_found'].append(error_msg)
            self.report_data['quality_scores']['latex_compilation'] = 0.0
            print("pdflatex not found")
            return False
        except Exception as e:
            error_msg = f"LaTeX compilation error: {str(e)}"
            self.report_data['issues_found'].append(error_msg)
            self.report_data['quality_scores']['latex_compilation'] = 0.0
            print(f"LaTeX compilation error: {e}")
            return False

    def calculate_overall_quality_score(self) -> Tuple[float, str]:
        """Calculate overall translation quality score"""
        scores = self.report_data['quality_scores']
        
        # Weights for different quality aspects
        weights = {
            'technical_terminology': 0.25,
            'academic_writing': 0.25,
            'completeness': 0.20,
            'latex_integrity': 0.15,
            'latex_compilation': 0.15
        }
        
        # Calculate weighted average
        total_score = 0.0
        total_weight = 0.0
        
        for metric, weight in weights.items():
            if metric in scores:
                total_score += scores[metric] * weight
                total_weight += weight
        
        if total_weight > 0:
            final_score = total_score / total_weight
        else:
            final_score = 0.0
        
        # Determine quality level
        if final_score >= 0.95:
            quality_level = 'Excellent'
        elif final_score >= 0.85:
            quality_level = 'Very Good'
        elif final_score >= 0.75:
            quality_level = 'Good'
        elif final_score >= 0.60:
            quality_level = 'Acceptable'
        else:
            quality_level = 'Needs Improvement'
        
        return final_score, quality_level

    def generate_recommendations(self):
        """Generate recommendations based on quality assessment"""
        recommendations = []
        scores = self.report_data['quality_scores']
        
        # Technical terminology recommendations
        if scores.get('technical_terminology', 0) < 0.8:
            recommendations.append(
                "Review technical terminology consistency and accuracy. "
                "Ensure all Portuguese terms are properly translated."
            )
        
        # Academic writing recommendations
        if scores.get('academic_writing', 0) < 0.8:
            recommendations.append(
                "Improve academic writing quality. Check abstract structure, "
                "use appropriate passive voice in methodology, and include "
                "proper statistical terminology in results."
            )
        
        # Completeness recommendations
        if scores.get('completeness', 0) < 0.9:
            recommendations.append(
                "Ensure all required sections, figures, and tables are present "
                "and properly referenced in the translated document."
            )
        
        # LaTeX recommendations
        if scores.get('latex_integrity', 0) < 0.9:
            recommendations.append(
                "Check LaTeX structure integrity. Ensure all essential commands "
                "and environments are properly formatted."
            )
        
        if scores.get('latex_compilation', 0) < 1.0:
            recommendations.append(
                "Fix LaTeX compilation issues. Check for syntax errors, "
                "missing packages, or formatting problems."
            )
        
        self.report_data['recommendations'] = recommendations

    def run_comprehensive_quality_tests(self) -> Dict[str, Any]:
        """Run all quality assurance tests"""
        print("Starting comprehensive quality assurance review...")
        print("=" * 60)
        
        # Read document content
        content = self.read_tex_file()
        if not content:
            print("ERROR: Could not read document content")
            return self.report_data
        
        # Execute all quality tests
        self.report_data['tests_performed'] = [
            'technical_terminology_accuracy',
            'academic_writing_quality', 
            'translation_completeness',
            'latex_integrity',
            'latex_compilation'
        ]
        
        # Run individual tests
        self.test_technical_terminology_accuracy(content)
        self.test_academic_writing_quality(content)
        self.test_translation_completeness(content)
        self.test_latex_integrity(content)
        self.test_latex_compilation()
        
        # Calculate overall score and generate recommendations
        overall_score, quality_level = self.calculate_overall_quality_score()
        self.report_data['overall_score'] = overall_score
        self.report_data['quality_level'] = quality_level
        
        self.generate_recommendations()
        
        print("=" * 60)
        print(f"Overall Quality Score: {overall_score:.2%} ({quality_level})")
        print("Quality assurance review completed.")
        
        return self.report_data

    def generate_quality_report(self, output_file: str = None) -> str:
        """Generate comprehensive quality report"""
        if output_file is None:
            timestamp = self.report_data['timestamp']
            output_file = f"translation_quality_report_{timestamp}.txt"
        
        report_lines = [
            "COMPREHENSIVE TRANSLATION QUALITY ASSURANCE REPORT",
            "=" * 60,
            f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            f"Document: {self.tex_file_path}",
            "",
            "OVERALL ASSESSMENT",
            "-" * 30,
            f"Overall Quality Score: {self.report_data.get('overall_score', 0):.2%}",
            f"Quality Level: {self.report_data.get('quality_level', 'Unknown')}",
            "",
            "DETAILED SCORES",
            "-" * 30
        ]
        
        # Add detailed scores
        for metric, score in self.report_data['quality_scores'].items():
            metric_name = metric.replace('_', ' ').title()
            report_lines.append(f"{metric_name}: {score:.2%}")
        
        # Add issues found
        if self.report_data['issues_found']:
            report_lines.extend([
                "",
                "ISSUES IDENTIFIED",
                "-" * 30
            ])
            for i, issue in enumerate(self.report_data['issues_found'], 1):
                report_lines.append(f"{i}. {issue}")
        
        # Add recommendations
        if self.report_data['recommendations']:
            report_lines.extend([
                "",
                "RECOMMENDATIONS",
                "-" * 30
            ])
            for i, rec in enumerate(self.report_data['recommendations'], 1):
                report_lines.append(f"{i}. {rec}")
        
        # Add test summary
        report_lines.extend([
            "",
            "TESTS PERFORMED",
            "-" * 30
        ])
        for test in self.report_data['tests_performed']:
            test_name = test.replace('_', ' ').title()
            report_lines.append(f"✓ {test_name}")
        
        report_lines.extend([
            "",
            "QUALITY CRITERIA",
            "-" * 30,
            "Excellent (95-100%): Publication ready",
            "Very Good (85-94%): Minor revisions needed", 
            "Good (75-84%): Moderate revisions needed",
            "Acceptable (60-74%): Major revisions needed",
            "Needs Improvement (<60%): Significant work required",
            "",
            "END OF REPORT"
        ])
        
        # Write report to file
        report_content = '\n'.join(report_lines)
        
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(report_content)
            print(f"Quality report saved to: {output_file}")
        except Exception as e:
            print(f"Error saving report: {e}")
        
        return report_content


def main():
    """Main execution function"""
    print("English Translation - Comprehensive Quality Assurance")
    print("=" * 60)
    
    # Initialize quality assurance system
    qa_system = ComprehensiveQualityAssurance()
    
    # Run comprehensive tests
    results = qa_system.run_comprehensive_quality_tests()
    
    # Generate and save report
    report_content = qa_system.generate_quality_report()
    
    # Print summary
    print("\nQUALITY ASSESSMENT SUMMARY")
    print("-" * 40)
    print(f"Overall Score: {results.get('overall_score', 0):.2%}")
    print(f"Quality Level: {results.get('quality_level', 'Unknown')}")
    print(f"Issues Found: {len(results.get('issues_found', []))}")
    print(f"Recommendations: {len(results.get('recommendations', []))}")
    
    return results


if __name__ == "__main__":
    main()