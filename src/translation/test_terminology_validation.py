#!/usr/bin/env python3
"""
Test script for terminology validation system.
Demonstrates the functionality and validates the current document.
"""

import os
import sys
from terminology_validator import TerminologyValidator, ValidationResult


def test_terminology_validation():
    """Test the terminology validation system with the current document."""
    
    # Initialize validator
    validator = TerminologyValidator()
    
    # Path to the main LaTeX document
    tex_file_path = "../../artigo_cientifico_corrosao.tex"
    
    if not os.path.exists(tex_file_path):
        print(f"Error: LaTeX file not found at {tex_file_path}")
        return False
    
    print("Testing Terminology Validation System")
    print("=" * 50)
    print(f"Validating document: {tex_file_path}")
    print()
    
    # Perform validation
    try:
        result = validator.validate_document(tex_file_path)
        
        # Display results
        print("VALIDATION RESULTS")
        print("-" * 20)
        print(f"Status: {'PASSED' if result.is_valid else 'FAILED'}")
        print(f"Critical Issues: {len(result.issues)}")
        print(f"Warnings: {len(result.warnings)}")
        print()
        
        # Show statistics
        if result.statistics:
            print("DOCUMENT STATISTICS")
            print("-" * 20)
            for key, value in result.statistics.items():
                formatted_key = key.replace('_', ' ').title()
                print(f"{formatted_key}: {value}")
            print()
        
        # Show first few issues
        if result.issues:
            print("CRITICAL ISSUES (First 10)")
            print("-" * 25)
            for i, issue in enumerate(result.issues[:10], 1):
                print(f"{i:2d}. {issue}")
            if len(result.issues) > 10:
                print(f"    ... and {len(result.issues) - 10} more issues")
            print()
        
        # Show first few warnings
        if result.warnings:
            print("WARNINGS (First 10)")
            print("-" * 15)
            for i, warning in enumerate(result.warnings[:10], 1):
                print(f"{i:2d}. {warning}")
            if len(result.warnings) > 10:
                print(f"    ... and {len(result.warnings) - 10} more warnings")
            print()
        
        # Generate full report
        report_path = "terminology_validation_report.md"
        report = validator.generate_validation_report(result, report_path)
        print(f"Full validation report saved to: {report_path}")
        
        return result.is_valid
        
    except Exception as e:
        print(f"Error during validation: {e}")
        return False


def test_section_validation():
    """Test section-specific validation."""
    
    validator = TerminologyValidator()
    
    print("\nTesting Section-Specific Validation")
    print("=" * 40)
    
    # Test with sample content containing issues
    test_sections = {
        "Introduction": """
        This study presents a comparative analysis between U-Net and Attention U-Net 
        architectures for automated corrosão detection in ASTM A572 Grau 50 vigas W 
        using deep learning-based segmentação semântica techniques.
        """,
        
        "Methodology": """
        The treinamento process was conducted using identical configurações for both 
        architectures. Data augmentation techniques were applied to improve model 
        performance and reduce overfitting.
        """,
        
        "Results": """
        The Attention U-Net architecture demonstrated superior performance with mean 
        IoU of 0.775 ± 0.089 compared to 0.693 ± 0.078 for classical U-Net (p < 0.001).
        """
    }
    
    for section_name, content in test_sections.items():
        print(f"\nValidating {section_name} section:")
        print("-" * 30)
        
        result = validator.validate_section(content, section_name)
        
        print(f"Status: {'PASSED' if result.is_valid else 'FAILED'}")
        print(f"Issues: {len(result.issues)}")
        print(f"Warnings: {len(result.warnings)}")
        
        if result.issues:
            print("Issues found:")
            for issue in result.issues:
                print(f"  - {issue}")
        
        if result.warnings:
            print("Warnings:")
            for warning in result.warnings:
                print(f"  - {warning}")


def test_portuguese_detection():
    """Test Portuguese text detection capabilities."""
    
    validator = TerminologyValidator()
    
    print("\nTesting Portuguese Text Detection")
    print("=" * 35)
    
    test_texts = [
        "This is proper English text with no issues.",
        "This text contains segmentação and detecção terms.",
        "The metodologia was based on aprendizado profundo.",
        "Results show that da análise estatística is important.",
        "The configurações were optimized para melhor performance."
    ]
    
    for i, text in enumerate(test_texts, 1):
        print(f"\nTest {i}: {text[:50]}...")
        issues = validator._check_portuguese_remnants(text)
        
        if issues:
            print(f"Portuguese detected: {len(issues)} issues")
            for issue in issues:
                print(f"  - {issue}")
        else:
            print("No Portuguese text detected")


def main():
    """Main test function."""
    
    print("Terminology Validation System Test Suite")
    print("=" * 50)
    
    # Test 1: Full document validation
    success = test_terminology_validation()
    
    # Test 2: Section validation
    test_section_validation()
    
    # Test 3: Portuguese detection
    test_portuguese_detection()
    
    print("\n" + "=" * 50)
    print("Test Suite Complete")
    
    if success:
        print("✓ Document validation passed")
    else:
        print("✗ Document validation failed - issues found")
    
    return 0 if success else 1


if __name__ == '__main__':
    exit(main())