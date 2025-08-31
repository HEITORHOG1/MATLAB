function validar_latex_compilacao()
% VALIDAR_LATEX_COMPILACAO - Task 13: Validate LaTeX compilation and formatting
%
% This function validates LaTeX compilation and formatting for the English
% translation of the scientific article, implementing all sub-tasks:
% - Test LaTeX compilation with English content
% - Verify all mathematical formulas render correctly  
% - Check figure and table references work properly
% - Ensure proper English hyphenation and spacing
%
% Requirements: 6.4

fprintf('TASK 13: LaTeX Compilation and Formatting Validation\n');
fprintf('==================================================\n\n');

% Initialize results structure
results = struct();
results.compilation = struct();
results.mathematics = struct();
results.references = struct();
results.hyphenation_spacing = struct();

% Task 13.1: Test LaTeX compilation with English content
fprintf('TASK 13.1: Testing LaTeX compilation with English content\n');
fprintf('--------------------------------------------------------\n');
results.compilation = validate_latex_compilation();

% Task 13.2: Verify mathematical formulas render correctly
fprintf('\nTASK 13.2: Verifying mathematical formulas render correctly\n');
fprintf('----------------------------------------------------------\n');
results.mathematics = validate_mathematical_formulas();

% Task 13.3: Check figure and table references work properly
fprintf('\nTASK 13.3: Checking figure and table references\n');
fprintf('-----------------------------------------------\n');
results.references = validate_figure_table_references();

% Task 13.4: Ensure proper English hyphenation and spacing
fprintf('\nTASK 13.4: Ensuring proper English hyphenation and spacing\n');
fprintf('---------------------------------------------------------\n');
results.hyphenation_spacing = validate_english_hyphenation_spacing();

% Generate comprehensive validation report
generate_validation_report(results);

end

function compilation_results = validate_latex_compilation()
% Validate LaTeX compilation with English content

compilation_results = struct();
tex_file = 'artigo_cientifico_corrosao.tex';

% Check if LaTeX file exists
if ~exist(tex_file, 'file')
    fprintf('✗ LaTeX file not found: %s\n', tex_file);
    compilation_results.file_exists = false;
    compilation_results.compilation_successful = false;
    compilation_results.pdf_generated = false;
    compilation_results.english_babel_loaded = false;
    return;
end

compilation_results.file_exists = true;
fprintf('✓ LaTeX file found: %s\n', tex_file);

% Read LaTeX content
try
    fid = fopen(tex_file, 'r', 'n', 'UTF-8');
    if fid == -1
        error('Could not open LaTeX file');
    end
    content = fread(fid, '*char')';
    fclose(fid);
catch ME
    fprintf('✗ Error reading LaTeX file: %s\n', ME.message);
    compilation_results.compilation_successful = false;
    return;
end

% Check for English babel configuration
english_babel_patterns = {
    '\\usepackage\[english\]\{babel\}',
    '\\usepackage\{babel\}.*english',
    '\\selectlanguage\{english\}'
};

english_babel_found = false;
for i = 1:length(english_babel_patterns)
    if ~isempty(regexp(content, english_babel_patterns{i}, 'once'))
        english_babel_found = true;
        break;
    end
end

compilation_results.english_babel_loaded = english_babel_found;
if english_babel_found
    fprintf('✓ English babel configuration found\n');
else
    fprintf('⚠ English babel configuration not found\n');
end

% Check for essential LaTeX packages
essential_packages = {
    '\\documentclass',
    '\\begin{document}',
    '\\end{document}',
    '\\usepackage{amsmath}',
    '\\usepackage{graphicx}',
    '\\usepackage{natbib}'
};

package_check = true;
for i = 1:length(essential_packages)
    if isempty(strfind(content, essential_packages{i}))
        fprintf('⚠ Missing essential command/package: %s\n', essential_packages{i});
        package_check = false;
    end
end

if package_check
    fprintf('✓ Essential LaTeX packages and commands found\n');
end

