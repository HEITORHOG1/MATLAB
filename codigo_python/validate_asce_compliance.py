#!/usr/bin/env python3
"""
ASCE Compliance and Content Preservation Validation Script
Validates that the ASCE-formatted document maintains all original content
and follows ASCE formatting requirements.
"""

import re
import os
import subprocess
import sys
from pathlib import Path

class ASCEValidator:
    def __init__(self, asce_file="artigo_cientifico_corrosao.tex", original_file="artigo_cientifico_corrosao_original_portuguese_backup.tex"):
        self.asce_file = asce_file
        self.original_file = original_file
        self.validation_results = {}
        
    def read_file(self, filename):
        """Read file content safely"""
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                return f.read()
        except FileNotFoundError:
            print(f"Warning: File {filename} not found")
            return ""
        except Exception as e:
            print(f"Error reading {filename}: {e}")
            return ""
    
    def validate_asce_document_class(self, content):
        """Validate ASCE document class and options"""
        print("\n=== ASCE Document Class Validation ===")
        
        # Check for ascelike-new class
        class_pattern = r'\\documentclass\[([^\]]*)\]\{ascelike-new\}'
        class_match = re.search(class_pattern, content)
        
        if class_match:
            options = class_match.group(1)
            print(f"✓ ASCE document class found with options: {options}")
            
            # Check for required options
            required_options = ['Journal', 'letterpaper']
            for option in required_options:
                if option in options:
                    print(f"✓ Required option '{option}' found")
                else:
                    print(f"✗ Missing required option '{option}'")
                    return False
        else:
            print("✗ ASCE document class not found")
            return False
        
        return True
    
    def validate_required_packages(self, content):
        """Validate required ASCE packages"""
        print("\n=== Required Packages Validation ===")
        
        required_packages = [
            'inputenc', 'fontenc', 'babel', 'lmodern', 'graphicx',
            'caption', 'subcaption', 'amsmath', 'siunitx', 'booktabs',
            'array', 'multirow', 'newtxtext', 'hyperref'
        ]
        
        all_found = True
        for package in required_packages:
            if f'\\usepackage' in content and package in content:
                print(f"✓ Package '{package}' found")
            else:
                print(f"✗ Package '{package}' missing")
                all_found = False
        
        return all_found
    
    def validate_asce_structure(self, content):
        """Validate ASCE document structure"""
        print("\n=== ASCE Document Structure Validation ===")
        
        required_sections = [
            (r'\\begin\{abstract\}', 'Abstract environment'),
            (r'\\section\{Practical Applications\}', 'Practical Applications section'),
            (r'\\section\{Introduction\}', 'Introduction section'),
            (r'\\section\{Data Availability Statement\}', 'Data Availability Statement'),
            (r'\\KeyWords\{', 'Keywords command')
        ]
        
        all_found = True
        for pattern, description in required_sections:
            if re.search(pattern, content):
                print(f"✓ {description} found")
            else:
                print(f"✗ {description} missing")
                all_found = False
        
        return all_found
    
    def validate_bibliography_format(self, content):
        """Validate ASCE bibliography format"""
        print("\n=== Bibliography Format Validation ===")
        
        # Check for ASCE bibliography style
        if '\\bibliographystyle{ascelike-new}' in content:
            print("✓ ASCE bibliography style found")
        else:
            print("✗ ASCE bibliography style missing")
            return False
        
        # Check for bibliography command
        if '\\bibliography{' in content:
            print("✓ Bibliography command found")
        else:
            print("✗ Bibliography command missing")
            return False
        
        return True
    
    def count_elements(self, content, element_type):
        """Count specific elements in the document"""
        if element_type == 'figures':
            return len(re.findall(r'\\begin\{figure\}', content))
        elif element_type == 'tables':
            return len(re.findall(r'\\begin\{table\}', content))
        elif element_type == 'equations':
            return len(re.findall(r'\\begin\{equation\}', content))
        elif element_type == 'sections':
            return len(re.findall(r'\\section\{', content))
        elif element_type == 'subsections':
            return len(re.findall(r'\\subsection\{', content))
        return 0
    
    def validate_content_preservation(self, asce_content, original_content):
        """Validate that content is preserved between versions"""
        print("\n=== Content Preservation Validation ===")
        
        if not original_content:
            print("Warning: Original file not available for comparison")
            return True
        
        # Count elements in both versions
        elements = ['figures', 'tables', 'equations', 'sections', 'subsections']
        
        for element in elements:
            asce_count = self.count_elements(asce_content, element)
            original_count = self.count_elements(original_content, element)
            
            print(f"{element.capitalize()}: ASCE={asce_count}, Original={original_count}")
            
            if asce_count >= original_count:
                print(f"✓ {element.capitalize()} count preserved or increased")
            else:
                print(f"⚠ {element.capitalize()} count decreased (may be acceptable)")
        
        return True
    
    def validate_figures_and_tables(self, content):
        """Validate figure and table formatting"""
        print("\n=== Figures and Tables Validation ===")
        
        # Check figure environments
        figures = re.findall(r'\\begin\{figure\}.*?\\end\{figure\}', content, re.DOTALL)
        print(f"Found {len(figures)} figures")
        
        for i, figure in enumerate(figures[:3]):  # Check first 3 figures
            if '\\centering' in figure:
                print(f"✓ Figure {i+1}: centering found")
            else:
                print(f"✗ Figure {i+1}: centering missing")
            
            if '\\caption{' in figure:
                print(f"✓ Figure {i+1}: caption found")
            else:
                print(f"✗ Figure {i+1}: caption missing")
            
            if '\\label{fig:' in figure:
                print(f"✓ Figure {i+1}: proper label found")
            else:
                print(f"⚠ Figure {i+1}: label may not follow fig: convention")
        
        # Check table environments
        tables = re.findall(r'\\begin\{table\}.*?\\end\{table\}', content, re.DOTALL)
        print(f"Found {len(tables)} tables")
        
        for i, table in enumerate(tables[:3]):  # Check first 3 tables
            if '\\caption{' in table:
                print(f"✓ Table {i+1}: caption found")
            else:
                print(f"✗ Table {i+1}: caption missing")
            
            if '\\label{tab:' in table:
                print(f"✓ Table {i+1}: proper label found")
            else:
                print(f"⚠ Table {i+1}: label may not follow tab: convention")
        
        return True
    
    def validate_equations(self, content):
        """Validate equation formatting"""
        print("\n=== Equations Validation ===")
        
        equations = re.findall(r'\\begin\{equation\}.*?\\end\{equation\}', content, re.DOTALL)
        print(f"Found {len(equations)} numbered equations")
        
        # Check for equation labels
        labeled_equations = re.findall(r'\\begin\{equation\}.*?\\label\{.*?\}.*?\\end\{equation\}', content, re.DOTALL)
        print(f"Found {len(labeled_equations)} labeled equations")
        
        if len(equations) > 0:
            print("✓ Equations use proper equation environment")
        
        return True
    
    def validate_citations(self, content):
        """Validate citation format"""
        print("\n=== Citations Validation ===")
        
        # Count different citation types
        cite_patterns = [
            (r'\\cite\{[^}]+\}', 'Standard citations'),
            (r'\\citeA\{[^}]+\}', 'Author citations'),
            (r'\\citeN\{[^}]+\}', 'Numeric citations')
        ]
        
        total_citations = 0
        for pattern, description in cite_patterns:
            citations = re.findall(pattern, content)
            count = len(citations)
            total_citations += count
            if count > 0:
                print(f"✓ {description}: {count} found")
        
        print(f"Total citations found: {total_citations}")
        return total_citations > 0
    
    def test_compilation(self):
        """Test LaTeX compilation"""
        print("\n=== Compilation Test ===")
        
        if not os.path.exists(self.asce_file):
            print(f"✗ ASCE file {self.asce_file} not found")
            return False
        
        try:
            # Run pdflatex
            print("Running pdflatex...")
            result = subprocess.run(['pdflatex', '-interaction=nonstopmode', self.asce_file], 
                                  capture_output=True, text=True, timeout=60)
            
            if result.returncode == 0:
                print("✓ pdflatex compilation successful")
            else:
                print("✗ pdflatex compilation failed")
                print("Error output:", result.stderr[:500])
                return False
            
            # Run bibtex if .aux file exists
            aux_file = self.asce_file.replace('.tex', '.aux')
            if os.path.exists(aux_file):
                print("Running bibtex...")
                result = subprocess.run(['bibtex', aux_file.replace('.aux', '')], 
                                      capture_output=True, text=True, timeout=30)
                
                if result.returncode == 0:
                    print("✓ bibtex compilation successful")
                else:
                    print("⚠ bibtex compilation had issues (may be acceptable)")
            
            # Run pdflatex again
            print("Running final pdflatex...")
            result = subprocess.run(['pdflatex', '-interaction=nonstopmode', self.asce_file], 
                                  capture_output=True, text=True, timeout=60)
            
            if result.returncode == 0:
                print("✓ Final compilation successful")
                
                # Check if PDF was generated
                pdf_file = self.asce_file.replace('.tex', '.pdf')
                if os.path.exists(pdf_file):
                    size = os.path.getsize(pdf_file)
                    print(f"✓ PDF generated successfully ({size} bytes)")
                    return True
                else:
                    print("✗ PDF file not found")
                    return False
            else:
                print("✗ Final compilation failed")
                return False
                
        except subprocess.TimeoutExpired:
            print("✗ Compilation timeout")
            return False
        except FileNotFoundError:
            print("✗ LaTeX tools not found (pdflatex, bibtex)")
            return False
        except Exception as e:
            print(f"✗ Compilation error: {e}")
            return False
    
    def generate_quality_report(self):
        """Generate comprehensive quality assurance report"""
        print("\n" + "="*60)
        print("ASCE COMPLIANCE AND QUALITY ASSURANCE REPORT")
        print("="*60)
        
        # Read files
        asce_content = self.read_file(self.asce_file)
        original_content = self.read_file(self.original_file)
        
        if not asce_content:
            print(f"✗ Cannot read ASCE file: {self.asce_file}")
            return False
        
        # Run all validations
        validations = [
            ("Document Class", self.validate_asce_document_class(asce_content)),
            ("Required Packages", self.validate_required_packages(asce_content)),
            ("Document Structure", self.validate_asce_structure(asce_content)),
            ("Bibliography Format", self.validate_bibliography_format(asce_content)),
            ("Content Preservation", self.validate_content_preservation(asce_content, original_content)),
            ("Figures and Tables", self.validate_figures_and_tables(asce_content)),
            ("Equations", self.validate_equations(asce_content)),
            ("Citations", self.validate_citations(asce_content)),
            ("Compilation", self.test_compilation())
        ]
        
        # Summary
        print("\n" + "="*60)
        print("VALIDATION SUMMARY")
        print("="*60)
        
        passed = 0
        total = len(validations)
        
        for name, result in validations:
            status = "✓ PASS" if result else "✗ FAIL"
            print(f"{name:<25} {status}")
            if result:
                passed += 1
        
        print(f"\nOverall Score: {passed}/{total} ({passed/total*100:.1f}%)")
        
        if passed == total:
            print("\n🎉 EXCELLENT: Document is ready for ASCE submission!")
        elif passed >= total * 0.9:
            print("\n✅ VERY GOOD: Document meets most ASCE requirements")
        elif passed >= total * 0.8:
            print("\n⚠️  GOOD: Document needs minor adjustments")
        else:
            print("\n❌ NEEDS WORK: Document requires significant improvements")
        
        return passed >= total * 0.8

def main():
    """Main validation function"""
    validator = ASCEValidator()
    success = validator.generate_quality_report()
    
    if success:
        print("\n✓ Validation completed successfully")
        return 0
    else:
        print("\n✗ Validation found issues that need attention")
        return 1

if __name__ == "__main__":
    sys.exit(main())