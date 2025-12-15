#!/usr/bin/env python3
"""
Final Validation Script for ASCE Page Reduction - Task 9
Validates key findings, logical coherence, and technical accuracy
"""

import re
import subprocess
import sys
from pathlib import Path
from datetime import datetime

class ValidationReport:
    def __init__(self):
        self.sections = []
        self.errors = []
        self.warnings = []
        self.passed_checks = []
        
    def add_section(self, title):
        self.sections.append({"title": title, "checks": []})
    
    def add_check(self, description, status, details=""):
        if self.sections:
            self.sections[-1]["checks"].append({
                "description": description,
                "status": status,
                "details": details
            })
            if status == "PASS":
                self.passed_checks.append(description)
            elif status == "FAIL":
                self.errors.append(f"{description}: {details}")
            elif status == "WARN":
                self.warnings.append(f"{description}: {details}")
    
    def generate_report(self):
        report = []
        report.append("=" * 80)
        report.append("FINAL VALIDATION REPORT - TASK 9")
        report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        report.append("=" * 80)
        report.append("")
        
        for section in self.sections:
            report.append(f"\n{'=' * 80}")
            report.append(f"{section['title']}")
            report.append("=" * 80)
            
            for check in section["checks"]:
                status_symbol = "✓" if check["status"] == "PASS" else "✗" if check["status"] == "FAIL" else "⚠"
                report.append(f"\n{status_symbol} [{check['status']}] {check['description']}")
                if check["details"]:
                    report.append(f"  Details: {check['details']}")
        
        # Summary
        report.append(f"\n\n{'=' * 80}")
        report.append("SUMMARY")
        report.append("=" * 80)
        report.append(f"Total Checks: {sum(len(s['checks']) for s in self.sections)}")
        report.append(f"Passed: {len(self.passed_checks)}")
        report.append(f"Warnings: {len(self.warnings)}")
        report.append(f"Errors: {len(self.errors)}")
        
        if self.errors:
            report.append(f"\n\nCRITICAL ERRORS ({len(self.errors)}):")
            for error in self.errors:
                report.append(f"  - {error}")
        
        if self.warnings:
            report.append(f"\n\nWARNINGS ({len(self.warnings)}):")
            for warning in self.warnings:
                report.append(f"  - {warning}")
        
        report.append("\n" + "=" * 80)
        
        return "\n".join(report)

