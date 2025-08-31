#!/usr/bin/env python3
"""
Task 14: Comprehensive Quality Assurance Review
Execute comprehensive translation quality tests and generate quality report
"""

import re
import os
import sys
from datetime import datetime
from pathlib import Path
import subprocess

class ComprehensiveQualityAssurance:
    """Comprehensive Quality Assurance for English Translation - Task 14"""
    
    def __init__(self, tex_file='artigo_cientifico_corrosao.tex'):
        self.tex_file = tex_file
        self.qa_results = {
            'timestamp': datetime.now().strftime('%Y%m%d_%H%M%S'),
            'tests_performed': [],
            'quality_scores': {},
            'issues_found': {},
            'recommendations': []
        }
        
    def run_task_14(self):
        """Execute Task 14: Perform final quality assurance review"""
        
        print("TASK 14: COMPREHENSIVE QUALITY ASSURANCE REVIEW")
        print("=" * 60)
        print("English Translation Final Quality Assessment")
        print(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        
        try:
            # Sub-task 14.1: Execute comprehensive translation quality tests
            print("SUB-TASK 14.1: Executing comprehensive translation quality tests")
            print("-" * 60)
            self.execute_comprehensive_quality_tests()
            
            # Sub-task 14.2: Verify academic writing quality meets English standards
            print("\nSUB-TASK 14.2: Verifying academic writing quality standards")
            print("-" * 60)
            self.verify_academic_writing_standards()
            
            # Sub-task 14.3: Check technical accuracy of all translated content
            print("\nSUB-TASK 14.3: Checking technical accuracy of translated content")
            print("-" * 60)
            self.check_technical_accuracy()
            
            # Sub-task 14.4: Generate translation quality report
            print("\nSUB-TASK 14.4: Generating comprehensive translation quality report")
            print("-" * 60)
            
            # Calculate overall quality metrics
            overall_score, quality_level = self.calculate_overall_quality_score()
            self.qa_results['overall_score'] = overall_score
            self.qa_results['quality_level'] = quality_level
            
            # Generate recommendations
            self.qa_results['recommendations'] = self.generate_quality_recommendations()
            
            # Generate comprehensive report
            report_file = self.generate_comprehensive_quality_report()
            
            # Display final summary
            self.display_quality_assessment_summary(report_file)
            
            print(f"\n✓ TASK 14 COMPLETED: Final quality assurance review finished")
            print(f"Report saved to: {report_file}")
            
            return True
            
        except Exception as e:
            print(f"✗ ERROR in Task 14: {str(e)}")
            return False
    
    def execute_comprehensive_quality_tests(self):
        """Execute comprehensive translation quality tests"""
        
        print("Executing comprehensive quality tests...")
        
        # Test 1: Technical terminology accuracy
        print("  → Testing technical terminology accuracy...")
        term_score, term_issues = self.test_technical_terminology_accuracy()
        self.qa_results['quality_scores']['technical_terminology'] = term_score
        self.qa_results['issues_found']['terminology'] = term_issues
        self.qa_results['tests_performed'].append('technical_terminology_accuracy')
        print(f"    Score: {term_score * 100:.1f}%")
        
        # Test 2: Translation completeness
        print("  → Testing translation completeness...")
        complete_score, complete_issues = self.test_translation_completeness()
        self.qa_results['quality_scores']['translation_completeness'] = complete_score
        self.qa_results['issues_found']['completeness'] = complete_issues
        self.qa_results['tests_performed'].append('translation_completeness')
        print(f"    Score: {complete_score * 100:.1f}%")
        
        # Test 3: LaTeX structure integrity
        print("  → Testing LaTeX structure integrity...")
        latex_score, latex_issues = self.test_latex_structure_integrity()
        self.qa_results['quality_scores']['latex_integrity'] = latex_score
        self.qa_results['issues_found']['latex_structure'] = latex_issues
        self.qa_results['tests_performed'].append('latex_structure_integrity')
        print(f"    Score: {latex_score * 100:.1f}%")
        
        # Test 4: Reference consistency
        print("  → Testing reference consistency...")
        ref_score, ref_issues = self.test_reference_consistency()
        self.qa_results['quality_scores']['reference_consistency'] = ref_score
        self.qa_results['issues_found']['references'] = ref_issues
        self.qa_results['tests_performed'].append('reference_consistency')
        print(f"    Score: {ref_score * 100:.1f}%")
    
    def verify_academic_writing_standards(self):
        """Verify academic writing quality meets English standards"""
        
        print("Verifying academic writing standards...")
        
        # Test 1: Abstract structure compliance
        print("  → Checking abstract structure...")
        abstract_score, abstract_issues = self.check_abstract_structure()
        self.qa_results['quality_scores']['abstract_structure'] = abstract_score
        self.qa_results['issues_found']['abstract'] = abstract_issues
        self.qa_results['tests_performed'].append('abstract_structure_compliance')
        print(f"    Score: {abstract_score * 100:.1f}%")
        
        # Test 2: Academic tone and style
        print("  → Analyzing academic tone and style...")
        tone_score, tone_issues = self.analyze_academic_tone()
        self.qa_results['quality_scores']['academic_tone'] = tone_score
        self.qa_results['issues_found']['tone'] = tone_issues
        self.qa_results['tests_performed'].append('academic_tone_analysis')
        print(f"    Score: {tone_score * 100:.1f}%")
        
        # Test 3: Scientific methodology presentation
        print("  → Evaluating methodology presentation...")
        method_score, method_issues = self.evaluate_methodology_presentation()
        self.qa_results['quality_scores']['methodology_presentation'] = method_score
        self.qa_results['issues_found']['methodology'] = method_issues
        self.qa_results['tests_performed'].append('methodology_presentation')
        print(f"    Score: {method_score * 100:.1f}%")
        
        # Test 4: Results and discussion quality
        print("  → Assessing results and discussion quality...")
        results_score, results_issues = self.assess_results_discussion_quality()
        self.qa_results['quality_scores']['results_discussion'] = results_score
        self.qa_results['issues_found']['results_discussion'] = results_issues
        self.qa_results['tests_performed'].append('results_discussion_quality')
        print(f"    Score: {results_score * 100:.1f}%")
    
    def check_technical_accuracy(self):
        """Check technical accuracy of all translated content"""
        
        print("Checking technical accuracy of translated content...")
        
        # Test 1: Engineering terminology accuracy
        print("  → Validating engineering terminology...")
        eng_score, eng_issues = self.validate_engineering_terminology()
        self.qa_results['quality_scores']['engineering_terminology'] = eng_score
        self.qa_results['issues_found']['engineering'] = eng_issues
        self.qa_results['tests_performed'].append('engineering_terminology_validation')
        print(f"    Score: {eng_score * 100:.1f}%")
        
        # Test 2: AI/ML terminology accuracy
        print("  → Validating AI/ML terminology...")
        ai_score, ai_issues = self.validate_ai_ml_terminology()
        self.qa_results['quality_scores']['ai_ml_terminology'] = ai_score
        self.qa_results['issues_found']['ai_ml'] = ai_issues
        self.qa_results['tests_performed'].append('ai_ml_terminology_validation')
        print(f"    Score: {ai_score * 100:.1f}%")
        
        # Test 3: Mathematical notation consistency
        print("  → Checking mathematical notation...")
        math_score, math_issues = self.check_mathematical_notation()
        self.qa_results['quality_scores']['mathematical_notation'] = math_score
        self.qa_results['issues_found']['mathematics'] = math_issues
        self.qa_results['tests_performed'].append('mathematical_notation_consistency')
        print(f"    Score: {math_score * 100:.1f}%")
        
        # Test 4: Statistical terminology accuracy
        print("  → Validating statistical terminology...")
        stats_score, stats_issues = self.validate_statistical_terminology()
        self.qa_results['quality_scores']['statistical_terminology'] = stats_score
        self.qa_results['issues_found']['statistics'] = stats_issues
        self.qa_results['tests_performed'].append('statistical_terminology_validation')
        print(f"    Score: {stats_score * 100:.1f}%")
    
    def read_tex_file(self):
        """Read LaTeX file content safely"""
        try:
            if not os.path.exists(self.tex_file):
                return ""
            
            with open(self.tex_file, 'r', encoding='utf-8') as f:
                return f.read()
        except Exception:
            return ""
    
    def test_technical_terminology_accuracy(self):
        """Test technical terminology accuracy and consistency"""
        
        issues = []
        
        try:
            content = self.read_tex_file()
            if not content:
                issues.append('Could not read LaTeX file')
                return 0, issues
            
            content_lower = content.lower()
            
            # Required English technical terms
            required_terms = [
                'ASTM A572 Grade 50', 'W-beams', 'structural inspection',
                'corrosion', 'structural integrity', 'deterioration',
                'convolutional neural networks', 'semantic segmentation',
                'deep learning', 'attention mechanisms', 'U-Net',
                'Attention U-Net', 'IoU', 'Dice coefficient',
                'precision', 'recall', 'F1-score', 'accuracy'
            ]
            
            # Portuguese terms that should NOT be present
            portuguese_terms = [
                'aço', 'corrosão', 'viga', 'treinamento', 'validação',
                'precisão', 'revocação', 'acurácia', 'segmentação',
                'aprendizado', 'rede neural', 'convolucional', 'metodologia'
            ]
            
            # Check for required English terms
            terms_found = 0
            for term in required_terms:
                if term.lower() in content_lower:
                    terms_found += 1
                else:
                    issues.append(f'Missing technical term: {term}')
            
            # Check for Portuguese terms (should not be present)
            portuguese_found = 0
            for term in portuguese_terms:
                if re.search(r'\b' + re.escape(term) + r'\b', content_lower):
                    portuguese_found += 1
                    issues.append(f'Portuguese term found: {term}')
            
            # Calculate score
            base_score = terms_found / len(required_terms)
            
            # Apply penalty for Portuguese terms
            if portuguese_found > 0:
                penalty = min(portuguese_found * 0.1, 0.5)  # Max 50% penalty
                score = max(0, base_score - penalty)
            else:
                score = base_score
            
            return score, issues
            
        except Exception as e:
            issues.append(f'Error in terminology test: {str(e)}')
            return 0, issues
    
    def test_translation_completeness(self):
        """Test translation completeness and content preservation"""
        
        issues = []
        
        try:
            content = self.read_tex_file()
            if not content:
                issues.append('Could not read LaTeX file')
                return 0, issues
            
            completeness_score = 0
            total_sections = 0
            
            # Required sections for scientific article
            required_sections = ['abstract', 'introduction', 'methodology', 'results', 'discussion', 'conclusion']
            sections_found = 0
            
            for section in required_sections:
                section_pattern = rf'\\section\{{.*?{section}.*?\}}'
                if re.search(section_pattern, content, re.IGNORECASE):
                    sections_found += 1
                else:
                    issues.append(f'Required section missing: {section}')
            
            completeness_score += sections_found / len(required_sections)
            total_sections += 1
            
            # Check figure references
            figure_refs = ['Figure 1', 'Figure 2', 'Figure 3', 'Figure 4', 'Figure 5', 'Figure 6', 'Figure 7']
            figures_found = 0
            
            for fig_ref in figure_refs:
                if fig_ref in content:
                    figures_found += 1
                else:
                    issues.append(f'Figure reference missing: {fig_ref}')
            
            completeness_score += figures_found / len(figure_refs)
            total_sections += 1
            
            # Check table references
            table_refs = ['Table 1', 'Table 2', 'Table 3', 'Table 4']
            tables_found = 0
            
            for table_ref in table_refs:
                if table_ref in content:
                    tables_found += 1
                else:
                    issues.append(f'Table reference missing: {table_ref}')
            
            completeness_score += tables_found / len(table_refs)
            total_sections += 1
            
            # Final score
            score = completeness_score / total_sections
            
            return score, issues
            
        except Exception as e:
            issues.append(f'Error in completeness test: {str(e)}')
            return 0, issues
    
    def test_latex_structure_integrity(self):
        """Test LaTeX structure integrity"""
        
        issues = []
        
        try:
            content = self.read_tex_file()
            if not content:
                issues.append('Could not read LaTeX file')
                return 0, issues
            
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
                    issues.append(f'Essential LaTeX command missing: {command}')
                integrity_checks += 1
            
            # Mathematical environments
            math_envs = [r'\\begin{equation}', r'\\end{equation}']
            math_found = 0
            
            for env in math_envs:
                if re.search(env, content):
                    math_found += 1
            
            if math_found == len(math_envs):
                passed_checks += 1
            elif math_found > 0:
                issues.append('Incomplete mathematical environments found')
            integrity_checks += 1
            
            # Bibliography
            if re.search(r'\\bibliography\{', content) or re.search(r'\\bibitem', content):
                passed_checks += 1
            else:
                issues.append('Bibliography section missing or improperly formatted')
            integrity_checks += 1
            
            # Calculate score
            score = passed_checks / integrity_checks if integrity_checks > 0 else 0
            
            return score, issues
            
        except Exception as e:
            issues.append(f'Error in LaTeX integrity test: {str(e)}')
            return 0, issues
    
    def test_reference_consistency(self):
        """Test reference consistency"""
        
        issues = []
        
        try:
            content = self.read_tex_file()
            if not content:
                issues.append('Could not read LaTeX file')
                return 0, issues
            
            # Find all labels
            all_labels = re.findall(r'\\label\{([^}]+)\}', content)
            
            # Find all references
            all_refs = re.findall(r'\\ref\{([^}]+)\}', content)
            
            # Check for unresolved references
            unresolved_refs = []
            for ref in all_refs:
                if ref not in all_labels:
                    unresolved_refs.append(ref)
            
            # Check for unused labels
            unused_labels = []
            for label in all_labels:
                if label not in all_refs:
                    unused_labels.append(label)
            
            # Calculate score
            total_refs = len(all_refs)
            resolved_refs = total_refs - len(unresolved_refs)
            
            if total_refs > 0:
                score = resolved_refs / total_refs
            else:
                score = 1.0  # No references to check
            
            # Add issues
            for ref in unresolved_refs:
                issues.append(f'Unresolved reference: {ref}')
            
            for label in unused_labels:
                issues.append(f'Unused label: {label}')
            
            return score, issues
            
        except Exception as e:
            issues.append(f'Error in reference consistency test: {str(e)}')
            return 0, issues
    
    def check_abstract_structure(self):
        """Check abstract structure compliance"""
        
        issues = []
        
        try:
            content = self.read_tex_file()
            if not content:
                issues.append('Could not read LaTeX file')
                return 0, issues
            
            # Extract abstract content
            abstract_pattern = r'\\begin\{abstract\}(.*?)\\end\{abstract\}'
            abstract_match = re.search(abstract_pattern, content, re.DOTALL | re.IGNORECASE)
            
            if not abstract_match:
                issues.append('Abstract section not found')
                return 0, issues
            
            abstract_text = abstract_match.group(1).lower()
            
            # Check for required abstract components
            abstract_components = ['background', 'objective', 'method', 'result', 'conclusion']
            components_found = 0
            
            for component in abstract_components:
                if component in abstract_text:
                    components_found += 1
                else:
                    issues.append(f'Abstract missing component: {component}')
            
            score = components_found / len(abstract_components)
            
            return score, issues
            
        except Exception as e:
            issues.append(f'Error in abstract structure check: {str(e)}')
            return 0, issues
    
    def analyze_academic_tone(self):
        """Analyze academic tone and style"""
        
        issues = []
        
        try:
            content = self.read_tex_file()
            if not content:
                issues.append('Could not read LaTeX file')
                return 0, issues
            
            content_lower = content.lower()
            
            # Check for academic indicators
            academic_indicators = [
                'however', 'furthermore', 'moreover', 'therefore', 'consequently',
                'in contrast', 'on the other hand', 'in addition', 'specifically',
                'particularly', 'significantly', 'substantially'
            ]
            
            indicators_found = 0
            for indicator in academic_indicators:
                if indicator in content_lower:
                    indicators_found += 1
            
            # Check for passive voice in methodology
            methodology_pattern = r'\\section\{.*?methodology.*?\}(.*?)(?=\\section|$)'
            methodology_match = re.search(methodology_pattern, content_lower, re.DOTALL | re.IGNORECASE)
            
            passive_score = 0
            if methodology_match:
                methodology_text = methodology_match.group(1)
                passive_indicators = ['was performed', 'were conducted', 'was implemented', 'was used', 'were analyzed']
                
                passive_found = 0
                for indicator in passive_indicators:
                    if indicator in methodology_text:
                        passive_found += 1
                
                passive_score = min(passive_found / 3, 1.0)
            else:
                issues.append('Methodology section not found for passive voice analysis')
            
            # Calculate overall tone score
            indicator_score = min(indicators_found / 8, 1.0)  # Normalize to max 1.0
            score = (indicator_score + passive_score) / 2
            
            return score, issues
            
        except Exception as e:
            issues.append(f'Error in academic tone analysis: {str(e)}')
            return 0, issues
    
    def evaluate_methodology_presentation(self):
        """Evaluate methodology presentation"""
        
        issues = []
        
        try:
            content = self.read_tex_file()
            if not content:
                issues.append('Could not read LaTeX file')
                return 0, issues
            
            # Extract methodology section
            methodology_pattern = r'\\section\{.*?methodology.*?\}(.*?)(?=\\section|$)'
            methodology_match = re.search(methodology_pattern, content, re.DOTALL | re.IGNORECASE)
            
            if not methodology_match:
                issues.append('Methodology section not found')
                return 0, issues
            
            methodology_text = methodology_match.group(1).lower()
            
            # Check for methodology components
            methodology_components = [
                'dataset', 'training', 'validation', 'evaluation', 'metrics',
                'architecture', 'parameters', 'preprocessing', 'augmentation'
            ]
            
            components_found = 0
            for component in methodology_components:
                if component in methodology_text:
                    components_found += 1
                else:
                    issues.append(f'Methodology missing component: {component}')
            
            score = components_found / len(methodology_components)
            
            return score, issues
            
        except Exception as e:
            issues.append(f'Error in methodology evaluation: {str(e)}')
            return 0, issues
    
    def assess_results_discussion_quality(self):
        """Assess results and discussion quality"""
        
        issues = []
        
        try:
            content = self.read_tex_file()
            if not content:
                issues.append('Could not read LaTeX file')
                return 0, issues
            
            content_lower = content.lower()
            
            # Check for statistical terminology in results
            stats_terms = ['p <', 'confidence interval', 'standard deviation', 'significant', 'correlation']
            stats_found = 0
            
            for term in stats_terms:
                if term in content_lower:
                    stats_found += 1
            
            # Check for discussion elements
            discussion_elements = ['limitation', 'implication', 'future work', 'comparison', 'interpretation']
            discussion_found = 0
            
            for element in discussion_elements:
                if element in content_lower:
                    discussion_found += 1
            
            # Calculate score
            stats_score = min(stats_found / 3, 1.0)
            discussion_score = min(discussion_found / 3, 1.0)
            score = (stats_score + discussion_score) / 2
            
            if stats_found == 0:
                issues.append('No statistical terminology found in results')
            
            if discussion_found == 0:
                issues.append('No discussion elements found')
            
            return score, issues
            
        except Exception as e:
            issues.append(f'Error in results/discussion assessment: {str(e)}')
            return 0, issues
    
    def validate_engineering_terminology(self):
        """Validate engineering terminology"""
        
        issues = []
        
        try:
            content = self.read_tex_file()
            if not content:
                issues.append('Could not read LaTeX file')
                return 0, issues
            
            content_lower = content.lower()
            
            # Engineering terms that should be present
            engineering_terms = [
                'ASTM A572 Grade 50', 'W-beams', 'structural inspection',
                'corrosion', 'structural integrity', 'deterioration',
                'steel', 'structural', 'inspection', 'integrity'
            ]
            
            terms_found = 0
            for term in engineering_terms:
                if term.lower() in content_lower:
                    terms_found += 1
                else:
                    issues.append(f'Missing engineering term: {term}')
            
            score = terms_found / len(engineering_terms)
            
            return score, issues
            
        except Exception as e:
            issues.append(f'Error in engineering terminology validation: {str(e)}')
            return 0, issues
    
    def validate_ai_ml_terminology(self):
        """Validate AI/ML terminology"""
        
        issues = []
        
        try:
            content = self.read_tex_file()
            if not content:
                issues.append('Could not read LaTeX file')
                return 0, issues
            
            content_lower = content.lower()
            
            # AI/ML terms that should be present
            ai_ml_terms = [
                'convolutional neural networks', 'semantic segmentation',
                'deep learning', 'attention mechanisms', 'U-Net',
                'training', 'validation', 'neural network'
            ]
            
            terms_found = 0
            for term in ai_ml_terms:
                if term.lower() in content_lower:
                    terms_found += 1
                else:
                    issues.append(f'Missing AI/ML term: {term}')
            
            score = terms_found / len(ai_ml_terms)
            
            return score, issues
            
        except Exception as e:
            issues.append(f'Error in AI/ML terminology validation: {str(e)}')
            return 0, issues
    
    def check_mathematical_notation(self):
        """Check mathematical notation consistency"""
        
        issues = []
        
        try:
            content = self.read_tex_file()
            if not content:
                issues.append('Could not read LaTeX file')
                return 0, issues
            
            # Check for equation environments
            begin_eq = len(re.findall(r'\\begin\{equation\}', content))
            end_eq = len(re.findall(r'\\end\{equation\}', content))
            
            # Check for mathematical symbols
            math_symbols = [r'\\alpha', r'\\beta', r'\\sigma', r'\\times', r'\\leq', r'\\geq']
            symbols_found = 0
            
            for symbol in math_symbols:
                if re.search(symbol, content):
                    symbols_found += 1
            
            # Calculate score
            equation_balance = (begin_eq == end_eq)
            symbol_presence = (symbols_found > 0)
            
            score_components = [equation_balance, symbol_presence]
            score = sum(score_components) / len(score_components)
            
            if not equation_balance:
                issues.append(f'Unbalanced equation environments: {begin_eq} begin, {end_eq} end')
            
            if not symbol_presence:
                issues.append('No mathematical symbols found')
            
            return score, issues
            
        except Exception as e:
            issues.append(f'Error in mathematical notation check: {str(e)}')
            return 0, issues
    
    def validate_statistical_terminology(self):
        """Validate statistical terminology"""
        
        issues = []
        
        try:
            content = self.read_tex_file()
            if not content:
                issues.append('Could not read LaTeX file')
                return 0, issues
            
            content_lower = content.lower()
            
            # Statistical terms that should be present
            stats_terms = [
                'IoU', 'Dice coefficient', 'precision', 'recall',
                'F1-score', 'accuracy', 'mean', 'standard deviation'
            ]
            
            terms_found = 0
            for term in stats_terms:
                if term.lower() in content_lower:
                    terms_found += 1
                else:
                    issues.append(f'Missing statistical term: {term}')
            
            score = terms_found / len(stats_terms)
            
            return score, issues
            
        except Exception as e:
            issues.append(f'Error in statistical terminology validation: {str(e)}')
            return 0, issues
    
    def calculate_overall_quality_score(self):
        """Calculate overall quality score with weighted average"""
        
        # Define weights for different quality aspects
        weights = {
            'technical_terminology': 0.15,
            'translation_completeness': 0.15,
            'latex_integrity': 0.10,
            'reference_consistency': 0.10,
            'abstract_structure': 0.10,
            'academic_tone': 0.10,
            'methodology_presentation': 0.10,
            'results_discussion': 0.10,
            'engineering_terminology': 0.05,
            'ai_ml_terminology': 0.05,
            'mathematical_notation': 0.05,
            'statistical_terminology': 0.05
        }
        
        # Calculate weighted average
        total_score = 0
        total_weight = 0
        
        for metric, weight in weights.items():
            if metric in self.qa_results['quality_scores']:
                total_score += self.qa_results['quality_scores'][metric] * weight
                total_weight += weight
        
        if total_weight > 0:
            overall_score = total_score / total_weight
        else:
            overall_score = 0
        
        # Determine quality level
        if overall_score >= 0.95:
            quality_level = 'Excellent'
        elif overall_score >= 0.85:
            quality_level = 'Very Good'
        elif overall_score >= 0.75:
            quality_level = 'Good'
        elif overall_score >= 0.60:
            quality_level = 'Acceptable'
        else:
            quality_level = 'Needs Improvement'
        
        return overall_score, quality_level
    
    def generate_quality_recommendations(self):
        """Generate quality recommendations based on scores and issues"""
        
        recommendations = []
        scores = self.qa_results['quality_scores']
        
        # Technical terminology recommendations
        if scores.get('technical_terminology', 0) < 0.8:
            recommendations.append('Review technical terminology consistency and accuracy. Ensure all Portuguese terms are properly translated to English.')
        
        # Academic writing recommendations
        if scores.get('abstract_structure', 0) < 0.8:
            recommendations.append('Improve abstract structure to include all required components: background, objective, methods, results, conclusions.')
        
        if scores.get('academic_tone', 0) < 0.8:
            recommendations.append('Enhance academic writing tone. Use more academic connectors and ensure proper passive voice in methodology.')
        
        # Completeness recommendations
        if scores.get('translation_completeness', 0) < 0.9:
            recommendations.append('Ensure all required sections, figures, and tables are present and properly referenced.')
        
        # Technical accuracy recommendations
        if scores.get('engineering_terminology', 0) < 0.8:
            recommendations.append('Review engineering terminology accuracy, particularly for ASTM standards and structural components.')
        
        if scores.get('ai_ml_terminology', 0) < 0.8:
            recommendations.append('Verify AI/ML terminology accuracy, especially for neural network architectures and evaluation metrics.')
        
        # LaTeX recommendations
        if scores.get('latex_integrity', 0) < 0.9:
            recommendations.append('Check LaTeX structure integrity and ensure all essential commands are properly formatted.')
        
        if scores.get('reference_consistency', 0) < 0.9:
            recommendations.append('Fix reference consistency issues. Ensure all references have corresponding labels.')
        
        # Mathematical recommendations
        if scores.get('mathematical_notation', 0) < 0.9:
            recommendations.append('Review mathematical notation consistency and ensure equation environments are properly balanced.')
        
        # Default recommendation if quality is excellent
        if not recommendations:
            recommendations.append('Translation quality is excellent. Document is ready for publication.')
        
        return recommendations
    
    def generate_comprehensive_quality_report(self):
        """Generate comprehensive quality report"""
        
        timestamp = self.qa_results['timestamp']
        report_file = f'comprehensive_quality_report_{timestamp}.txt'
        
        try:
            with open(report_file, 'w', encoding='utf-8') as f:
                # Header
                f.write('COMPREHENSIVE TRANSLATION QUALITY ASSURANCE REPORT\n')
                f.write('=' * 60 + '\n')
                f.write(f'Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}\n')
                f.write(f'Document: {self.tex_file}\n')
                f.write('Task: 14 - Final Quality Assurance Review\n\n')
                
                # Overall Assessment
                f.write('OVERALL ASSESSMENT\n')
                f.write('=' * 20 + '\n')
                f.write(f'Overall Quality Score: {self.qa_results["overall_score"] * 100:.1f}%\n')
                f.write(f'Quality Level: {self.qa_results["quality_level"]}\n\n')
                
                # Detailed Scores
                f.write('DETAILED QUALITY SCORES\n')
                f.write('=' * 25 + '\n')
                for metric, score in self.qa_results['quality_scores'].items():
                    metric_name = metric.replace('_', ' ').title()
                    f.write(f'{metric_name:<30}: {score * 100:6.1f}%\n')
                
                # Issues Found
                f.write('\nISSUES IDENTIFIED\n')
                f.write('=' * 20 + '\n')
                issue_count = 1
                
                for category, issues in self.qa_results['issues_found'].items():
                    if issues:
                        f.write(f'\n{category.replace("_", " ").title()} Issues:\n')
                        f.write('-' * (len(category) + 8) + '\n')
                        for issue in issues:
                            f.write(f'{issue_count}. {issue}\n')
                            issue_count += 1
                
                # Recommendations
                f.write('\nRECOMMENDATIONS\n')
                f.write('=' * 15 + '\n')
                for i, rec in enumerate(self.qa_results['recommendations'], 1):
                    f.write(f'{i}. {rec}\n\n')
                
                # Tests Performed
                f.write('TESTS PERFORMED\n')
                f.write('=' * 15 + '\n')
                for test in self.qa_results['tests_performed']:
                    test_name = test.replace('_', ' ').title()
                    f.write(f'✓ {test_name}\n')
                
                # Quality Criteria
                f.write('\nQUALITY CRITERIA\n')
                f.write('=' * 16 + '\n')
                f.write('Excellent (95-100%):     Publication ready\n')
                f.write('Very Good (85-94%):      Minor revisions needed\n')
                f.write('Good (75-84%):           Moderate revisions needed\n')
                f.write('Acceptable (60-74%):     Major revisions needed\n')
                f.write('Needs Improvement (<60%): Significant work required\n\n')
                
                # Final Assessment
                f.write('FINAL ASSESSMENT\n')
                f.write('=' * 16 + '\n')
                overall_score = self.qa_results['overall_score']
                if overall_score >= 0.95:
                    f.write('✓ RESULT: Translation is PUBLICATION READY\n')
                    f.write('The document meets all quality standards for international publication.\n')
                elif overall_score >= 0.85:
                    f.write('⚠ RESULT: Translation needs MINOR REVISIONS\n')
                    f.write('The document is of high quality but requires minor improvements.\n')
                elif overall_score >= 0.75:
                    f.write('⚠ RESULT: Translation needs MODERATE REVISIONS\n')
                    f.write('The document requires moderate improvements before publication.\n')
                elif overall_score >= 0.60:
                    f.write('⚠ RESULT: Translation needs MAJOR REVISIONS\n')
                    f.write('The document requires significant improvements before publication.\n')
                else:
                    f.write('❌ RESULT: Translation needs SIGNIFICANT WORK\n')
                    f.write('The document requires extensive revision before publication consideration.\n')
                
                f.write('\nEND OF REPORT\n')
                f.write('=' * 13 + '\n')
            
            return report_file
            
        except Exception as e:
            print(f'Error generating comprehensive report: {str(e)}')
            return ''
    
    def display_quality_assessment_summary(self, report_file):
        """Display quality assessment summary"""
        
        print('\n' + '=' * 60)
        print('COMPREHENSIVE QUALITY ASSESSMENT SUMMARY')
        print('=' * 60)
        
        print(f'Overall Quality Score: {self.qa_results["overall_score"] * 100:.1f}% ({self.qa_results["quality_level"]})')
        
        # Count total issues
        total_issues = sum(len(issues) for issues in self.qa_results['issues_found'].values() if isinstance(issues, list))
        
        print(f'Total Issues Found: {total_issues}')
        print(f'Recommendations: {len(self.qa_results["recommendations"])}')
        print(f'Tests Performed: {len(self.qa_results["tests_performed"])}')
        
        print('\nQUALITY BREAKDOWN:')
        for metric, score in self.qa_results['quality_scores'].items():
            metric_name = metric.replace('_', ' ').title()
            
            if score >= 0.9:
                status = '✓ Excellent'
            elif score >= 0.8:
                status = '⚠ Good'
            elif score >= 0.7:
                status = '⚠ Acceptable'
            else:
                status = '❌ Needs Work'
            
            print(f'  {metric_name:<25}: {score * 100:6.1f}% {status}')
        
        print('\nFINAL RECOMMENDATION:')
        overall_score = self.qa_results['overall_score']
        if overall_score >= 0.95:
            print('✓ PUBLICATION READY: Document meets international standards')
        elif overall_score >= 0.85:
            print('⚠ MINOR REVISIONS: High quality with minor improvements needed')
        elif overall_score >= 0.75:
            print('⚠ MODERATE REVISIONS: Good quality requiring moderate improvements')
        elif overall_score >= 0.60:
            print('⚠ MAJOR REVISIONS: Acceptable quality requiring significant improvements')
        else:
            print('❌ SIGNIFICANT WORK: Extensive revision required')
        
        print(f'\nReport saved to: {report_file}')
        print('=' * 60)


def main():
    """Main execution function"""
    
    print("English Translation - Task 14: Comprehensive Quality Assurance")
    print("=" * 60)
    
    # Initialize quality assurance system
    qa_system = ComprehensiveQualityAssurance()
    
    # Run Task 14
    success = qa_system.run_task_14()
    
    if success:
        print("\n✓ Task 14 completed successfully")
        return 0
    else:
        print("\n✗ Task 14 failed")
        return 1


if __name__ == "__main__":
    exit(main())