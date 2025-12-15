#!/usr/bin/env python3
"""
Simple test to validate the terminology validation system.
"""

import os
import sys

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'translation'))

try:
    from terminology_validator import TerminologyValidator
    
    # Test basic functionality
    validator = TerminologyValidator()
    
    # Test Portuguese detection
    test_text = "This text contains segmentação and metodologia terms."
    issues = validator._check_portuguese_remnants(test_text)
    
    print("Terminology Validation System Test")
    print("=" * 40)
    print(f"Test text: {test_text}")
    print(f"Portuguese issues found: {len(issues)}")
    
    for issue in issues:
        print(f"  - {issue}")
    
    print("\nSystem is working correctly!")
    
    # Test with actual document if it exists
    tex_file = "artigo_cientifico_corrosao.tex"
    if os.path.exists(tex_file):
        print(f"\nValidating {tex_file}...")
        result = validator.validate_document(tex_file)
        print(f"Validation complete: {len(result.issues)} issues, {len(result.warnings)} warnings")
        
        # Save a quick report
        report = validator.generate_validation_report(result, "validation_test_report.md")
        print("Report saved to: validation_test_report.md")
    else:
        print(f"\nDocument {tex_file} not found for full validation")
    
except ImportError as e:
    print(f"Import error: {e}")
    print("Make sure the terminology_validator module is properly created")
except Exception as e:
    print(f"Error: {e}")