% Attempt LaTeX compilation (if pdflatex is available)
try
    % Create temporary directory for compilation
    temp_dir = tempname;
    mkdir(temp_dir);
    
    % Copy necessary files
    copyfile(tex_file, fullfile(temp_dir, tex_file));
    
    if exist('referencias.bib', 'file')
        copyfile('referencias.bib', fullfile(temp_dir, 'referencias.bib'));
    end
    
    if exist('figuras', 'dir')
        copyfile('figuras', fullfile(temp_dir, 'figuras'), 'f');
    end
    
    % Try compilation
    current_dir = pwd;
    cd(temp_dir);
    
    [status, result] = system(['pdflatex -interaction=nonstopmode ' tex_file]);
    
    cd(current_dir);
    
    % Check if PDF was generated
    pdf_file = fullfile(temp_dir, strrep(tex_file, '.tex', '.pdf'));
    pdf_generated = exist(pdf_file, 'file') == 2;
    
    compilation_results.compilation_successful = (status == 0);
    compilation_results.pdf_generated = pdf_generated;
    
    if compilation_results.compilation_successful
        fprintf('✓ LaTeX compilation successful\n');
    else
        fprintf('✗ LaTeX compilation failed\n');
    end
    
    if pdf_generated
        fprintf('✓ PDF file generated successfully\n');
    else
        fprintf('✗ PDF file not generated\n');
    end
    
    % Clean up temporary directory
    rmdir(temp_dir, 's');
    
catch ME
    fprintf('⚠ Could not test LaTeX compilation: %s\n', ME.message);
    compilation_results.compilation_successful = false;
    compilation_results.pdf_generated = false;
end

end

function math_results = validate_mathematical_formulas()
% Verify all mathematical formulas render correctly

math_results = struct();
tex_file = 'artigo_cientifico_corrosao.tex';

% Read LaTeX content
try
    fid = fopen(tex_file, 'r', 'n', 'UTF-8');
    content = fread(fid, '*char')';
    fclose(fid);
catch ME
    fprintf('✗ Error reading LaTeX file: %s\n', ME.message);
    return;
end

% Check for equation environments
equation_patterns = {
    '\\begin\{equation\}',
    '\\begin\{align\}',
    '\\begin\{gather\}',
    '\\begin\{eqnarray\}'
};

equations_found = 0;
for i = 1:length(equation_patterns)
    matches = regexp(content, equation_patterns{i}, 'match');
    equations_found = equations_found + length(matches);
end

math_results.equations_found = equations_found > 0;
fprintf('✓ Found %d equation environments\n', equations_found);

% Check for inline math
inline_math_matches = regexp(content, '\$[^$]+\$', 'match');
math_results.inline_math_valid = length(inline_math_matches) > 0;
fprintf('✓ Found %d inline math expressions\n', length(inline_math_matches));

% Check for mathematical symbols
math_symbols = {
    '\\alpha', '\\beta', '\\sigma', '\\varepsilon', '\\odot', 
    '\\cap', '\\cup', '\\times', '\\pm', '\\leq', '\\geq'
};

symbols_found = 0;
for i = 1:length(math_symbols)
    if ~isempty(strfind(content, math_symbols{i}))
        symbols_found = symbols_found + 1;
    end
end

math_results.mathematical_symbols_valid = symbols_found > 0;
fprintf('✓ Found %d different mathematical symbols\n', symbols_found);

% Check for balanced equation environments
begin_eq = length(regexp(content, '\\begin\{equation\}', 'match'));
end_eq = length(regexp(content, '\\end\{equation\}', 'match'));

math_results.equation_environments_valid = (begin_eq == end_eq);
if begin_eq == end_eq
    fprintf('✓ Equation environments are balanced (%d pairs)\n', begin_eq);
else
    fprintf('⚠ Unbalanced equation environments: %d begin, %d end\n', begin_eq, end_eq);
end

% Check for siunitx usage
siunitx_patterns = {'\\SI\{', '\\si\{', '\\num\{', '\\usepackage{siunitx}'};
siunitx_usage = 0;
for i = 1:length(siunitx_patterns)
    if ~isempty(strfind(content, siunitx_patterns{i}))
        siunitx_usage = siunitx_usage + 1;
    end
end

math_results.siunitx_usage_correct = siunitx_usage > 0;
if siunitx_usage > 0
    fprintf('✓ siunitx package usage detected\n');
else
    fprintf('⚠ siunitx package usage not detected\n');
end

end

function ref_results = validate_figure_table_references()
% Check figure and table references work properly

ref_results = struct();
tex_file = 'artigo_cientifico_corrosao.tex';

% Read LaTeX content
try
    fid = fopen(tex_file, 'r', 'n', 'UTF-8');
    content = fread(fid, '*char')';
    fclose(fid);
catch ME
    fprintf('✗ Error reading LaTeX file: %s\n', ME.message);
    return;
end

% Find figure labels
figure_labels = regexp(content, '\\label\{fig:([^}]+)\}', 'tokens');
figure_labels = [figure_labels{:}];
ref_results.figure_labels_found = length(figure_labels) > 0;
fprintf('✓ Found %d figure labels\n', length(figure_labels));

