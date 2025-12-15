function executar_qa_completa_final()
% EXECUTAR_QA_COMPLETA_FINAL - Comprehensive Quality Assurance for English Translation
% Performs final quality review of the translated scientific article
% 
% This function implements Task 14: Perform final quality assurance review
% - Execute comprehensive translation quality tests
% - Verify academic writing quality meets English standards  
% - Check technical accuracy of all translated content
% - Generate translation quality report

    fprintf('=== COMPREHENSIVE QUALITY ASSURANCE REVIEW ===\n');
    fprintf('English Translation Final Quality Assessment\n');
    fprintf('Generated: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    
    % Initialize quality assessment structure
    qa_results = struct();
    qa_results.timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    qa_results.tests_performed = {};
    qa_results.quality_scores = struct();
    qa_results.issues_found = {};
    qa_results.recommendations = {};
    
    % Define file paths
    tex_file = 'artigo_cientifico_corrosao.tex';
    
    try
        % Test 1: Technical Terminology Accuracy
        fprintf('1. Testing Technical Terminology Accuracy...\n');
        [term_score, term_issues] = test_technical_terminology(tex_file);
        qa_results.quality_scores.technical_terminology = term_score;
        qa_results.issues_found.terminology = term_issues;
        qa_results.tests_performed{end+1} = 'technical_terminology_accuracy';
        fprintf('   Score: %.1f%%\n', term_score * 100);
        
        % Test 2: Academic Writing Quality
        fprintf('2. Testing Academic Writing Quality...\n');
        [writing_score, writing_issues] = test_academic_writing_quality(tex_file);
        qa_results.quality_scores.academic_writing = writing_score;
        qa_results.issues_found.academic_writing = writing_issues;
        qa_results.tests_performed{end+1} = 'academic_writing_quality';
        fprintf('   Score: %.1f%%\n', writing_score * 100);
        
        % Test 3: Translation Completeness
        fprintf('3. Testing Translation Completeness...\n');
        [complete_score, complete_issues] = test_translation_completeness(tex_file);
        qa_results.quality_scores.completeness = complete_score;
        qa_results.issues_found.completeness = complete_issues;
        qa_results.tests_performed{end+1} = 'translation_completeness';
        fprintf('   Score: %.1f%%\n', complete_score * 100);
        
        % Test 4: LaTeX Structure Integrity
        fprintf('4. Testing LaTeX Structure Integrity...\n');
        [latex_score, latex_issues] = test_latex_integrity(tex_file);
        qa_results.quality_scores.latex_integrity = latex_score;
        qa_results.issues_found.latex_integrity = latex_issues;
        qa_results.tests_performed{end+1} = 'latex_integrity';
        fprintf('   Score: %.1f%%\n', latex_score * 100);
        
        % Test 5: LaTeX Compilation Test
        fprintf('5. Testing LaTeX Compilation...\n');
        [compile_score, compile_issues] = test_latex_compilation(tex_file);
        qa_results.quality_scores.latex_compilation = compile_score;
        qa_results.issues_found.latex_compilation = compile_issues;
        qa_results.tests_performed{end+1} = 'latex_compilation';
        fprintf('   Score: %.1f%%\n', compile_score * 100);
        
        % Calculate Overall Quality Score
        [overall_score, quality_level] = calculate_overall_quality_score(qa_results.quality_scores);
        qa_results.overall_score = overall_score;
        qa_results.quality_level = quality_level;
        
        % Generate Recommendations
        qa_results.recommendations = generate_quality_recommendations(qa_results.quality_scores);
        
        % Generate Comprehensive Report
        report_file = generate_comprehensive_quality_report(qa_results);
        
        % Display Summary
        fprintf('\n=== QUALITY ASSESSMENT SUMMARY ===\n');
        fprintf('Overall Quality Score: %.1f%% (%s)\n', overall_score * 100, quality_level);
        fprintf('Total Issues Found: %d\n', count_total_issues(qa_results.issues_found));
        fprintf('Recommendations: %d\n', length(qa_results.recommendations));
        fprintf('Report saved to: %s\n', report_file);
        
        % Display Quality Level Interpretation
        fprintf('\n=== QUALITY LEVEL INTERPRETATION ===\n');
        fprintf('Excellent (95-100%%): Publication ready\n');
        fprintf('Very Good (85-94%%): Minor revisions needed\n');
        fprintf('Good (75-84%%): Moderate revisions needed\n');
        fprintf('Acceptable (60-74%%): Major revisions needed\n');
        fprintf('Needs Improvement (<60%%): Significant work required\n');
        
        if overall_score >= 0.95
            fprintf('\n✓ RESULT: Translation is PUBLICATION READY\n');
        elseif overall_score >= 0.85
            fprintf('\n⚠ RESULT: Translation needs MINOR REVISIONS\n');
        elseif overall_score >= 0.75
            fprintf('\n⚠ RESULT: Translation needs MODERATE REVISIONS\n');
        elseif overall_score >= 0.60
            fprintf('\n⚠ RESULT: Translation needs MAJOR REVISIONS\n');
        else
            fprintf('\n❌ RESULT: Translation needs SIGNIFICANT WORK\n');
        end
        
        fprintf('\nComprehensive Quality Assurance Review Completed Successfully.\n');
        
    catch ME
        fprintf('ERROR in Quality Assurance Review: %s\n', ME.message);
        fprintf('File: %s, Line: %d\n', ME.stack(1).file, ME.stack(1).line);
    end
end

function [score, issues] = test_technical_terminology(tex_file)
% Test technical terminology accuracy and consistency
    
    issues = {};
    
    try
        % Read LaTeX file
        content = fileread(tex_file);
        content_lower = lower(content);
        
        % Define technical terms that should be present (English)
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
            'aprendizado', 'rede neural', 'convolucional'
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
        
        % Penalize for Portuguese terms
        if portuguese_found > 0
            penalty = min(portuguese_found * 0.1, 0.5); % Max 50% penalty
            score = max(0, base_score - penalty);
        else
            score = base_score;
        end
        
    catch ME
        issues{end+1} = sprintf('Error reading file: %s', ME.message);
        score = 0;
    end
end

function [score, issues] = test_academic_writing_quality(tex_file)
% Test academic writing quality and conventions
    
    issues = {};
    
    try
        content = fileread(tex_file);
        content_lower = lower(content);
        
        quality_indicators = 0;
        total_checks = 0;
        
        % Check abstract structure
        abstract_pattern = '\\begin{abstract}(.*?)\\end{abstract}';
        abstract_match = regexp(content, abstract_pattern, 'tokens', 'dotexceptnewline');
        
        if ~isempty(abstract_match)
            abstract_text = lower(abstract_match{1}{1});
            abstract_indicators = {'background', 'objective', 'method', 'result', 'conclusion'};
            abstract_score = 0;
            
            for i = 1:length(abstract_indicators)
                if contains(abstract_text, abstract_indicators{i})
                    abstract_score = abstract_score + 1;
                end
            end
            
            quality_indicators = quality_indicators + (abstract_score / length(abstract_indicators));
            total_checks = total_checks + 1;
        else
            issues{end+1} = 'Abstract section not found or improperly formatted';
        end
        
        % Check methodology passive voice
        methodology_pattern = '\\section\{.*?methodology.*?\}(.*?)(?=\\section|$)';
        methodology_match = regexp(content_lower, methodology_pattern, 'tokens', 'dotexceptnewline');
        
        if ~isempty(methodology_match)
            methodology_text = methodology_match{1}{1};
            passive_indicators = {'was performed', 'were conducted', 'was implemented', 'was used'};
            passive_count = 0;
            
            for i = 1:length(passive_indicators)
                if contains(methodology_text, passive_indicators{i})
                    passive_count = passive_count + 1;
                end
            end
            
            if passive_count > 0
                quality_indicators = quality_indicators + min(passive_count / 3, 1.0);
            end
            total_checks = total_checks + 1;
        else
            issues{end+1} = 'Methodology section not found';
        end
        
        % Check statistical terminology in results
        results_pattern = '\\section\{.*?result.*?\}(.*?)(?=\\section|$)';
        results_match = regexp(content_lower, results_pattern, 'tokens', 'dotexceptnewline');
        
        if ~isempty(results_match)
            results_text = results_match{1}{1};
            stats_terms = {'p <', 'confidence interval', 'standard deviation', 'significant'};
            stats_count = 0;
            
            for i = 1:length(stats_terms)
                if contains(results_text, stats_terms{i})
                    stats_count = stats_count + 1;
                end
            end
            
            if stats_count > 0
                quality_indicators = quality_indicators + min(stats_count / 2, 1.0);
            end
            total_checks = total_checks + 1;
        else
            issues{end+1} = 'Results section not found';
        end
        
        % Calculate score
        if total_checks > 0
            score = quality_indicators / total_checks;
        else
            score = 0;
            issues{end+1} = 'No academic sections found for quality assessment';
        end
        
    catch ME
        issues{end+1} = sprintf('Error in academic writing test: %s', ME.message);
        score = 0;
    end
end

function [score, issues] = test_translation_completeness(tex_file)
% Test translation completeness and content preservation
    
    issues = {};
    
    try
        content = fileread(tex_file);
        
        completeness_score = 0;
        total_sections = 0;
        
        % Required sections
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

function [score, issues] = test_latex_integrity(tex_file)
% Test LaTeX structure integrity
    
    issues = {};
    
    try
        content = fileread(tex_file);
        
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

function [score, issues] = test_latex_compilation(tex_file)
% Test LaTeX compilation
    
    issues = {};
    
    try
        % Check if pdflatex is available
        [status, ~] = system('pdflatex --version');
        
        if status ~= 0
            issues{end+1} = 'pdflatex not found - LaTeX not installed or not in PATH';
            score = 0;
            return;
        end
        
        % Attempt compilation
        compile_cmd = sprintf('pdflatex -interaction=nonstopmode "%s"', tex_file);
        [status, output] = system(compile_cmd);
        
        if status == 0
            score = 1.0;
            fprintf('   LaTeX compilation successful\n');
        else
            score = 0;
            issues{end+1} = 'LaTeX compilation failed';
            issues{end+1} = sprintf('Compilation output: %s', output);
        end
        
    catch ME
        issues{end+1} = sprintf('Error in LaTeX compilation test: %s', ME.message);
        score = 0;
    end
end

function [overall_score, quality_level] = calculate_overall_quality_score(scores)
% Calculate overall quality score with weighted average
    
    % Define weights for different aspects
    weights = struct();
    weights.technical_terminology = 0.25;
    weights.academic_writing = 0.25;
    weights.completeness = 0.20;
    weights.latex_integrity = 0.15;
    weights.latex_compilation = 0.15;
    
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

function recommendations = generate_quality_recommendations(scores)
% Generate recommendations based on quality scores
    
    recommendations = {};
    
    if scores.technical_terminology < 0.8
        recommendations{end+1} = 'Review technical terminology consistency and accuracy. Ensure all Portuguese terms are properly translated.';
    end
    
    if scores.academic_writing < 0.8
        recommendations{end+1} = 'Improve academic writing quality. Check abstract structure, use appropriate passive voice in methodology, and include proper statistical terminology in results.';
    end
    
    if scores.completeness < 0.9
        recommendations{end+1} = 'Ensure all required sections, figures, and tables are present and properly referenced in the translated document.';
    end
    
    if scores.latex_integrity < 0.9
        recommendations{end+1} = 'Check LaTeX structure integrity. Ensure all essential commands and environments are properly formatted.';
    end
    
    if scores.latex_compilation < 1.0
        recommendations{end+1} = 'Fix LaTeX compilation issues. Check for syntax errors, missing packages, or formatting problems.';
    end
    
    if isempty(recommendations)
        recommendations{end+1} = 'Translation quality is excellent. Document is ready for publication.';
    end
end

function total_issues = count_total_issues(issues_struct)
% Count total number of issues across all categories
    
    total_issues = 0;
    fields = fieldnames(issues_struct);
    
    for i = 1:length(fields)
        field_issues = issues_struct.(fields{i});
        if iscell(field_issues)
            total_issues = total_issues + length(field_issues);
        end
    end
end

function report_file = generate_comprehensive_quality_report(qa_results)
% Generate comprehensive quality report
    
    timestamp = qa_results.timestamp;
    report_file = sprintf('translation_quality_report_%s.txt', timestamp);
    
    try
        fid = fopen(report_file, 'w', 'n', 'UTF-8');
        
        % Header
        fprintf(fid, 'COMPREHENSIVE TRANSLATION QUALITY ASSURANCE REPORT\n');
        fprintf(fid, '============================================================\n');
        fprintf(fid, 'Generated: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
        fprintf(fid, 'Document: artigo_cientifico_corrosao.tex\n\n');
        
        % Overall Assessment
        fprintf(fid, 'OVERALL ASSESSMENT\n');
        fprintf(fid, '------------------------------\n');
        fprintf(fid, 'Overall Quality Score: %.1f%%\n', qa_results.overall_score * 100);
        fprintf(fid, 'Quality Level: %s\n\n', qa_results.quality_level);
        
        % Detailed Scores
        fprintf(fid, 'DETAILED SCORES\n');
        fprintf(fid, '------------------------------\n');
        score_fields = fieldnames(qa_results.quality_scores);
        for i = 1:length(score_fields)
            field = score_fields{i};
            score = qa_results.quality_scores.(field);
            field_name = strrep(field, '_', ' ');
            field_name = [upper(field_name(1)), field_name(2:end)];
            fprintf(fid, '%s: %.1f%%\n', field_name, score * 100);
        end
        
        % Issues Found
        fprintf(fid, '\nISSUES IDENTIFIED\n');
        fprintf(fid, '------------------------------\n');
        issue_fields = fieldnames(qa_results.issues_found);
        issue_count = 1;
        
        for i = 1:length(issue_fields)
            field = issue_fields{i};
            field_issues = qa_results.issues_found.(field);
            
            if ~isempty(field_issues)
                fprintf(fid, '\n%s Issues:\n', strrep(field, '_', ' '));
                for j = 1:length(field_issues)
                    fprintf(fid, '%d. %s\n', issue_count, field_issues{j});
                    issue_count = issue_count + 1;
                end
            end
        end
        
        % Recommendations
        fprintf(fid, '\nRECOMMENDATIONS\n');
        fprintf(fid, '------------------------------\n');
        for i = 1:length(qa_results.recommendations)
            fprintf(fid, '%d. %s\n', i, qa_results.recommendations{i});
        end
        
        % Tests Performed
        fprintf(fid, '\nTESTS PERFORMED\n');
        fprintf(fid, '------------------------------\n');
        for i = 1:length(qa_results.tests_performed)
            test_name = strrep(qa_results.tests_performed{i}, '_', ' ');
            test_name = [upper(test_name(1)), test_name(2:end)];
            fprintf(fid, '✓ %s\n', test_name);
        end
        
        % Quality Criteria
        fprintf(fid, '\nQUALITY CRITERIA\n');
        fprintf(fid, '------------------------------\n');
        fprintf(fid, 'Excellent (95-100%%): Publication ready\n');
        fprintf(fid, 'Very Good (85-94%%): Minor revisions needed\n');
        fprintf(fid, 'Good (75-84%%): Moderate revisions needed\n');
        fprintf(fid, 'Acceptable (60-74%%): Major revisions needed\n');
        fprintf(fid, 'Needs Improvement (<60%%): Significant work required\n\n');
        
        fprintf(fid, 'END OF REPORT\n');
        
        fclose(fid);
        
    catch ME
        fprintf('Error generating report: %s\n', ME.message);
        report_file = '';
    end
end