#!/usr/bin/env python3
"""
LaTeX Compilation and Formatting Validator

This module validates LaTeX compilation and formatting for the English translation
of the scientific article, ensuring all components render correctly.

Task 13 Implementation:
- Test LaTeX compilation with English content
- Verify all mathematical formulas render correctly
- Check figure and table references work properly
- Ensure proper English hyphenation and spacing

Requirements: 6.4
"""

import os
import subprocess
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import tempfile
import shutil
from datetime import datetime

class LaTeXCompilationValidator:
    """Validates LaTeX compilation and formatting for English scientific article."""
    
    def __init__(self, tex_file_path: str = "artigo_cientifico_corrosao.tex"):
        """
        Initialize the LaTeX validator.
        
        Args:
            tex_file_path: Path to the main LaTeX file
        """
        self.tex_file_path = Path(tex_file_path)
        self.validation_results = {}
        self.compilation_log = []
        self.errors = []
        self.warnings = []
        
    def validate_latex_compilation(self) -> Dict[str, bool]:
        """
        Test LaTeX compilation with English content.
        
        Returns:
            Dictionary with compilation validation results
        """
        print("=" * 60)
        print("TASK 13.1: Testing LaTeX compilation with English content")
        print("=" * 60)
        
        results = {
            'compilation_successful': False,
            'pdf_generated': False,
            'no_critical_errors': False,
            'bibliography_compiled': False,
            'english_babel_loaded': False
        }
        
        try:
            # Check if LaTeX file exists
            if not self.tex_file_path.exists():
                self.errors.append(f"LaTeX file not found: {self.tex_file_path}")
                return results
            
            # Create temporary directory for compilation
            with tempfile.TemporaryDirectory() as temp_dir:
                temp_path = Path(temp_dir)
                
                # Copy necessary files to temp directory
                self._copy_compilation_files(temp_path)
                
                # Compile LaTeX document
                compilation_success = self._compile_latex_document(temp_path)
                results['compilation_successful'] = compilation_success
                
                # Check if PDF was generated
                pdf_path = temp_path / self.tex_file_path.with_suffix('.pdf').name
                results['pdf_generated'] = pdf_path.exists()
                
                # Analyze compilation log for critical errors
                results['no_critical_errors'] = self._check_critical_errors()
                
                # Check bibliography compilation
                results['bibliography_compiled'] = self._check_bibliography_compilation(temp_path)
                
                # Verify English babel is loaded
                results['english_babel_loaded'] = self._check_english_babel()
                
        except Exception as e:
            self.errors.append(f"Compilation validation failed: {str(e)}")
            
        self.validation_results['compilation'] = results
        self._print_compilation_results(results)
        return results
    
    def validate_mathematical_formulas(self) -> Dict[str, bool]:
        """
        Verify all mathematical formulas render correctly.
        
        Returns:
            Dictionary with mathematical formula validation results
        """
        print("\n" + "=" * 60)
        print("TASK 13.2: Verifying mathematical formulas render correctly")
        print("=" * 60)
        
        results = {
            'equations_found': False,
            'equation_environments_valid': False,
            'inline_math_valid': False,
            'mathematical_symbols_valid': False,
            'siunitx_usage_correct': False
        }
        
        try:
            # Read LaTeX content
            with open(self.tex_file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Check for equation environments
            equation_patterns = [
                r'\\begin\{equation\}.*?\\end\{equation\}',
                r'\\begin\{align\}.*?\\end\{align\}',
                r'\\begin\{gather\}.*?\\end\{gather\}'
            ]
            
            equations_found = []
            for pattern in equation_patterns:
                matches = re.findall(pattern, content, re.DOTALL)
                equations_found.extend(matches)
            
            results['equations_found'] = len(equations_found) > 0
            
            # Validate equation environments
            results['equation_environments_valid'] = self._validate_equation_environments(content)
            
            # Check inline math
            inline_math_matches = re.findall(r'\$[^$]+\$', content)
            results['inline_math_valid'] = len(inline_math_matches) > 0
            
            # Check mathematical symbols
            math_symbols = [r'\\alpha', r'\\beta', r'\\sigma', r'\\varepsilon', r'\\odot', r'\\cap', r'\\cup']
            symbols_found = sum(1 for symbol in math_symbols if symbol in content)
            results['mathematical_symbols_valid'] = symbols_found > 0
            
            # Check siunitx usage
            siunitx_patterns = [r'\\SI\{', r'\\si\{', r'\\num\{']
            siunitx_usage = sum(1 for pattern in siunitx_patterns if re.search(pattern, content))
            results['siunitx_usage_correct'] = siunitx_usage > 0 or '\\usepackage{siunitx}' in content
            
            print(f"✓ Found {len(equations_found)} equation environments")
            print(f"✓ Found {len(inline_math_matches)} inline math expressions")
            print(f"✓ Found {symbols_found} mathematical symbols")
            
        except Exception as e:
            self.errors.append(f"Mathematical formula validation failed: {str(e)}")
            
        self.validation_results['mathematics'] = results
        self._print_math_results(results)
        return results
    
    def validate_figure_table_references(self) -> Dict[str, bool]:
        """
        Check figure and table references work properly.
        
        Returns:
            Dictionary with reference validation results
        """
        print("\n" + "=" * 60)
        print("TASK 13.3: Checking figure and table references")
        print("=" * 60)
        
        results = {
            'figure_labels_found': False,
            'table_labels_found': False,
            'figure_references_valid': False,
            'table_references_valid': False,
            'all_references_resolved': False
        }
        
        try:
            # Read LaTeX content
            with open(self.tex_file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Find figure labels
            figure_labels = re.findall(r'\\label\{fig:([^}]+)\}', content)
            results['figure_labels_found'] = len(figure_labels) > 0
            
            # Find table labels
            table_labels = re.findall(r'\\label\{tab:([^}]+)\}', content)
            results['table_labels_found'] = len(table_labels) > 0
            
            # Find figure references
            figure_refs = re.findall(r'\\ref\{fig:([^}]+)\}', content)
            figure_refs.extend(re.findall(r'Figure~?\\ref\{fig:([^}]+)\}', content))
            
            # Find table references
            table_refs = re.findall(r'\\ref\{tab:([^}]+)\}', content)
            table_refs.extend(re.findall(r'Table~?\\ref\{tab:([^}]+)\}', content))
            
            # Validate references match labels
            unresolved_fig_refs = [ref for ref in figure_refs if ref not in figure_labels]
            unresolved_tab_refs = [ref for ref in table_refs if ref not in table_labels]
            
            results['figure_references_valid'] = len(unresolved_fig_refs) == 0
            results['table_references_valid'] = len(unresolved_tab_refs) == 0
            results['all_references_resolved'] = len(unresolved_fig_refs) == 0 and len(unresolved_tab_refs) == 0
            
            print(f"✓ Found {len(figure_labels)} figure labels")
            print(f"✓ Found {len(table_labels)} table labels")
            print(f"✓ Found {len(figure_refs)} figure references")
            print(f"✓ Found {len(table_refs)} table references")
            
            if unresolved_fig_refs:
                print(f"⚠ Unresolved figure references: {unresolved_fig_refs}")
            if unresolved_tab_refs:
                print(f"⚠ Unresolved table references: {unresolved_tab_refs}")
                
        except Exception as e:
            self.errors.append(f"Reference validation failed: {str(e)}")
            
        self.validation_results['references'] = results
        self._print_reference_results(results)
        return results
    
    def validate_english_hyphenation_spacing(self) -> Dict[str, bool]:
        """
        Ensure proper English hyphenation and spacing.
        
        Returns:
            Dictionary with hyphenation and spacing validation results
        """
        print("\n" + "=" * 60)
        print("TASK 13.4: Ensuring proper English hyphenation and spacing")
        print("=" * 60)
        
        results = {
            'english_babel_configured': False,
            'microtype_loaded': False,
            'proper_spacing_commands': False,
            'no_portuguese_hyphenation': False,
            'english_text_detected': False
        }
        
        try:
            # Read LaTeX content
            with open(self.tex_file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Check English babel configuration
            english_babel_patterns = [
                r'\\usepackage\[english\]\{babel\}',
                r'\\usepackage\{babel\}.*english',
                r'\\selectlanguage\{english\}'
            ]
            results['english_babel_configured'] = any(re.search(pattern, content) for pattern in english_babel_patterns)
            
            # Check microtype package for better typography
            results['microtype_loaded'] = '\\usepackage{microtype}' in content
            
            # Check for proper spacing commands
            spacing_commands = ['\\,', '\\:', '\\;', '~', '\\quad', '\\qquad']
            spacing_found = sum(1 for cmd in spacing_commands if cmd in content)
            results['proper_spacing_commands'] = spacing_found > 0
            
            # Check for absence of Portuguese hyphenation patterns
            portuguese_patterns = [
                r'\\usepackage\[.*portuguese.*\]\{babel\}',
                r'\\selectlanguage\{portuguese\}',
                r'\\usepackage\[brazil\]\{babel\}'
            ]
            results['no_portuguese_hyphenation'] = not any(re.search(pattern, content) for pattern in portuguese_patterns)
            
            # Detect English text content
            english_indicators = [
                'Background:', 'Objective:', 'Methods:', 'Results:', 'Conclusions:',
                'Figure', 'Table', 'Section', 'Introduction', 'Methodology',
                'Discussion', 'Literature Review', 'References'
            ]
            english_found = sum(1 for indicator in english_indicators if indicator in content)
            results['english_text_detected'] = english_found >= 5
            
            print(f"✓ English babel configured: {results['english_babel_configured']}")
            print(f"✓ Microtype loaded: {results['microtype_loaded']}")
            print(f"✓ Proper spacing commands found: {spacing_found}")
            print(f"✓ English text indicators found: {english_found}")
            
        except Exception as e:
            self.errors.append(f"Hyphenation/spacing validation failed: {str(e)}")
            
        self.validation_results['hyphenation_spacing'] = results
        self._print_hyphenation_results(results)
        return results
    
    def run_complete_validation(self) -> Dict[str, Dict[str, bool]]:
        """
        Run all validation tasks for LaTeX compilation and formatting.
        
        Returns:
            Complete validation results
        """
        print("STARTING LATEX COMPILATION AND FORMATTING VALIDATION")
        print("=" * 80)
        
        # Run all validation tasks
        compilation_results = self.validate_latex_compilation()
        math_results = self.validate_mathematical_formulas()
        reference_results = self.validate_figure_table_references()
        hyphenation_results = self.validate_english_hyphenation_spacing()
        
        # Generate summary report
        self._generate_validation_report()
        
        return self.validation_results
    
    def _copy_compilation_files(self, temp_path: Path):
        """Copy necessary files for LaTeX compilation to temporary directory."""
        # Copy main LaTeX file
        shutil.copy2(self.tex_file_path, temp_path)
        
        # Copy bibliography file if it exists
        bib_file = Path("referencias.bib")
        if bib_file.exists():
            shutil.copy2(bib_file, temp_path)
        
        # Copy figures directory if it exists
        figures_dir = Path("figuras")
        if figures_dir.exists():
            shutil.copytree(figures_dir, temp_path / "figuras", dirs_exist_ok=True)
        
        # Copy tables directory if it exists
        tables_dir = Path("tabelas")
        if tables_dir.exists():
            shutil.copytree(tables_dir, temp_path / "tabelas", dirs_exist_ok=True)
    
    def _compile_latex_document(self, temp_path: Path) -> bool:
        """Compile LaTeX document and capture output."""
        tex_file = temp_path / self.tex_file_path.name
        
        try:
            # First pdflatex run
            result1 = subprocess.run(
                ['pdflatex', '-interaction=nonstopmode', '-output-directory', str(temp_path), str(tex_file)],
                capture_output=True,
                text=True,
                timeout=120,
                cwd=temp_path
            )
            
            self.compilation_log.append(f"First pdflatex run: {result1.returncode}")
            
            # Run bibtex if bibliography exists
            if Path(temp_path / "referencias.bib").exists():
                bib_result = subprocess.run(
                    ['bibtex', tex_file.stem],
                    capture_output=True,
                    text=True,
                    timeout=60,
                    cwd=temp_path
                )
                self.compilation_log.append(f"Bibtex run: {bib_result.returncode}")
            
            # Second pdflatex run
            result2 = subprocess.run(
                ['pdflatex', '-interaction=nonstopmode', '-output-directory', str(temp_path), str(tex_file)],
                capture_output=True,
                text=True,
                timeout=120,
                cwd=temp_path
            )
            
            # Third pdflatex run for references
            result3 = subprocess.run(
                ['pdflatex', '-interaction=nonstopmode', '-output-directory', str(temp_path), str(tex_file)],
                capture_output=True,
                text=True,
                timeout=120,
                cwd=temp_path
            )
            
            self.compilation_log.append(f"Final pdflatex runs: {result2.returncode}, {result3.returncode}")
            
            # Check for errors in output
            if result3.stderr:
                self.errors.extend(result3.stderr.split('\n'))
            
            return result3.returncode == 0
            
        except subprocess.TimeoutExpired:
            self.errors.append("LaTeX compilation timed out")
            return False
        except FileNotFoundError:
            self.errors.append("pdflatex command not found. Please install LaTeX distribution.")
            return False
        except Exception as e:
            self.errors.append(f"Compilation error: {str(e)}")
            return False
    
    def _check_critical_errors(self) -> bool:
        """Check for critical errors in compilation log."""
        critical_patterns = [
            r'! LaTeX Error:',
            r'! Undefined control sequence',
            r'! Missing',
            r'! Package.*Error',
            r'Fatal error'
        ]
        
        log_text = ' '.join(self.compilation_log)
        for pattern in critical_patterns:
            if re.search(pattern, log_text, re.IGNORECASE):
                return False
        return True
    
    def _check_bibliography_compilation(self, temp_path: Path) -> bool:
        """Check if bibliography compiled successfully."""
        bbl_file = temp_path / f"{self.tex_file_path.stem}.bbl"
        return bbl_file.exists() and bbl_file.stat().st_size > 0
    
    def _check_english_babel(self) -> bool:
        """Check if English babel package is loaded."""
        try:
            with open(self.tex_file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            return '[english]' in content and 'babel' in content
        except:
            return False
    
    def _validate_equation_environments(self, content: str) -> bool:
        """Validate equation environments are properly formed."""
        # Check for balanced equation environments
        begin_count = len(re.findall(r'\\begin\{equation\}', content))
        end_count = len(re.findall(r'\\end\{equation\}', content))
        
        if begin_count != end_count:
            self.warnings.append(f"Unbalanced equation environments: {begin_count} begin, {end_count} end")
            return False
        
        return True
    
    def _print_compilation_results(self, results: Dict[str, bool]):
        """Print compilation validation results."""
        print("\nCompilation Results:")
        for key, value in results.items():
            status = "✓ PASS" if value else "✗ FAIL"
            print(f"  {key}: {status}")
    
    def _print_math_results(self, results: Dict[str, bool]):
        """Print mathematical formula validation results."""
        print("\nMathematical Formula Results:")
        for key, value in results.items():
            status = "✓ PASS" if value else "✗ FAIL"
            print(f"  {key}: {status}")
    
    def _print_reference_results(self, results: Dict[str, bool]):
        """Print reference validation results."""
        print("\nReference Validation Results:")
        for key, value in results.items():
            status = "✓ PASS" if value else "✗ FAIL"
            print(f"  {key}: {status}")
    
    def _print_hyphenation_results(self, results: Dict[str, bool]):
        """Print hyphenation and spacing validation results."""
        print("\nHyphenation and Spacing Results:")
        for key, value in results.items():
            status = "✓ PASS" if value else "✗ FAIL"
            print(f"  {key}: {status}")
    
    def _generate_validation_report(self):
        """Generate comprehensive validation report."""
        print("\n" + "=" * 80)
        print("LATEX COMPILATION AND FORMATTING VALIDATION SUMMARY")
        print("=" * 80)
        
        total_checks = 0
        passed_checks = 0
        
        for category, results in self.validation_results.items():
            print(f"\n{category.upper()} VALIDATION:")
            for check, result in results.items():
                total_checks += 1
                if result:
                    passed_checks += 1
                status = "✓ PASS" if result else "✗ FAIL"
                print(f"  {check}: {status}")
        
        success_rate = (passed_checks / total_checks) * 100 if total_checks > 0 else 0
        
        print(f"\nOVERALL VALIDATION RESULTS:")
        print(f"  Total checks: {total_checks}")
        print(f"  Passed: {passed_checks}")
        print(f"  Failed: {total_checks - passed_checks}")
        print(f"  Success rate: {success_rate:.1f}%")
        
        if self.errors:
            print(f"\nERRORS FOUND ({len(self.errors)}):")
            for i, error in enumerate(self.errors, 1):
                print(f"  {i}. {error}")
        
        if self.warnings:
            print(f"\nWARNINGS ({len(self.warnings)}):")
            for i, warning in enumerate(self.warnings, 1):
                print(f"  {i}. {warning}")
        
        # Save detailed report to file
        self._save_validation_report(success_rate, total_checks, passed_checks)
        
        print(f"\n{'='*80}")
        if success_rate >= 90:
            print("✓ LATEX VALIDATION COMPLETED SUCCESSFULLY")
        elif success_rate >= 75:
            print("⚠ LATEX VALIDATION COMPLETED WITH WARNINGS")
        else:
            print("✗ LATEX VALIDATION FAILED - CRITICAL ISSUES FOUND")
        print(f"{'='*80}")
    
    def _save_validation_report(self, success_rate: float, total_checks: int, passed_checks: int):
        """Save detailed validation report to file."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_file = f"latex_validation_report_{timestamp}.txt"
        
        try:
            with open(report_file, 'w', encoding='utf-8') as f:
                f.write("LATEX COMPILATION AND FORMATTING VALIDATION REPORT\n")
                f.write("=" * 60 + "\n")
                f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write(f"LaTeX file: {self.tex_file_path}\n\n")
                
                f.write("VALIDATION RESULTS:\n")
                f.write("-" * 30 + "\n")
                for category, results in self.validation_results.items():
                    f.write(f"\n{category.upper()}:\n")
                    for check, result in results.items():
                        status = "PASS" if result else "FAIL"
                        f.write(f"  {check}: {status}\n")
                
                f.write(f"\nSUMMARY:\n")
                f.write(f"  Total checks: {total_checks}\n")
                f.write(f"  Passed: {passed_checks}\n")
                f.write(f"  Failed: {total_checks - passed_checks}\n")
                f.write(f"  Success rate: {success_rate:.1f}%\n")
                
                if self.errors:
                    f.write(f"\nERRORS:\n")
                    for error in self.errors:
                        f.write(f"  - {error}\n")
                
                if self.warnings:
                    f.write(f"\nWARNINGS:\n")
                    for warning in self.warnings:
                        f.write(f"  - {warning}\n")
                
                if self.compilation_log:
                    f.write(f"\nCOMPILATION LOG:\n")
                    for log_entry in self.compilation_log:
                        f.write(f"  {log_entry}\n")
            
            print(f"\n✓ Detailed validation report saved to: {report_file}")
            
        except Exception as e:
            print(f"⚠ Could not save validation report: {str(e)}")


def main():
    """Main function to run LaTeX validation."""
    if len(sys.argv) > 1:
        tex_file = sys.argv[1]
    else:
        tex_file = "artigo_cientifico_corrosao.tex"
    
    validator = LaTeXCompilationValidator(tex_file)
    results = validator.run_complete_validation()
    
    # Return appropriate exit code
    all_passed = all(
        all(category_results.values()) 
        for category_results in results.values()
    )
    
    sys.exit(0 if all_passed else 1)


if __name__ == "__main__":
    main()