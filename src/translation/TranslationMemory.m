classdef TranslationMemory < handle
    % TranslationMemory - Manages Portuguese-English translation mappings
    % for scientific articles with context-aware translation suggestions
    %
    % This class provides translation memory functionality to maintain
    % consistency across document sections and track translation quality.
    
    properties (Access = private)
        translation_segments
        context_mappings
        quality_scores
        terminology_dict
        consistency_rules
        translation_history
    end
    
    methods
        function obj = TranslationMemory()
            % Constructor - Initialize translation memory system
            obj.translation_segments = containers.Map();
            obj.context_mappings = containers.Map();
            obj.quality_scores = containers.Map();
            obj.terminology_dict = TerminologyDictionary();
            obj.consistency_rules = obj.initializeConsistencyRules();
            obj.translation_history = {};
        end
        
        function addTranslationSegment(obj, portuguese_text, english_text, context, quality_score)
            % Add a translation segment to memory
            %
            % Args:
            %   portuguese_text (string): Original Portuguese text
            %   english_text (string): English translation
            %   context (string): Section context ('abstract', 'introduction', etc.)
            %   quality_score (double): Quality score (0-1)
            
            segment_id = obj.generateSegmentId(portuguese_text);
            
            segment_data.portuguese = portuguese_text;
            segment_data.english = english_text;
            segment_data.context = context;
            segment_data.timestamp = datetime('now');
            segment_data.quality_score = quality_score;
            
            obj.translation_segments(segment_id) = segment_data;
            obj.quality_scores(segment_id) = quality_score;
            
            % Update context mappings
            if isKey(obj.context_mappings, context)
                context_segments = obj.context_mappings(context);
                context_segments{end+1} = segment_id;
                obj.context_mappings(context) = context_segments;
            else
                obj.context_mappings(context) = {segment_id};
            end
            
            % Add to history
            obj.translation_history{end+1} = segment_data;
        end
        
        function suggestions = findSimilarTranslations(obj, portuguese_text, context, similarity_threshold)
            % Find similar translations in memory
            %
            % Args:
            %   portuguese_text (string): Text to find translations for
            %   context (string): Current section context
            %   similarity_threshold (double): Minimum similarity score (0-1)
            %
            % Returns:
            %   suggestions (cell array): Array of similar translation suggestions
            
            if nargin < 4
                similarity_threshold = 0.7;
            end
            
            suggestions = {};
            segment_ids = keys(obj.translation_segments);
            
            for i = 1:length(segment_ids)
                segment_id = segment_ids{i};
                segment_data = obj.translation_segments(segment_id);
                
                % Calculate similarity score
                similarity = obj.calculateTextSimilarity(portuguese_text, segment_data.portuguese);
                
                % Check context relevance
                context_bonus = 0;
                if strcmp(segment_data.context, context)
                    context_bonus = 0.1;
                end
                
                total_score = similarity + context_bonus;
                
                if total_score >= similarity_threshold
                    suggestion.portuguese = segment_data.portuguese;
                    suggestion.english = segment_data.english;
                    suggestion.context = segment_data.context;
                    suggestion.similarity_score = similarity;
                    suggestion.quality_score = segment_data.quality_score;
                    suggestion.total_score = total_score;
                    
                    suggestions{end+1} = suggestion;
                end
            end
            
            % Sort by total score (descending)
            if ~isempty(suggestions)
                scores = cellfun(@(x) x.total_score, suggestions);
                [~, sort_idx] = sort(scores, 'descend');
                suggestions = suggestions(sort_idx);
            end
        end
        
        function translation = translateWithMemory(obj, portuguese_text, context)
            % Translate text using memory and terminology dictionary
            %
            % Args:
            %   portuguese_text (string): Portuguese text to translate
            %   context (string): Section context
            %
            % Returns:
            %   translation (struct): Translation result with confidence score
            
            % First, check for exact matches
            exact_match = obj.findExactMatch(portuguese_text);
            if ~isempty(exact_match)
                translation.text = exact_match.english;
                translation.confidence = 1.0;
                translation.source = 'exact_match';
                translation.context = exact_match.context;
                return;
            end
            
            % Look for similar translations
            suggestions = obj.findSimilarTranslations(portuguese_text, context, 0.8);
            
            if ~isempty(suggestions)
                best_suggestion = suggestions{1};
                translation.text = obj.adaptTranslation(portuguese_text, best_suggestion);
                translation.confidence = best_suggestion.total_score;
                translation.source = 'similarity_match';
                translation.context = context;
            else
                % Use terminology dictionary for technical terms
                translation.text = obj.translateWithTerminology(portuguese_text, context);
                translation.confidence = 0.5;
                translation.source = 'terminology_dict';
                translation.context = context;
            end
        end
        
        function consistency_report = validateConsistency(obj, context)
            % Validate translation consistency within a context
            %
            % Args:
            %   context (string): Section context to validate
            %
            % Returns:
            %   consistency_report (struct): Consistency validation report
            
            if ~isKey(obj.context_mappings, context)
                consistency_report.is_consistent = true;
                consistency_report.issues = {};
                consistency_report.suggestions = {};
                return;
            end
            
            segment_ids = obj.context_mappings(context);
            issues = {};
            suggestions = {};
            
            % Check terminology consistency
            for i = 1:length(segment_ids)
                segment_data = obj.translation_segments(segment_ids{i});
                
                % Check against consistency rules
                rule_violations = obj.checkConsistencyRules(segment_data.portuguese, segment_data.english);
                if ~isempty(rule_violations)
                    issues = [issues, rule_violations];
                end
                
                % Check terminology usage
                term_issues = obj.terminology_dict.checkConsistency(segment_data.english, 'academic');
                if ~term_issues.is_consistent
                    issues = [issues, term_issues.inconsistencies];
                end
            end
            
            consistency_report.is_consistent = isempty(issues);
            consistency_report.issues = issues;
            consistency_report.suggestions = suggestions;
            consistency_report.context = context;
            consistency_report.segments_checked = length(segment_ids);
        end
        
        function quality_metrics = calculateQualityMetrics(obj)
            % Calculate overall translation quality metrics
            %
            % Returns:
            %   quality_metrics (struct): Quality assessment metrics
            
            segment_ids = keys(obj.translation_segments);
            
            if isempty(segment_ids)
                quality_metrics.overall_quality = 0;
                quality_metrics.consistency_score = 0;
                quality_metrics.coverage_score = 0;
                quality_metrics.total_segments = 0;
                return;
            end
            
            % Calculate average quality score
            quality_scores = cellfun(@(id) obj.quality_scores(id), segment_ids);
            quality_metrics.overall_quality = mean(quality_scores);
            
            % Calculate consistency score across contexts
            contexts = unique(values(obj.context_mappings));
            consistency_scores = [];
            
            for i = 1:length(contexts)
                context = contexts{i};
                consistency_report = obj.validateConsistency(context);
                if consistency_report.is_consistent
                    consistency_scores(end+1) = 1.0;
                else
                    consistency_scores(end+1) = max(0, 1.0 - length(consistency_report.issues) * 0.1);
                end
            end
            
            quality_metrics.consistency_score = mean(consistency_scores);
            quality_metrics.coverage_score = obj.calculateCoverageScore();
            quality_metrics.total_segments = length(segment_ids);
            quality_metrics.contexts_covered = length(contexts);
        end
        
        function exportMemory(obj, filename)
            % Export translation memory to file
            %
            % Args:
            %   filename (string): Output filename
            
            memory_data.segments = obj.translation_segments;
            memory_data.context_mappings = obj.context_mappings;
            memory_data.quality_scores = obj.quality_scores;
            memory_data.consistency_rules = obj.consistency_rules;
            memory_data.export_timestamp = datetime('now');
            
            save(filename, 'memory_data');
            fprintf('Translation memory exported to: %s\n', filename);
        end
        
        function importMemory(obj, filename)
            % Import translation memory from file
            %
            % Args:
            %   filename (string): Input filename
            
            if exist(filename, 'file')
                loaded_data = load(filename);
                memory_data = loaded_data.memory_data;
                
                obj.translation_segments = memory_data.segments;
                obj.context_mappings = memory_data.context_mappings;
                obj.quality_scores = memory_data.quality_scores;
                obj.consistency_rules = memory_data.consistency_rules;
                
                fprintf('Translation memory imported from: %s\n', filename);
            else
                error('Translation memory file not found: %s', filename);
            end
        end
    end
    
    methods (Access = private)
        function segment_id = generateSegmentId(obj, text)
            % Generate unique ID for translation segment
            text_hash = string(java.lang.String(text).hashCode());
            timestamp = string(posixtime(datetime('now')));
            segment_id = strcat('seg_', text_hash, '_', timestamp);
        end
        
        function similarity = calculateTextSimilarity(obj, text1, text2)
            % Calculate similarity between two texts using Jaccard similarity
            
            % Simple tokenization (split by spaces and punctuation)
            tokens1 = obj.tokenizeText(text1);
            tokens2 = obj.tokenizeText(text2);
            
            % Calculate Jaccard similarity
            intersection = length(intersect(tokens1, tokens2));
            union = length(union(tokens1, tokens2));
            
            if union == 0
                similarity = 0;
            else
                similarity = intersection / union;
            end
        end
        
        function tokens = tokenizeText(obj, text)
            % Simple text tokenization
            text = lower(text);
            text = regexprep(text, '[^\w\s]', ' '); % Remove punctuation
            tokens = strsplit(text);
            tokens = tokens(~cellfun('isempty', tokens)); % Remove empty tokens
        end
        
        function exact_match = findExactMatch(obj, portuguese_text)
            % Find exact match in translation memory
            segment_ids = keys(obj.translation_segments);
            exact_match = [];
            
            for i = 1:length(segment_ids)
                segment_data = obj.translation_segments(segment_ids{i});
                if strcmp(segment_data.portuguese, portuguese_text)
                    exact_match = segment_data;
                    return;
                end
            end
        end
        
        function adapted_translation = adaptTranslation(obj, portuguese_text, suggestion)
            % Adapt a similar translation to the current text
            % For now, return the suggestion as-is
            % In a more sophisticated implementation, this could use
            % edit distance algorithms to adapt the translation
            adapted_translation = suggestion.english;
        end
        
        function translation = translateWithTerminology(obj, portuguese_text, context)
            % Translate using terminology dictionary
            translation = portuguese_text; % Default fallback
            
            % Try different domains based on context
            domains = {'academic', 'structural', 'deep_learning', 'materials', 'statistics'};
            
            for i = 1:length(domains)
                try
                    translated = obj.terminology_dict.translateTerm(portuguese_text, domains{i});
                    if ~strcmp(translated, portuguese_text)
                        translation = translated;
                        return;
                    end
                catch
                    continue;
                end
            end
        end
        
        function violations = checkConsistencyRules(obj, portuguese_text, english_text)
            % Check translation against consistency rules
            violations = {};
            
            % Check each rule
            rule_names = fieldnames(obj.consistency_rules);
            for i = 1:length(rule_names)
                rule_name = rule_names{i};
                rule = obj.consistency_rules.(rule_name);
                
                if rule.check_function(portuguese_text, english_text)
                    violations{end+1} = sprintf('Rule violation: %s - %s', rule_name, rule.description);
                end
            end
        end
        
        function coverage_score = calculateCoverageScore(obj)
            % Calculate how well the memory covers different contexts
            expected_contexts = {'abstract', 'introduction', 'methodology', 'results', 'discussion', 'conclusions'};
            covered_contexts = keys(obj.context_mappings);
            
            coverage_score = length(intersect(expected_contexts, covered_contexts)) / length(expected_contexts);
        end
        
        function rules = initializeConsistencyRules(obj)
            % Initialize consistency checking rules
            rules = struct();
            
            % Rule 1: No Portuguese technical terms in English text
            rules.no_portuguese_terms.description = 'English text should not contain Portuguese technical terms';
            rules.no_portuguese_terms.check_function = @(pt, en) obj.containsPortugueseTerms(en);
            
            % Rule 2: Consistent abbreviation usage
            rules.consistent_abbreviations.description = 'Abbreviations should be used consistently';
            rules.consistent_abbreviations.check_function = @(pt, en) obj.checkAbbreviationConsistency(en);
            
            % Rule 3: Proper capitalization
            rules.proper_capitalization.description = 'Technical terms should have proper capitalization';
            rules.proper_capitalization.check_function = @(pt, en) obj.checkCapitalization(en);
        end
        
        function has_portuguese = containsPortugueseTerms(obj, english_text)
            % Check if English text contains Portuguese terms
            portuguese_indicators = {'ção', 'são', 'ões', 'ão', 'ê', 'ô', 'ã', 'õ'};
            has_portuguese = false;
            
            for i = 1:length(portuguese_indicators)
                if contains(english_text, portuguese_indicators{i})
                    has_portuguese = true;
                    return;
                end
            end
        end
        
        function inconsistent = checkAbbreviationConsistency(obj, english_text)
            % Check abbreviation consistency (placeholder implementation)
            inconsistent = false;
            % Implementation would check for consistent abbreviation usage
        end
        
        function improper = checkCapitalization(obj, english_text)
            % Check proper capitalization (placeholder implementation)
            improper = false;
            % Implementation would check for proper technical term capitalization
        end
    end
end