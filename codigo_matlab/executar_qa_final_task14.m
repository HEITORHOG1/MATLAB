function executar_qa_final_task14()
% EXECUTAR_QA_FINAL_TASK14 - Task 14: Perform final quality assurance review
%
% This function implements the comprehensive final quality assurance review:
% - Execute comprehensive translation quality tests
% - Verify academic writing quality meets English standards
% - Check technical accuracy of all translated content
% - Generate translation quality report
%
% Requirements: 6.5

fprintf('TASK 14: COMPREHENSIVE QUALITY ASSURANCE REVIEW\n');
fprintf('===============================================\n');
fprintf('English Translation Final Quality Assessment\n');
fprintf('Generated: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));

% Initialize comprehensive quality assessment
qa_results = struct();
qa_results.timestamp = datestr(now, 'yyyymmdd_HHMMSS');
qa_results.tests_performed = {};
qa_results.quality_scores = struct();
qa_results.issues_found = struct();
qa_results.recommendations = {};

% Define file paths
tex_file = 'artigo_cientifico_corrosao.tex';

try
    % Sub-task 14.1: Execute comprehensive translation quality tests
    fprintf('SUB-TASK 14.1: Executing comprehensive translation quality tests\n');
    fprintf('---------------------------------------------------------------\n');
    [quality_tests_results] = execute_comprehensive_quality_tests(tex_file);
    qa_results.quality_scores = merge_structs(qa_results.quality_scores, quality_tests_results.scores);
    qa_results.issues_found = merge_structs(qa_results.issues_found, quality_tests_results.issues);
    qa_results.tests_performed = [qa_results.tests_performed, quality_tests_results.tests];
    
    % Sub-task 14.2: Verify academic writing quality meets English standards
    fprintf('\nSUB-TASK 14.2: Verifying academic writing quality standards\n');
    fprintf('----------------------------------------------------------\n');
    [academic_results] = verify_academic_writing_standards(tex_file);
    qa_results.quality_scores = merge_structs(qa_results.quality_scores, academic_results.scores);
    qa_results.issues_found = merge_structs(qa_results.issues_found, academic_results.issues);
    qa_results.tests_performed = [qa_results.tests_performed, academic_results.tests];
    
    % Sub-task 14.3: Check technical accuracy of all translated content
    fprintf('\nSUB-TASK 14.3: Checking technical accuracy of translated content\n');
    fprintf('----------------------------------------------------------------\n');
    [technical_results] = check_technical_accuracy(tex_file);
    qa_results.quality_scores = merge_structs(qa_results.quality_scores, technical_results.scores);
    qa_results.issues_found = merge_structs(qa_results.issues_found, technical_results.issues);
    qa_results.tests_performed = [qa_results.tests_performed, technical_results.tests];
    
    % Sub-task 14.4: Generate translation quality report
    fprintf('\nSUB-TASK 14.4: Generating comprehensive translation quality report\n');
    fprintf('-----------------------------------------------------------------\n');
    
    % Calculate overall quality metrics
    [overall_score, quality_level] = calculate_overall_quality_score(qa_results.quality_scores);
    qa_results.overall_score = overall_score;
    qa_results.quality_level = quality_level;
    
    % Generate recommendations
    qa_results.recommendations = generate_quality_recommendations(qa_results.quality_scores, qa_results.issues_found);
    
    % Generate comprehensive report
    report_file = generate_comprehensive_quality_report(qa_results);
    
    % Display final summary
    display_quality_assessment_summary(qa_results, report_file);
    
    fprintf('\n✓ TASK 14 COMPLETED: Final quality assurance review finished\n');
    fprintf('Report saved to: %s\n', report_file);
    
catch ME
    fprintf('✗ ERROR in Task 14: %s\n', ME.message);
    fprintf('File: %s, Line: %d\n', ME.stack(1).file, ME.stack(1).line);
end

end

function results = execute_comprehensive_quality_tests(tex_file)
% Execute comprehensive translation quality tests

fprintf('Executing comprehensive quality tests...\n');

results = struct();
results.scores = struct();
results.issues = struct();
results.tests = {};

% Test 1: Technical terminology accuracy
fprintf('  → Testing technical terminology accuracy...\n');
[term_score, term_issues] = test_technical_terminology_accuracy(tex_file);
results.scores.technical_terminology = term_score;
results.issues.terminology = term_issues;
results.tests{end+1} = 'technical_terminology_accuracy';
fprintf('    Score: %.1f%%\n', term_score * 100);

% Test 2: Translation completeness
fprintf('  → Testing translation completeness...\n');
[complete_score, complete_issues] = test_translation_completeness(tex_file);
results.scores.translation_completeness = complete_score;
results.issues.completeness = complete_issues;
results.tests{end+1} = 'translation_completeness';
fprintf('    Score: %.1f%%\n', complete_score * 100);

% Test 3: LaTeX structure integrity
fprintf('  → Testing LaTeX structure integrity...\n');
[latex_score, latex_issues] = test_latex_structure_integrity(tex_file);
results.scores.latex_integrity = latex_score;
results.issues.latex_structure = latex_issues;
results.tests{end+1} = 'latex_structure_integrity';
fprintf('    Score: %.1f%%\n', latex_score * 100);

% Test 4: Reference consistency
fprintf('  → Testing reference consistency...\n');
[ref_score, ref_issues] = test_reference_consistency(tex_file);
results.scores.reference_consistency = ref_score;
results.issues.references = ref_issues;
results.tests{end+1} = 'reference_consistency';
fprintf('    Score: %.1f%%\n', ref_score * 100);

end

function results = verify_academic_writing_standards(tex_file)
% Verify academic writing quality meets English standards

fprintf('Verifying academic writing standards...\n');

results = struct();
results.scores = struct();
results.issues = struct();
results.tests = {};

% Test 1: Abstract structure compliance
fprintf('  → Checking abstract structure...\n');
[abstract_score, abstract_issues] = check_abstract_structure(tex_file);
results.scores.abstract_structure = abstract_score;
results.issues.abstract = abstract_issues;
results.tests{end+1} = 'abstract_structure_compliance';
fprintf('    Score: %.1f%%\n', abstract_score * 100);

% Test 2: Academic tone and style
fprintf('  → Analyzing academic tone and style...\n');
[tone_score, tone_issues] = analyze_academic_tone(tex_file);
results.scores.academic_tone = tone_score;
results.issues.tone = tone_issues;
results.tests{end+1} = 'academic_tone_analysis';
fprintf('    Score: %.1f%%\n', tone_score * 100);

% Test 3: Scientific methodology presentation
fprintf('  → Evaluating methodology presentation...\n');
[method_score, method_issues] = evaluate_methodology_presentation(tex_file);
results.scores.methodology_presentation = method_score;
results.issues.methodology = method_issues;
results.tests{end+1} = 'methodology_presentation';
fprintf('    Score: %.1f%%\n', method_score * 100);

% Test 4: Results and discussion quality
fprintf('  → Assessing results and discussion quality...\n');
[results_score, results_issues] = assess_results_discussion_quality(tex_file);
results.scores.results_discussion = results_score;
results.issues.results_discussion = results_issues;
results.tests{end+1} = 'results_discussion_quality';
fprintf('    Score: %.1f%%\n', results_score * 100);

end

function results = check_technical_accuracy(tex_file)
% Check technical accuracy of all translated content

fprintf('Checking technical accuracy of translated content...\n');

results = struct();
results.scores = struct();
results.issues = struct();
results.tests = {};

% Test 1: Engineering terminology accuracy
fprintf('  → Validating engineering terminology...\n');
[eng_score, eng_issues] = validate_engineering_terminology(tex_file);
results.scores.engineering_terminology = eng_score;
results.issues.engineering = eng_issues;
results.tests{end+1} = 'engineering_terminology_validation';
fprintf('    Score: %.1f%%\n', eng_score * 100);

% Test 2: AI/ML terminology accuracy
fprintf('  → Validating AI/ML terminology...\n');
[ai_score, ai_issues] = validate_ai_ml_terminology(tex_file);
results.scores.ai_ml_terminology = ai_score;
results.issues.ai_ml = ai_issues;
results.tests{end+1} = 'ai_ml_terminology_validation';
fprintf('    Score: %.1f%%\n', ai_score * 100);

% Test 3: Mathematical notation consistency
fprintf('  → Checking mathematical notation...\n');
[math_score, math_issues] = check_mathematical_notation(tex_file);
results.scores.mathematical_notation = math_score;
results.issues.mathematics = math_issues;
results.tests{end+1} = 'mathematical_notation_consistency';
fprintf('    Score: %.1f%%\n', math_score * 100);

% Test 4: Statistical terminology accuracy
fprintf('  → Validating statistical terminology...\n');
[stats_score, stats_issues] = validate_statistical_terminology(tex_file);
results.scores.statistical_terminology = stats_score;
results.issues.statistics = stats_issues;
results.tests{end+1} = 'statistical_terminology_validation';
fprintf('    Score: %.1f%%\n', stats_score * 100);

end

function [score, issues] = test_technical_terminology_accuracy(tex_file)
% Test technical terminology accuracy and consistency

issues = {};

try
    % Read LaTeX file
    content = read_tex_file(tex_file);
    if isempty(content)
        issues{end+1} = 'Could not read LaTeX file';
        score = 0;
        return;
    end
    
    content_lower = lower(content);
    
    % Define required English technical terms
    required_terms = {
        'ASTM A572 Grade 50', 'W-beams', 'structural inspection', ...
        'corrosion', 'structural integrity', 'deterioration', ...
        'convolutional neural networks', 'semantic segmentation', ...
        'deep learning', 'attention mechanisms', 'U-Net', ...
        'Attention U-Net', 'IoU', 'Dice coefficient', ...
        'precision', 'recall', 'F1-score', 'accuracy'
    };
    
    % Portuguese terms that should NOT be present
    portuguese_terms = {
        'aço', 'corrosão', 'viga', 'treinamento', 'validação', ...
        'precisão', 'revocação', 'acurácia', 'segmentação', ...
        'aprendizado', 'rede neural', 'convolucional', 'metodologia'
    };
    
    % Check for required English terms
    terms_found = 0;
    for i = 1:length(required_terms)
        if contains(content_lower, lower(required_terms{i}))
            terms_found = terms_found + 1;
        else
            issues{end+1} = sprintf('Missing technical term: %s', required_terms{i});
        end
    end
    
    % Check for Portuguese terms (should not be present)
    portuguese_found = 0;
    for i = 1:length(portuguese_terms)
        if contains(content_lower, portuguese_terms{i})
            portuguese_found = portuguese_found + 1;
            issues{end+1} = sprintf('Portuguese term found: %s', portuguese_terms{i});
        end
    end
    
    % Calculate score
    base_score = terms_found / length(required_terms);
    
    % Apply penalty for Portuguese terms
    if portuguese_found > 0
        penalty = min(portuguese_found * 0.1, 0.5); % Max 50% penalty
        score = max(0, base_score - penalty);
    else
        score = base_score;
    end
    
catch ME
    issues{end+1} = sprintf('Error in terminology test: %s', ME.message);
    score = 0;
end

end

function [score, issues] = test_translation_completeness(tex_file)
% Test translation completeness and content preservation

issues = {};

try
    content = read_tex_file(tex_file);
    if isempty(content)
        issues{end+1} = 'Could not read LaTeX file';
        score = 0;
        return;
    end
    
    completeness_score = 0;
    total_sections = 0;
    
    % Required sections for scientific article
    required_sections = {'abstract', 'introduction', 'methodology', 'results', 'discussion', 'conclusion'};
    sections_found = 0;
    
    for i = 1:length(required_sections)
        section_pattern = sprintf('\\\\section\\{.*?%s.*?\\}', required_sections{i});
        if ~isempty(regexp(content, section_pattern, 'once', 'ignorecase'))
            sections_found = sections_found + 1;
        else
            issues{end+1} = sprintf('Required section missing: %s', required_sections{i});
        end
    end
    
    completeness_score = completeness_score + (sections_found / length(required_sections));
    total_sections = total_sections + 1;
    
    % Check figure references
    figure_refs = {'Figure 1', 'Figure 2', 'Figure 3', 'Figure 4', 'Figure 5', 'Figure 6', 'Figure 7'};
    figures_found = 0;
    
    for i = 1:length(figure_refs)
        if contains(content, figure_refs{i})
            figures_found = figures_found + 1;
        else
            issues{end+1} = sprintf('Figure reference missing: %s', figure_refs{i});
        end
    end
    
    completeness_score = completeness_score + (figures_found / length(figure_refs));
    total_sections = total_sections + 1;
    
    % Check table references
    table_refs = {'Table 1', 'Table 2', 'Table 3', 'Table 4'};
    tables_found = 0;
    
    for i = 1:length(table_refs)
        if contains(content, table_refs{i})
            tables_found = tables_found + 1;
        else
            issues{end+1} = sprintf('Table reference missing: %s', table_refs{i});
        end
    end
    
    completeness_score = completeness_score + (tables_found / length(table_refs));
    total_sections = total_sections + 1;
    
    % Final score
    score = completeness_score / total_sections;
    
catch ME
    issues{end+1} = sprintf('Error in completeness test: %s', ME.message);
    score = 0;
end

end

function [score, issues] = test_latex_structure_integrity(tex_file)
% Test LaTeX structure integrity

issues = {};

try
    content = read_tex_file(tex_file);
    if isempty(content)
        issues{end+1} = 'Could not read LaTeX file';
        score = 0;
        return;
    end
    
    integrity_checks = 0;
    passed_checks = 0;
    
    % Essential LaTeX commands
    essential_commands = {
        '\\documentclass', '\\begin{document}', '\\end{document}', ...
        '\\section', '\\subsection', '\\cite', '\\ref'
    };
    
    for i = 1:length(essential_commands)
        if contains(content, essential_commands{i})
            passed_checks = passed_checks + 1;
        else
            issues{end+1} = sprintf('Essential LaTeX command missing: %s', essential_commands{i});
        end
        integrity_checks = integrity_checks + 1;
    end
    
    % Mathematical environments
    math_envs = {'\\begin{equation}', '\\end{equation}'};
    math_found = 0;
    
    for i = 1:length(math_envs)
        if contains(content, math_envs{i})
            math_found = math_found + 1;
        end
    end
    
    if math_found == length(math_envs)
        passed_checks = passed_checks + 1;
    elseif math_found > 0
        issues{end+1} = 'Incomplete mathematical environments found';
    end
    integrity_checks = integrity_checks + 1;
    
    % Bibliography
    if contains(content, '\\bibliography{') || contains(content, '\\bibitem')
        passed_checks = passed_checks + 1;
    else
        issues{end+1} = 'Bibliography section missing or improperly formatted';
    end
    integrity_checks = integrity_checks + 1;
    
    % Calculate score
    score = passed_checks / integrity_checks;
    
catch ME
    issues{end+1} = sprintf('Error in LaTeX integrity test: %s', ME.message);
    score = 0;
end

end

function [score, issues] = test_reference_consistency(tex_file)
% Test reference consistency

issues = {};

try
    content = read_tex_file(tex_file);
    if isempty(content)
        issues{end+1} = 'Could not read LaTeX file';
        score = 0;
        return;
    end
    
    % Find all labels
    all_labels = regexp(content, '\\label\{([^}]+)\}', 'tokens');
    all_labels = [all_labels{:}];
    
    % Find all references
    all_refs = regexp(content, '\\ref\{([^}]+)\}', 'tokens');
    all_refs = [all_refs{:}];
    
    % Check for unresolved references
    unresolved_refs = {};
    for i = 1:length(all_refs)
        if ~any(strcmp(all_refs{i}, all_labels))
            unresolved_refs{end+1} = all_refs{i};
        end
    end
    
    % Check for unused labels
    unused_labels = {};
    for i = 1:length(all_labels)
        if ~any(strcmp(all_labels{i}, all_refs))
            unused_labels{end+1} = all_labels{i};
        end
    end
    
    % Calculate score
    total_refs = length(all_refs);
    resolved_refs = total_refs - length(unresolved_refs);
    
    if total_refs > 0
        score = resolved_refs / total_refs;
    else
        score = 1.0; % No references to check
    end
    
    % Add issues
    for i = 1:length(unresolved_refs)
        issues{end+1} = sprintf('Unresolved reference: %s', unresolved_refs{i});
    end
    
    for i = 1:length(unused_labels)
        issues{end+1} = sprintf('Unused label: %s', unused_labels{i});
    end
    
catch ME
    issues{end+1} = sprintf('Error in reference consistency test: %s', ME.message);
    score = 0;
end

end

function [score, issues] = check_abstract_structure(tex_file)
% Check abstract structure compliance

issues = {};

try
    content = read_tex_file(tex_file);
    if isempty(content)
        issues{end+1} = 'Could not read LaTeX file';
        score = 0;
        return;
    end
    
    % Extract abstract content
    abstract_pattern = '\\begin\{abstract\}(.*?)\\end\{abstract\}';
    abstract_match = regexp(content, abstract_pattern, 'tokens', 'dotexceptnewline');
    
    if isempty(abstract_match)
        issues{end+1} = 'Abstract section not found';
        score = 0;
        return;
    end
    
    abstract_text = lower(abstract_match{1}{1});
    
    % Check for required abstract components
    abstract_components = {'background', 'objective', 'method', 'result', 'conclusion'};
    components_found = 0;
    
    for i = 1:length(abstract_components)
        if contains(abstract_text, abstract_components{i})
            components_found = components_found + 1;
        else
            issues{end+1} = sprintf('Abstract missing component: %s', abstract_components{i});
        end
    end
    
    score = components_found / length(abstract_components);
    
catch ME
    issues{end+1} = sprintf('Error in abstract structure check: %s', ME.message);
    score = 0;
end

end

function [score, issues] = analyze_academic_tone(tex_file)
% Analyze academic tone and style

issues = {};

try
    content = read_tex_file(tex_file);
    if isempty(content)
        issues{end+1} = 'Could not read LaTeX file';
        score = 0;
        return;
    end
    
    content_lower = lower(content);
    
    % Check for academic indicators
    academic_indicators = {
        'however', 'furthermore', 'moreover', 'therefore', 'consequently',
        'in contrast', 'on the other hand', 'in addition', 'specifically',
        'particularly', 'significantly', 'substantially'
    };
    
    indicators_found = 0;
    for i = 1:length(academic_indicators)
        if contains(content_lower, academic_indicators{i})
            indicators_found = indicators_found + 1;
        end
    end
    
    % Check for passive voice in methodology
    methodology_pattern = '\\section\{.*?methodology.*?\}(.*?)(?=\\section|$)';
    methodology_match = regexp(content_lower, methodology_pattern, 'tokens', 'dotexceptnewline');
    
    passive_score = 0;
    if ~isempty(methodology_match)
        methodology_text = methodology_match{1}{1};
        passive_indicators = {'was performed', 'were conducted', 'was implemented', 'was used', 'were analyzed'};
        
        passive_found = 0;
        for i = 1:length(passive_indicators)
            if contains(methodology_text, passive_indicators{i})
                passive_found = passive_found + 1;
            end
        end
        
        passive_score = min(passive_found / 3, 1.0);
    else
        issues{end+1} = 'Methodology section not found for passive voice analysis';
    end
    
    % Calculate overall tone score
    indicator_score = min(indicators_found / 8, 1.0); % Normalize to max 1.0
    score = (indicator_score + passive_score) / 2;
    
catch ME
    issues{end+1} = sprintf('Error in academic tone analysis: %s', ME.message);
    score = 0;
end

end

function [score, issues] = evaluate_methodology_presentation(tex_file)
% Evaluate methodology presentation

issues = {};

try
    content = read_tex_file(tex_file);
    if isempty(content)
        issues{end+1} = 'Could not read LaTeX file';
        score = 0;
        return;
    end
    
    % Extract methodology section
    methodology_pattern = '\\section\{.*?methodology.*?\}(.*?)(?=\\section|$)';
    methodology_match = regexp(content, methodology_pattern, 'tokens', 'dotexceptnewline', 'ignorecase');
    
    if isempty(methodology_match)
        issues{end+1} = 'Methodology section not found';
        score = 0;
        return;
    end
    
    methodology_text = lower(methodology_match{1}{1});
    
    % Check for methodology components
    methodology_components = {
        'dataset', 'training', 'validation', 'evaluation', 'metrics',
        'architecture', 'parameters', 'preprocessing', 'augmentation'
    };
    
    components_found = 0;
    for i = 1:length(methodology_components)
        if contains(methodology_text, methodology_components{i})
            components_found = components_found + 1;
        else
            issues{end+1} = sprintf('Methodology missing component: %s', methodology_components{i});
        end
    end
    
    score = components_found / length(methodology_components);
    
catch ME
    issues{end+1} = sprintf('Error in methodology evaluation: %s', ME.message);
    score = 0;
end

end

function [score, issues] = assess_results_discussion_quality(tex_file)
% Assess results and discussion quality

issues = {};

try
    content = read_tex_file(tex_file);
    if isempty(content)
        issues{end+1} = 'Could not read LaTeX file';
        score = 0;
        return;
    end
    
    content_lower = lower(content);
    
    % Check for statistical terminology in results
    stats_terms = {'p <', 'confidence interval', 'standard deviation', 'significant', 'correlation'};
    stats_found = 0;
    
    for i = 1:length(stats_terms)
        if contains(content_lower, stats_terms{i})
            stats_found = stats_found + 1;
        end
    end
    
    % Check for discussion elements
    discussion_elements = {'limitation', 'implication', 'future work', 'comparison', 'interpretation'};
    discussion_found = 0;
    
    for i = 1:length(discussion_elements)
        if contains(content_lower, discussion_elements{i})
            discussion_found = discussion_found + 1;
        end
    end
    
    % Calculate score
    stats_score = min(stats_found / 3, 1.0);
    discussion_score = min(discussion_found / 3, 1.0);
    score = (stats_score + discussion_score) / 2;
    
    if stats_found == 0
        issues{end+1} = 'No statistical terminology found in results';
    end
    
    if discussion_found == 0
        issues{end+1} = 'No discussion elements found';
    end
    
catch ME
    issues{end+1} = sprintf('Error in results/discussion assessment: %s', ME.message);
    score = 0;
end

end

function [score, issues] = validate_engineering_terminology(tex_file)
% Validate engineering terminology

issues = {};

try
    content = read_tex_file(tex_file);
    if isempty(content)
        issues{end+1} = 'Could not read LaTeX file';
        score = 0;
        return;
    end
    
    content_lower = lower(content);
    
    % Engineering terms that should be present
    engineering_terms = {
        'ASTM A572 Grade 50', 'W-beams', 'structural inspection',
        'corrosion', 'structural integrity', 'deterioration',
        'steel', 'structural', 'inspection', 'integrity'
    };
    
    terms_found = 0;
    for i = 1:length(engineering_terms)
        if contains(content_lower, lower(engineering_terms{i}))
            terms_found = terms_found + 1;
        else
            issues{end+1} = sprintf('Missing engineering term: %s', engineering_terms{i});
        end
    end
    
    score = terms_found / length(engineering_terms);
    
catch ME
    issues{end+1} = sprintf('Error in engineering terminology validation: %s', ME.message);
    score = 0;
end

end

function [score, issues] = validate_ai_ml_terminology(tex_file)
% Validate AI/ML terminology

issues = {};

try
    content = read_tex_file(tex_file);
    if isempty(content)
        issues{end+1} = 'Could not read LaTeX file';
        score = 0;
        return;
    end
    
    content_lower = lower(content);
    
    % AI/ML terms that should be present
    ai_ml_terms = {
        'convolutional neural networks', 'semantic segmentation',
        'deep learning', 'attention mechanisms', 'U-Net',
        'training', 'validation', 'neural network'
    };
    
    terms_found = 0;
    for i = 1:length(ai_ml_terms)
        if contains(content_lower, lower(ai_ml_terms{i}))
            terms_found = terms_found + 1;
        else
            issues{end+1} = sprintf('Missing AI/ML term: %s', ai_ml_terms{i});
        end
    end
    
    score = terms_found / length(ai_ml_terms);
    
catch ME
    issues{end+1} = sprintf('Error in AI/ML terminology validation: %s', ME.message);
    score = 0;
end

end

function [score, issues] = check_mathematical_notation(tex_file)
% Check mathematical notation consistency

issues = {};

try
    content = read_tex_file(tex_file);
    if isempty(content)
        issues{end+1} = 'Could not read LaTeX file';
        score = 0;
        return;
    end
    
    % Check for equation environments
    begin_eq = length(regexp(content, '\\begin\{equation\}', 'match'));
    end_eq = length(regexp(content, '\\end\{equation\}', 'match'));
    
    % Check for mathematical symbols
    math_symbols = {'\\alpha', '\\beta', '\\sigma', '\\times', '\\leq', '\\geq'};
    symbols_found = 0;
    
    for i = 1:length(math_symbols)
        if contains(content, math_symbols{i})
            symbols_found = symbols_found + 1;
        end
    end
    
    % Calculate score
    equation_balance = (begin_eq == end_eq);
    symbol_presence = (symbols_found > 0);
    
    score_components = [equation_balance, symbol_presence];
    score = sum(score_components) / length(score_components);
    
    if ~equation_balance
        issues{end+1} = sprintf('Unbalanced equation environments: %d begin, %d end', begin_eq, end_eq);
    end
    
    if ~symbol_presence
        issues{end+1} = 'No mathematical symbols found';
    end
    
catch ME
    issues{end+1} = sprintf('Error in mathematical notation check: %s', ME.message);
    score = 0;
end

end

function [score, issues] = validate_statistical_terminology(tex_file)
% Validate statistical terminology

issues = {};

try
    content = read_tex_file(tex_file);
    if isempty(content)
        issues{end+1} = 'Could not read LaTeX file';
        score = 0;
        return;
    end
    
    content_lower = lower(content);
    
    % Statistical terms that should be present
    stats_terms = {
        'IoU', 'Dice coefficient', 'precision', 'recall', 
        'F1-score', 'accuracy', 'mean', 'standard deviation'
    };
    
    terms_found = 0;
    for i = 1:length(stats_terms)
        if contains(content_lower, lower(stats_terms{i}))
            terms_found = terms_found + 1;
        else
            issues{end+1} = sprintf('Missing statistical term: %s', stats_terms{i});
        end
    end
    
    score = terms_found / length(stats_terms);
    
catch ME
    issues{end+1} = sprintf('Error in statistical terminology validation: %s', ME.message);
    score = 0;
end

end

function [overall_score, quality_level] = calculate_overall_quality_score(scores)
% Calculate overall quality score with weighted average

% Define weights for different quality aspects
weights = struct();
weights.technical_terminology = 0.15;
weights.translation_completeness = 0.15;
weights.latex_integrity = 0.10;
weights.reference_consistency = 0.10;
weights.abstract_structure = 0.10;
weights.academic_tone = 0.10;
weights.methodology_presentation = 0.10;
weights.results_discussion = 0.10;
weights.engineering_terminology = 0.05;
weights.ai_ml_terminology = 0.05;
weights.mathematical_notation = 0.05;
weights.statistical_terminology = 0.05;

% Calculate weighted average
total_score = 0;
total_weight = 0;

fields = fieldnames(weights);
for i = 1:length(fields)
    field = fields{i};
    if isfield(scores, field)
        total_score = total_score + scores.(field) * weights.(field);
        total_weight = total_weight + weights.(field);
    end
end

if total_weight > 0
    overall_score = total_score / total_weight;
else
    overall_score = 0;
end

% Determine quality level
if overall_score >= 0.95
    quality_level = 'Excellent';
elseif overall_score >= 0.85
    quality_level = 'Very Good';
elseif overall_score >= 0.75
    quality_level = 'Good';
elseif overall_score >= 0.60
    quality_level = 'Acceptable';
else
    quality_level = 'Needs Improvement';
end

end

function recommendations = generate_quality_recommendations(scores, issues)
% Generate quality recommendations based on scores and issues

recommendations = {};

% Technical terminology recommendations
if scores.technical_terminology < 0.8
    recommendations{end+1} = 'Review technical terminology consistency and accuracy. Ensure all Portuguese terms are properly translated to English.';
end

% Academic writing recommendations
if scores.abstract_structure < 0.8
    recommendations{end+1} = 'Improve abstract structure to include all required components: background, objective, methods, results, conclusions.';
end

if scores.academic_tone < 0.8
    recommendations{end+1} = 'Enhance academic writing tone. Use more academic connectors and ensure proper passive voice in methodology.';
end

% Completeness recommendations
if scores.translation_completeness < 0.9
    recommendations{end+1} = 'Ensure all required sections, figures, and tables are present and properly referenced.';
end

% Technical accuracy recommendations
if scores.engineering_terminology < 0.8
    recommendations{end+1} = 'Review engineering terminology accuracy, particularly for ASTM standards and structural components.';
end

if scores.ai_ml_terminology < 0.8
    recommendations{end+1} = 'Verify AI/ML terminology accuracy, especially for neural network architectures and evaluation metrics.';
end

% LaTeX recommendations
if scores.latex_integrity < 0.9
    recommendations{end+1} = 'Check LaTeX structure integrity and ensure all essential commands are properly formatted.';
end

if scores.reference_consistency < 0.9
    recommendations{end+1} = 'Fix reference consistency issues. Ensure all references have corresponding labels.';
end

% Mathematical recommendations
if scores.mathematical_notation < 0.9
    recommendations{end+1} = 'Review mathematical notation consistency and ensure equation environments are properly balanced.';
end

% Default recommendation if quality is excellent
if isempty(recommendations)
    recommendations{end+1} = 'Translation quality is excellent. Document is ready for publication.';
end

end

function report_file = generate_comprehensive_quality_report(qa_results)
% Generate comprehensive quality report

timestamp = qa_results.timestamp;
report_file = sprintf('comprehensive_quality_report_%s.txt', timestamp);

try
    fid = fopen(report_file, 'w', 'n', 'UTF-8');
    
    % Header
    fprintf(fid, 'COMPREHENSIVE TRANSLATION QUALITY ASSURANCE REPORT\n');
    fprintf(fid, '==================================================\n');
    fprintf(fid, 'Generated: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf(fid, 'Document: artigo_cientifico_corrosao.tex\n');
    fprintf(fid, 'Task: 14 - Final Quality Assurance Review\n\n');
    
    % Overall Assessment
    fprintf(fid, 'OVERALL ASSESSMENT\n');
    fprintf(fid, '==================\n');
    fprintf(fid, 'Overall Quality Score: %.1f%%\n', qa_results.overall_score * 100);
    fprintf(fid, 'Quality Level: %s\n\n', qa_results.quality_level);
    
    % Detailed Scores
    fprintf(fid, 'DETAILED QUALITY SCORES\n');
    fprintf(fid, '=======================\n');
    score_fields = fieldnames(qa_results.quality_scores);
    for i = 1:length(score_fields)
        field = score_fields{i};
        score = qa_results.quality_scores.(field);
        field_name = strrep(field, '_', ' ');
        field_name = [upper(field_name(1)), field_name(2:end)];
        fprintf(fid, '%-30s: %6.1f%%\n', field_name, score * 100);
    end
    
    % Issues Found
    fprintf(fid, '\nISSUES IDENTIFIED\n');
    fprintf(fid, '=================\n');
    issue_fields = fieldnames(qa_results.issues_found);
    issue_count = 1;
    
    for i = 1:length(issue_fields)
        field = issue_fields{i};
        field_issues = qa_results.issues_found.(field);
        
        if ~isempty(field_issues)
            fprintf(fid, '\n%s Issues:\n', strrep(field, '_', ' '));
            fprintf(fid, '%s\n', repmat('-', 1, length(field) + 8));
            for j = 1:length(field_issues)
                fprintf(fid, '%d. %s\n', issue_count, field_issues{j});
                issue_count = issue_count + 1;
            end
        end
    end
    
    % Recommendations
    fprintf(fid, '\nRECOMMENDATIONS\n');
    fprintf(fid, '===============\n');
    for i = 1:length(qa_results.recommendations)
        fprintf(fid, '%d. %s\n\n', i, qa_results.recommendations{i});
    end
    
    % Tests Performed
    fprintf(fid, 'TESTS PERFORMED\n');
    fprintf(fid, '===============\n');
    for i = 1:length(qa_results.tests_performed)
        test_name = strrep(qa_results.tests_performed{i}, '_', ' ');
        test_name = [upper(test_name(1)), test_name(2:end)];
        fprintf(fid, '✓ %s\n', test_name);
    end
    
    % Quality Criteria
    fprintf(fid, '\nQUALITY CRITERIA\n');
    fprintf(fid, '================\n');
    fprintf(fid, 'Excellent (95-100%%):     Publication ready\n');
    fprintf(fid, 'Very Good (85-94%%):      Minor revisions needed\n');
    fprintf(fid, 'Good (75-84%%):           Moderate revisions needed\n');
    fprintf(fid, 'Acceptable (60-74%%):     Major revisions needed\n');
    fprintf(fid, 'Needs Improvement (<60%%): Significant work required\n\n');
    
    % Final Assessment
    fprintf(fid, 'FINAL ASSESSMENT\n');
    fprintf(fid, '================\n');
    if qa_results.overall_score >= 0.95
        fprintf(fid, '✓ RESULT: Translation is PUBLICATION READY\n');
        fprintf(fid, 'The document meets all quality standards for international publication.\n');
    elseif qa_results.overall_score >= 0.85
        fprintf(fid, '⚠ RESULT: Translation needs MINOR REVISIONS\n');
        fprintf(fid, 'The document is of high quality but requires minor improvements.\n');
    elseif qa_results.overall_score >= 0.75
        fprintf(fid, '⚠ RESULT: Translation needs MODERATE REVISIONS\n');
        fprintf(fid, 'The document requires moderate improvements before publication.\n');
    elseif qa_results.overall_score >= 0.60
        fprintf(fid, '⚠ RESULT: Translation needs MAJOR REVISIONS\n');
        fprintf(fid, 'The document requires significant improvements before publication.\n');
    else
        fprintf(fid, '❌ RESULT: Translation needs SIGNIFICANT WORK\n');
        fprintf(fid, 'The document requires extensive revision before publication consideration.\n');
    end
    
    fprintf(fid, '\nEND OF REPORT\n');
    fprintf(fid, '=============\n');
    
    fclose(fid);
    
catch ME
    fprintf('Error generating comprehensive report: %s\n', ME.message);
    report_file = '';
end

end

function display_quality_assessment_summary(qa_results, report_file)
% Display quality assessment summary

fprintf('\n');
fprintf('================================================================\n');
fprintf('COMPREHENSIVE QUALITY ASSESSMENT SUMMARY\n');
fprintf('================================================================\n');

fprintf('Overall Quality Score: %.1f%% (%s)\n', qa_results.overall_score * 100, qa_results.quality_level);

% Count total issues
total_issues = 0;
issue_fields = fieldnames(qa_results.issues_found);
for i = 1:length(issue_fields)
    field_issues = qa_results.issues_found.(issue_fields{i});
    if iscell(field_issues)
        total_issues = total_issues + length(field_issues);
    end
end

fprintf('Total Issues Found: %d\n', total_issues);
fprintf('Recommendations: %d\n', length(qa_results.recommendations));
fprintf('Tests Performed: %d\n', length(qa_results.tests_performed));

fprintf('\nQUALITY BREAKDOWN:\n');
score_fields = fieldnames(qa_results.quality_scores);
for i = 1:length(score_fields)
    field = score_fields{i};
    score = qa_results.quality_scores.(field);
    field_name = strrep(field, '_', ' ');
    field_name = [upper(field_name(1)), field_name(2:end)];
    
    if score >= 0.9
        status = '✓ Excellent';
    elseif score >= 0.8
        status = '⚠ Good';
    elseif score >= 0.7
        status = '⚠ Acceptable';
    else
        status = '❌ Needs Work';
    end
    
    fprintf('  %-25s: %6.1f%% %s\n', field_name, score * 100, status);
end

fprintf('\nFINAL RECOMMENDATION:\n');
if qa_results.overall_score >= 0.95
    fprintf('✓ PUBLICATION READY: Document meets international standards\n');
elseif qa_results.overall_score >= 0.85
    fprintf('⚠ MINOR REVISIONS: High quality with minor improvements needed\n');
elseif qa_results.overall_score >= 0.75
    fprintf('⚠ MODERATE REVISIONS: Good quality requiring moderate improvements\n');
elseif qa_results.overall_score >= 0.60
    fprintf('⚠ MAJOR REVISIONS: Acceptable quality requiring significant improvements\n');
else
    fprintf('❌ SIGNIFICANT WORK: Extensive revision required\n');
end

fprintf('\nReport saved to: %s\n', report_file);
fprintf('================================================================\n');

end

% Utility functions

function content = read_tex_file(tex_file)
% Read LaTeX file content safely

content = '';
try
    if ~exist(tex_file, 'file')
        return;
    end
    
    fid = fopen(tex_file, 'r', 'n', 'UTF-8');
    if fid == -1
        return;
    end
    
    content = fread(fid, '*char')';
    fclose(fid);
    
catch ME
    if fid ~= -1
        fclose(fid);
    end
    content = '';
end

end

function result = merge_structs(struct1, struct2)
% Merge two structures

result = struct1;
fields = fieldnames(struct2);

for i = 1:length(fields)
    result.(fields{i}) = struct2.(fields{i});
end

end