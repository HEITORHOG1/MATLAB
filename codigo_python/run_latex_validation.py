#!/usr/bin/env python3
"""
Run LaTeX Compilation and Formatting Validation

This script executes Task 13 validation for the English translation article.
"""

import sys
import os
from pathlib import Path

# Add src directory to path
sys.path.insert(0, str(Path(__file__).parent / "src"))

from validation.latex_compilation_validator import LaTeXCompilationValidator

def main():
    """Run the LaTeX validation for Task 13."""
    print("TASK 13: LaTeX Compilation and Formatting Validation")
    print("=" * 60)
    print("Validating English translation article LaTeX compilation...")
    print()
    
    # Initialize validator
    validator = LaTeXCompilationValidator("artigo_cientifico_corrosao.tex")
    
    # Run complete validation
    try:
        results = validator.run_complete_validation()
        
        # Check if validation was successful
        all_passed = all(
            all(category_results.values()) 
            for category_results in results.values()
        )
        
        if all_passed:
            print("\n🎉 All LaTeX validation checks passed!")
            return 0
        else:
            print("\n⚠️  Some LaTeX validation checks failed. See report above.")
            return 1
            
    except Exception as e:
        print(f"\n❌ LaTeX validation failed with error: {str(e)}")
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)