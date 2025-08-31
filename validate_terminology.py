#!/usr/bin/env python3
"""
Command-line interface for terminology validation.
Validates the English translation for terminology consistency.
"""

import os
import sys
import argparse
from datetime import datetime

# Add src directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'translation'))

from terminology_validator import TerminologyValidator


def main():
    """Main command-line interface."""
    
    parser = argparse.ArgumentParser(
        description='Validate terminology consistency in English translation',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python validate_terminology.py artigo_cientifico_corrosao.tex
  python validate_terminology.py artigo_cientifico_corrosao.tex --output report.md
  python validate_terminology.py artigo_cientifico_corrosao.tex --verbose
  python validate_terminology.py artigo_cientifico_corrosao.tex --section methodology
        """
    )
    
    parser.add_argument(
        'tex_file',
        help='Path to LaTeX file to validate'
    )
    
    parser.add_argument(
        '--output', '-o',
        help='Output path for validation report (default: auto-generated)'
    )
    
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Show detailed validation results'
    )
    
    parser.add_argument(
        '--section', '-s',
        help='Validate specific section only'
    )
    
    parser.add_argument(
        '--quiet', '-q',
        action='store_true',
        help='Minimal output (exit code only)'
    )
    
    args = parser.parse_args()
    
    # Check if file exists
    if not os.path.exists(args.tex_file):
        if not args.quiet:
            print(f"Error: File '{args.tex_file}' not found")
        return 1
    
    # Initialize validator
    validator = TerminologyValidator()
    
    # Generate output filename if not provided
    if not args.output:
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        base_name = os.path.splitext(os.path.basename(args.tex_file))[0]
        args.output = f"terminology_validation_{base_name}_{timestamp}.md"
    
    try:
        # Perform validation
        if args.section:
            # Section-specific validation
            with open(args.tex_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract section content (simplified)
            import re
            section_pattern = rf'\\section\{{{re.escape(args.section)}\}}(.*?)(?=\\section|\Z)'
            match = re.search(section_pattern, content, re.DOTALL | re.IGNORECASE)
            
            if not match:
                if not args.quiet:
                    print(f"Error: Section '{args.section}' not found")
                return 1
            
            section_content = match.group(1)
            result = validator.validate_section(section_content, args.section)
            
        else:
            # Full document validation
            result = validator.validate_document(args.tex_file)
        
        # Generate report
        report = validator.generate_validation_report(result, args.output)
        
        # Output results
        if args.quiet:
            # Quiet mode: only exit code
            pass
        elif args.verbose:
            # Verbose mode: show full report
            print(report)
        else:
            # Normal mode: summary
            status = "PASSED" if result.is_valid else "FAILED"
            print(f"Terminology Validation: {status}")
            print(f"File: {args.tex_file}")
            print(f"Issues: {len(result.issues)}")
            print(f"Warnings: {len(result.warnings)}")
            
            if result.statistics:
                print(f"Word Count: {result.statistics.get('word_count', 'N/A')}")
                print(f"Sections: {result.statistics.get('section_count', 'N/A')}")
            
            print(f"Report saved to: {args.output}")
            
            # Show first few critical issues
            if result.issues and not args.quiet:
                print("\nCritical Issues (first 5):")
                for i, issue in enumerate(result.issues[:5], 1):
                    print(f"  {i}. {issue}")
                if len(result.issues) > 5:
                    print(f"  ... and {len(result.issues) - 5} more issues")
        
        return 0 if result.is_valid else 1
        
    except Exception as e:
        if not args.quiet:
            print(f"Error during validation: {e}")
        return 1


if __name__ == '__main__':
    exit(main())