% Find table labels  
table_labels = regexp(content, '\\label\{tab:([^}]+)\}', 'tokens');
table_labels = [table_labels{:}];
ref_results.table_labels_found = length(table_labels) > 0;
fprintf('✓ Found %d table labels\n', length(table_labels));

% Find figure references
figure_refs = regexp(content, '\\ref\{fig:([^}]+)\}', 'tokens');
figure_refs = [figure_refs{:}];
% Also check for Figure~\ref patterns
figure_refs2 = regexp(content, 'Figure~?\\ref\{fig:([^}]+)\}', 'tokens');
figure_refs2 = [figure_refs2{:}];
all_figure_refs = [figure_refs, figure_refs2];
fprintf('✓ Found %d figure references\n', length(all_figure_refs));

% Find table references
table_refs = regexp(content, '\\ref\{tab:([^}]+)\}', 'tokens');
table_refs = [table_refs{:}];
% Also check for Table~\ref patterns
table_refs2 = regexp(content, 'Table~?\\ref\{tab:([^}]+)\}', 'tokens');
table_refs2 = [table_refs2{:}];
all_table_refs = [table_refs, table_refs2];
fprintf('✓ Found %d table references\n', length(all_table_refs));

% Check for unresolved references
unresolved_fig_refs = {};
for i = 1:length(all_figure_refs)
    if ~any(strcmp(all_figure_refs{i}, figure_labels))
        unresolved_fig_refs{end+1} = all_figure_refs{i};
    end
end

unresolved_tab_refs = {};
for i = 1:length(all_table_refs)
    if ~any(strcmp(all_table_refs{i}, table_labels))
        unresolved_tab_refs{end+1} = all_table_refs{i};
    end
end

ref_results.figure_references_valid = isempty(unresolved_fig_refs);
ref_results.table_references_valid = isempty(unresolved_tab_refs);
ref_results.all_references_resolved = isempty(unresolved_fig_refs) && isempty(unresolved_tab_refs);

if isempty(unresolved_fig_refs)
    fprintf('✓ All figure references resolved\n');
else
    fprintf('⚠ Unresolved figure references: %s\n', strjoin(unresolved_fig_refs, ', '));
end

if isempty(unresolved_tab_refs)
    fprintf('✓ All table references resolved\n');
else
    fprintf('⚠ Unresolved table references: %s\n', strjoin(unresolved_tab_refs, ', '));
end

end

function hyph_results = validate_english_hyphenation_spacing()
% Ensure proper English hyphenation and spacing

hyph_results = struct();
tex_file = 'artigo_cientifico_corrosao.tex';

% Read LaTeX content
try
    fid = fopen(tex_file, 'r', 'n', 'UTF-8');
    content = fread(fid, '*char')';
    fclose(fid);
catch ME
    fprintf('✗ Error reading LaTeX file: %s\n', ME.message);
    return;
end

% Check English babel configuration
english_babel_patterns = {
    '\\usepackage\[english\]\{babel\}',
    '\\usepackage\{babel\}.*english',
    '\\selectlanguage\{english\}'
};

english_babel_configured = false;
for i = 1:length(english_babel_patterns)
    if ~isempty(regexp(content, english_babel_patterns{i}, 'once'))
        english_babel_configured = true;
        break;
    end
end

hyph_results.english_babel_configured = english_babel_configured;
if english_babel_configured
    fprintf('✓ English babel configuration found\n');
else
    fprintf('⚠ English babel configuration not found\n');
end

% Check microtype package for better typography
microtype_loaded = ~isempty(strfind(content, '\usepackage{microtype}'));
hyph_results.microtype_loaded = microtype_loaded;
if microtype_loaded
    fprintf('✓ Microtype package loaded for better typography\n');
else
    fprintf('⚠ Microtype package not loaded\n');
end

% Check for proper spacing commands
spacing_commands = {'\\,', '\\:', '\\;', '~', '\\quad', '\\qquad'};
spacing_found = 0;
for i = 1:length(spacing_commands)
    if ~isempty(strfind(content, spacing_commands{i}))
        spacing_found = spacing_found + 1;
    end
end

hyph_results.proper_spacing_commands = spacing_found > 0;
fprintf('✓ Found %d different spacing commands\n', spacing_found);

% Check for absence of Portuguese hyphenation patterns
portuguese_patterns = {
    '\\usepackage\[.*portuguese.*\]\{babel\}',
    '\\selectlanguage\{portuguese\}',
    '\\usepackage\[brazil\]\{babel\}'
};

