#!/usr/bin/env python3
"""
Main script to run terminology validation on the scientific article.
Demonstrates the complete validation system functionality.
"""

import os
import sys
from datetime import datetime

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'translation'))

def main():
    """Run comprehensive terminology validation."""
    
    print("English Translation Terminology Validation")
    print("=" * 50)
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Check if the main document exists
    tex_file = "artigo_cientifico_corrosao.tex"
    if not os.path.exists(tex_file):
        print(f"Error: Document '{tex_file}' not found")
        print("Please ensure the LaTeX file is in the current directory")
        return 1
    
    try:
        # Import validation components
        from terminology_validator import TerminologyValidator
        from validation_config import ValidationConfig, publication_config
        
        print("✓ Validation system loaded successfully")
        print(f"✓ Document found: {tex_file}")
        print()
        
        # Initialize validator with publication-ready configuration
        validator = TerminologyValidator(config=publication_config)
        
        print("Running comprehensive validation...")
        print("-" * 30)
        
        # Perform validation
        result = validator.validate_document(tex_file)
        
        # Display summary results
        status = "PASSED" if result.is_valid else "FAILED"
        status_symbol = "✓" if result.is_valid else "✗"
        
        print(f"\n{status_symbol} Validation Status: {status}")
        print(f"  Critical Issues: {len(result.issues)}")
        print(f"  Warnings: {len(result.warnings)}")
        
        # Display document statistics
        if result.statistics:
            print(f"\nDocument Statistics:")
            print(f"  Word Count: {result.statistics.get('word_count', 'N/A'):,}")
            print(f"  Sections: {result.statistics.get('section_count', 'N/A')}")
            print(f"  Figures: {result.statistics.get('figure_count', 'N/A')}")
            print(f"  Tables: {result.statistics.get('table_count', 'N/A')}")
            print(f"  Citations: {result.statistics.get('citation_count', 'N/A')}")
            print(f"  Deep Learning Terms: {result.statistics.get('deep_learning_terms', 'N/A')}")
            print(f"  Structural Engineering Terms: {result.statistics.get('structural_engineering_terms', 'N/A')}")
        
        # Display critical issues (first 10)
        if result.issues:
            print(f"\nCritical Issues (showing first 10 of {len(result.issues)}):")
            for i, issue in enumerate(result.issues[:10], 1):
                print(f"  {i:2d}. {issue}")
            if len(result.issues) > 10:
                print(f"      ... and {len(result.issues) - 10} more issues")
        
        # Display warnings (first 5)
        if result.warnings:
            print(f"\nWarnings (showing first 5 of {len(result.warnings)}):")
            for i, warning in enumerate(result.warnings[:5], 1):
                print(f"  {i:2d}. {warning}")
            if len(result.warnings) > 5:
                print(f"      ... and {len(result.warnings) - 5} more warnings")
        
        # Generate detailed report
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_filename = f"terminology_validation_report_{timestamp}.md"
        
        print(f"\nGenerating detailed report...")
        report = validator.generate_validation_report(result, report_filename)
        print(f"✓ Report saved to: {report_filename}")
        
        # Provide recommendations
        print(f"\nRecommendations:")
        if result.is_valid:
            print("  ✓ Document passes all terminology consistency checks")
            print("  ✓ Ready for publication review")
            print("  • Consider addressing warnings for optimal quality")
        else:
            print("  ✗ Critical issues must be resolved before publication")
            print("  • Review and fix all Portuguese text remnants")
            print("  • Ensure consistent technical terminology usage")
            print("  • Validate all translations with domain experts")
        
        print("  • Run LaTeX compilation test after any changes")
        print("  • Perform final peer review by subject matter experts")
        
        print(f"\nValidation complete. Exit code: {0 if result.is_valid else 1}")
        
        return 0 if result.is_valid else 1
        
    except ImportError as e:
        print(f"✗ Import error: {e}")
        print("Please ensure all validation modules are properly installed")
        return 1
    except Exception as e:
        print(f"✗ Validation error: {e}")
        print("Please check the document format and try again")
        return 1


if __name__ == '__main__':
    exit(main())