def read_tex_file(filepath):
    """Read LaTeX file content"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return None


def validate_key_findings(content, report):
    """Task 9.1: Verify all key findings preserved"""
    report.add_section("9.1 KEY FINDINGS VALIDATION")
    
    # Check quantitative results (handle LaTeX \% escaping)
    key_results = {
        "ResNet50 accuracy": r"94\.2\\?%",
        "EfficientNet-B0 accuracy": r"91\.9\\?%",
        "Custom CNN accuracy": r"85\.5\\?%",
        "ResNet50 macro F1": r"0\.932",
        "Speedup range": r"18--46",
        "ResNet50 inference time": r"45\.3.*ms",
        "Class 0 images": r"245",
        "Class 1 images": r"112",
        "Class 2 images": r"57",
        "Total images": r"414"
    }
    
    for result_name, pattern in key_results.items():
        if re.search(pattern, content):
            report.add_check(f"Quantitative result present: {result_name}", "PASS")
        else:
            report.add_check(f"Quantitative result present: {result_name}", "FAIL", 
                           f"Pattern '{pattern}' not found")
    
    # Check methodology completeness
    methodology_elements = [
        (r"\\subsection\{Dataset Preparation", "Dataset preparation section"),
        (r"\\subsection\{Model Architectures", "Model architectures section"),
        (r"\\subsection\{Training Configuration", "Training configuration section"),
        (r"\\subsection\{Evaluation Metrics", "Evaluation metrics section"),
        (r"ResNet50.*\\cite\{he2016deep\}", "ResNet50 methodology"),
        (r"EfficientNet.*\\cite\{tan2019efficientnet\}", "EfficientNet methodology"),
        (r"Adam optimizer.*\\cite\{kingma2014adam\}", "Optimizer specification"),
        (r"Data augmentation", "Data augmentation description")
    ]
    
    for pattern, description in methodology_elements:
        if re.search(pattern, content, re.IGNORECASE):
            report.add_check(f"Methodology element: {description}", "PASS")
        else:
            report.add_check(f"Methodology element: {description}", "FAIL",
                           f"Not found in document")
    
    # Check conclusions intact
    conclusion_elements = [
        (r"94\.2\%.*accuracy", "Best accuracy in conclusions"),
        (r"18--46.*faster", "Speedup in conclusions"),
        (r"complementary", "Complementary relationship mentioned"),
        (r"hierarchical.*classification", "Hierarchical classification mentioned"),
        (r"transfer learning", "Transfer learning conclusions")
    ]
    
    conclusions_section = re.search(r"\\section\{Conclusions\}.*?(?=\\section|\\bibliographystyle|$)", 
                                   content, re.DOTALL | re.IGNORECASE)
    if conclusions_section:
        conclusions_text = conclusions_section.group(0)
        for pattern, description in conclusion_elements:
            if re.search(pattern, conclusions_text, re.IGNORECASE):
                report.add_check(f"Conclusion element: {description}", "PASS")
            else:
                report.add_check(f"Conclusion element: {description}", "WARN",
                               "Not explicitly stated in conclusions")
    else:
        report.add_check("Conclusions section exists", "FAIL", "Section not found")

def validate_logical_coherence(content, report):
    """Task 9.2: Verify logical coherence"""
    report.add_section("9.2 LOGICAL COHERENCE VALIDATION")
    
    # Check section order
    expected_sections = [
        (r"\\begin\{abstract\}", "Abstract"),
        (r"\\section\{Introduction\}", "Introduction"),
        (r"\\section\{Methodology\}", "Methodology"),
        (r"\\section\{Results\}", "Results"),
        (r"\\section\{Discussion\}", "Discussion"),
        (r"\\section\{Conclusions\}", "Conclusions")
    ]
    
    positions = []
    for pattern, name in expected_sections:
        match = re.search(pattern, content, re.IGNORECASE)
        if match:
            positions.append((match.start(), name))
            report.add_check(f"Section exists: {name}", "PASS")
        else:
            report.add_check(f"Section exists: {name}", "FAIL", "Section not found")
    
    # Verify sections are in correct order
    if len(positions) > 1:
        sorted_positions = sorted(positions, key=lambda x: x[0])
        if positions == sorted_positions:
            report.add_check("Section order is correct", "PASS")
        else:
            report.add_check("Section order is correct", "FAIL",
                           f"Expected order not maintained")
    
    # Check for orphaned references
    # Find all \ref{} and \cite{} commands
    refs = re.findall(r"\\ref\{([^}]+)\}", content)
    cites = re.findall(r"\\cite\{([^}]+)\}", content)
    
    # Find all \label{} commands
    labels = re.findall(r"\\label\{([^}]+)\}", content)
    
    orphaned_refs = []
    for ref in set(refs):
        if ref not in labels:
            orphaned_refs.append(ref)
    
    if orphaned_refs:
        report.add_check("No orphaned \\ref commands", "WARN",
                       f"Found {len(orphaned_refs)} potentially orphaned refs: {', '.join(orphaned_refs[:5])}")
    else:
        report.add_check("No orphaned \\ref commands", "PASS")
    
    # Check narrative flow - look for transition words/phrases
    sections_to_check = [
        (r"\\section\{Methodology\}", r"\\section\{Results\}"),
        (r"\\section\{Results\}", r"\\section\{Discussion\}"),
        (r"\\section\{Discussion\}", r"\\section\{Conclusions\}")
    ]
    
    transition_patterns = [
        r"This section",
        r"The following",
        r"As shown",
        r"Based on",
        r"These results",
        r"In summary",
        r"Therefore"
    ]
    
    for start_pattern, end_pattern in sections_to_check:
        start_match = re.search(start_pattern, content, re.IGNORECASE)
        end_match = re.search(end_pattern, content, re.IGNORECASE)
        
        if start_match and end_match:
            section_text = content[start_match.start():end_match.start()]
            section_name = start_pattern.replace(r"\\section\{", "").replace(r"\}", "")
            
            # Check last paragraph for transitions
            last_para = section_text.strip().split('\n\n')[-1] if '\n\n' in section_text else section_text
            has_transition = any(re.search(pattern, last_para, re.IGNORECASE) 
                               for pattern in transition_patterns)
            
            if has_transition or len(last_para) > 200:
                report.add_check(f"Transition from {section_name}", "PASS")
            else:
                report.add_check(f"Transition from {section_name}", "WARN",
                               "No clear transition phrase found")


def validate_technical_accuracy(content, report):
    """Task 9.3: Verify technical accuracy"""
    report.add_section("9.3 TECHNICAL ACCURACY VALIDATION")
    
    # Check equations
    equations = re.findall(r"\\begin\{equation\}(.*?)\\end\{equation\}", content, re.DOTALL)
    report.add_check(f"Equations found: {len(equations)}", "PASS" if equations else "WARN",
                   f"Found {len(equations)} equation(s)")
    
    # Check for balanced math delimiters
    dollar_signs = content.count('$')
    if dollar_signs % 2 == 0:
        report.add_check("Math delimiters balanced", "PASS")
    else:
        report.add_check("Math delimiters balanced", "WARN",
                       f"Odd number of $ signs: {dollar_signs}")
    
    # Check statistics consistency
    stats_checks = [
        (r"414.*images", "Total dataset size"),
        (r"290.*training", "Training set size"),
        (r"62.*validation", "Validation set size"),
        (r"62.*test", "Test set size"),
        (r"70%.*15%.*15%", "Split percentages")
    ]
    
    for pattern, description in stats_checks:
        if re.search(pattern, content, re.IGNORECASE):
            report.add_check(f"Statistics consistent: {description}", "PASS")
        else:
            report.add_check(f"Statistics consistent: {description}", "WARN",
                           "Not found or inconsistent")
    
    # Check figure references
    figures = re.findall(r"\\begin\{figure\}.*?\\label\{([^}]+)\}.*?\\end\{figure\}", 
                        content, re.DOTALL)
    figure_refs = re.findall(r"Figure~\\ref\{([^}]+)\}", content)
    
    report.add_check(f"Figures defined: {len(figures)}", "PASS" if figures else "WARN")
    
    for fig_label in figures:
        if fig_label in figure_refs:
            report.add_check(f"Figure referenced: {fig_label}", "PASS")
        else:
            report.add_check(f"Figure referenced: {fig_label}", "WARN",
                           "Figure not referenced in text")
    
    # Check table references
    tables = re.findall(r"\\begin\{table\}.*?\\label\{([^}]+)\}.*?\\end\{table\}", 
                       content, re.DOTALL)
    table_refs = re.findall(r"Table~\\ref\{([^}]+)\}", content)
    
    report.add_check(f"Tables defined: {len(tables)}", "PASS" if tables else "WARN")
    
    for tab_label in tables:
        if tab_label in table_refs:
            report.add_check(f"Table referenced: {tab_label}", "PASS")
        else:
            report.add_check(f"Table referenced: {tab_label}", "WARN",
                           "Table not referenced in text")


def compile_latex(tex_file, report):
    """Task 9.4: Final compilation check"""
    report.add_section("9.4 COMPILATION CHECK")
    
    tex_path = Path(tex_file)
    if not tex_path.exists():
        report.add_check("LaTeX file exists", "FAIL", f"{tex_file} not found")
        return False
    
    report.add_check("LaTeX file exists", "PASS")
    
    # Try to compile
    try:
        print(f"Compiling {tex_file}...")
        result = subprocess.run(
            ['pdflatex', '-interaction=nonstopmode', tex_file],
            capture_output=True,
            text=True,
            timeout=60
        )
        
        if result.returncode == 0:
            report.add_check("LaTeX compilation successful", "PASS")
        else:
            # Check for errors in log
            log_file = tex_path.with_suffix('.log')
            if log_file.exists():
                with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
                    log_content = f.read()
                    errors = re.findall(r"! (.+)", log_content)
                    if errors:
                        report.add_check("LaTeX compilation successful", "FAIL",
                                       f"Errors: {'; '.join(errors[:3])}")
                    else:
                        report.add_check("LaTeX compilation successful", "WARN",
                                       "Non-zero return code but no errors found")
            else:
                report.add_check("LaTeX compilation successful", "FAIL",
                               f"Return code: {result.returncode}")
        
        # Run bibtex
        aux_file = tex_path.stem
        subprocess.run(['bibtex', aux_file], capture_output=True, timeout=30)
        
        # Second pass
        subprocess.run(['pdflatex', '-interaction=nonstopmode', tex_file],
                      capture_output=True, timeout=60)
        
        # Third pass for references
        result = subprocess.run(['pdflatex', '-interaction=nonstopmode', tex_file],
                              capture_output=True, text=True, timeout=60)
        
        if result.returncode == 0:
            report.add_check("Full compilation (3 passes + bibtex)", "PASS")
        else:
            report.add_check("Full compilation (3 passes + bibtex)", "WARN",
                           "Initial pass succeeded but full compilation had issues")
        
    except subprocess.TimeoutExpired:
        report.add_check("LaTeX compilation successful", "FAIL", "Compilation timeout")
        return False
    except FileNotFoundError:
        report.add_check("LaTeX compilation successful", "FAIL",
                       "pdflatex not found - cannot compile")
        return False
    except Exception as e:
        report.add_check("LaTeX compilation successful", "FAIL", str(e))
        return False
    
    # Check page count
    pdf_file = tex_path.with_suffix('.pdf')
    if pdf_file.exists():
        try:
            # Try to get page count from PDF
            result = subprocess.run(
                ['pdfinfo', str(pdf_file)],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            if result.returncode == 0:
                page_match = re.search(r"Pages:\s+(\d+)", result.stdout)
                if page_match:
                    page_count = int(page_match.group(1))
                    report.add_check(f"Page count: {page_count}", 
                                   "PASS" if page_count <= 30 else "FAIL",
                                   f"Target: ≤30 pages, Actual: {page_count} pages")
                    return page_count
            
            # Fallback: check log file
            log_file = tex_path.with_suffix('.log')
            if log_file.exists():
                with open(log_file, 'r', encoding='utf-8', errors='ignore') as f:
                    log_content = f.read()
                    # Look for page count in log
                    page_match = re.search(r"Output written.*\((\d+) pages", log_content)
                    if page_match:
                        page_count = int(page_match.group(1))
                        report.add_check(f"Page count: {page_count}",
                                       "PASS" if page_count <= 30 else "FAIL",
                                       f"Target: ≤30 pages, Actual: {page_count} pages")
                        return page_count
            
            report.add_check("Page count verification", "WARN",
                           "Could not determine page count")
            
        except Exception as e:
            report.add_check("Page count verification", "WARN", str(e))
    else:
        report.add_check("PDF generated", "FAIL", "PDF file not found")
    
    return None

def generate_change_report(content, report):
    """Task 9.5: Generate change report"""
    report.add_section("9.5 CHANGE REPORT GENERATION")
    
    # Check for backup file
    backup_file = Path("artigo_classificacao_corrosao_original_backup.tex")
    if backup_file.exists():
        report.add_check("Original backup exists", "PASS")
    else:
        report.add_check("Original backup exists", "WARN",
                       "No backup file found - cannot generate detailed change report")
    
    # Document current state
    word_count = len(re.findall(r'\w+', content))
    report.add_check(f"Current word count: ~{word_count}", "PASS")
    
    sections = len(re.findall(r"\\section\{", content))
    subsections = len(re.findall(r"\\subsection\{", content))
    report.add_check(f"Structure: {sections} sections, {subsections} subsections", "PASS")
    
    figures = len(re.findall(r"\\begin\{figure\}", content))
    tables = len(re.findall(r"\\begin\{table\}", content))
    report.add_check(f"Figures: {figures}, Tables: {tables}", "PASS")
    
    return True


def main():
    """Main validation function"""
    print("=" * 80)
    print("FINAL VALIDATION - TASK 9: Quality Assurance")
    print("=" * 80)
    print()
    
    tex_file = "artigo_classificacao_corrosao.tex"
    
    # Read the LaTeX file
    print(f"Reading {tex_file}...")
    content = read_tex_file(tex_file)
    
    if content is None:
        print(f"ERROR: Could not read {tex_file}")
        sys.exit(1)
    
    # Create validation report
    report = ValidationReport()
    
    # Run all validation checks
    print("\n9.1 Validating key findings...")
    validate_key_findings(content, report)
    
    print("9.2 Validating logical coherence...")
    validate_logical_coherence(content, report)
    
    print("9.3 Validating technical accuracy...")
    validate_technical_accuracy(content, report)
    
    print("9.4 Compiling LaTeX document...")
    page_count = compile_latex(tex_file, report)
    
    print("9.5 Generating change report...")
    generate_change_report(content, report)
    
    # Generate and save report
    print("\nGenerating validation report...")
    report_text = report.generate_report()
    
    # Save to file
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    report_file = f"final_validation_report_task9_{timestamp}.txt"
    
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write(report_text)
    
    print(f"\nValidation report saved to: {report_file}")
    print("\n" + "=" * 80)
    print("VALIDATION COMPLETE")
    print("=" * 80)
    
    # Print summary
    print(f"\nTotal Checks: {sum(len(s['checks']) for s in report.sections)}")
    print(f"Passed: {len(report.passed_checks)}")
    print(f"Warnings: {len(report.warnings)}")
    print(f"Errors: {len(report.errors)}")
    
    if page_count:
        print(f"\nFinal Page Count: {page_count} pages")
        if page_count <= 30:
            print("✓ Page count meets ASCE requirement (≤30 pages)")
        else:
            print(f"✗ Page count exceeds ASCE requirement by {page_count - 30} pages")
    
    # Print report to console
    print("\n" + report_text)
    
    # Return exit code
    if report.errors:
        sys.exit(1)
    else:
        sys.exit(0)

if __name__ == "__main__":
    main()