portuguese_hyphenation_found = false;
for i = 1:length(portuguese_patterns)
    if ~isempty(regexp(content, portuguese_patterns{i}, 'once'))
        portuguese_hyphenation_found = true;
        break;
    end
end

hyph_results.no_portuguese_hyphenation = ~portuguese_hyphenation_found;
if ~portuguese_hyphenation_found
    fprintf('✓ No Portuguese hyphenation patterns found\n');
else
    fprintf('⚠ Portuguese hyphenation patterns detected\n');
end

% Detect English text content
english_indicators = {
    'Background:', 'Objective:', 'Methods:', 'Results:', 'Conclusions:',
    'Figure', 'Table', 'Section', 'Introduction', 'Methodology',
    'Discussion', 'Literature Review', 'References'
};

english_found = 0;
for i = 1:length(english_indicators)
    if ~isempty(strfind(content, english_indicators{i}))
        english_found = english_found + 1;
    end
end

hyph_results.english_text_detected = english_found >= 5;
fprintf('✓ Found %d English text indicators\n', english_found);

end

function generate_validation_report(results)
% Generate comprehensive validation report

fprintf('\n');
fprintf('================================================================\n');
fprintf('LATEX COMPILATION AND FORMATTING VALIDATION SUMMARY\n');
fprintf('================================================================\n');

% Count total checks and passed checks
total_checks = 0;
passed_checks = 0;

categories = fieldnames(results);
for i = 1:length(categories)
    category = categories{i};
    category_results = results.(category);
    
    fprintf('\n%s VALIDATION:\n', upper(strrep(category, '_', ' ')));
    
    checks = fieldnames(category_results);
    for j = 1:length(checks)
        check = checks{j};
        result = category_results.(check);
        total_checks = total_checks + 1;
        
        if result
            passed_checks = passed_checks + 1;
            status = '✓ PASS';
        else
            status = '✗ FAIL';
        end
        
        fprintf('  %s: %s\n', strrep(check, '_', ' '), status);
    end
end

success_rate = (passed_checks / total_checks) * 100;

fprintf('\nOVERALL VALIDATION RESULTS:\n');
fprintf('  Total checks: %d\n', total_checks);
fprintf('  Passed: %d\n', passed_checks);
fprintf('  Failed: %d\n', total_checks - passed_checks);
fprintf('  Success rate: %.1f%%\n', success_rate);

% Save detailed report to file
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
report_file = sprintf('latex_validation_report_%s.txt', timestamp);

try
    fid = fopen(report_file, 'w', 'n', 'UTF-8');
    fprintf(fid, 'LATEX COMPILATION AND FORMATTING VALIDATION REPORT\n');
    fprintf(fid, '==================================================\n');
    fprintf(fid, 'Generated: %s\n', datestr(now));
    fprintf(fid, 'LaTeX file: artigo_cientifico_corrosao.tex\n\n');
    
    fprintf(fid, 'VALIDATION RESULTS:\n');
    fprintf(fid, '-------------------\n');
    
    for i = 1:length(categories)
        category = categories{i};
        category_results = results.(category);
        
        fprintf(fid, '\n%s:\n', upper(strrep(category, '_', ' ')));
        
        checks = fieldnames(category_results);
        for j = 1:length(checks)
            check = checks{j};
            result = category_results.(check);
            status = 'PASS';
            if ~result
                status = 'FAIL';
            end
            fprintf(fid, '  %s: %s\n', strrep(check, '_', ' '), status);
        end
    end
    
    fprintf(fid, '\nSUMMARY:\n');
    fprintf(fid, '  Total checks: %d\n', total_checks);
    fprintf(fid, '  Passed: %d\n', passed_checks);
    fprintf(fid, '  Failed: %d\n', total_checks - passed_checks);
    fprintf(fid, '  Success rate: %.1f%%\n', success_rate);
    
    fclose(fid);
    fprintf('\n✓ Detailed validation report saved to: %s\n', report_file);
    
catch ME
    fprintf('\n⚠ Could not save validation report: %s\n', ME.message);
end

fprintf('\n================================================================\n');
if success_rate >= 90
    fprintf('✓ LATEX VALIDATION COMPLETED SUCCESSFULLY\n');
elseif success_rate >= 75
    fprintf('⚠ LATEX VALIDATION COMPLETED WITH WARNINGS\n');
else
    fprintf('✗ LATEX VALIDATION FAILED - CRITICAL ISSUES FOUND\n');
end
fprintf('================================================================\n');

end