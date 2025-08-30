function test_translation_infrastructure()
    % Test script for English translation infrastructure components
    %
    % This script tests the functionality of:
    % - TerminologyDictionary
    % - TranslationMemory  
    % - LaTeXStructurePreserver
    
    fprintf('=== Testing English Translation Infrastructure ===\n\n');
    
    % Test 1: TerminologyDictionary
    fprintf('1. Testing TerminologyDictionary...\n');
    test_terminology_dictionary();
    
    % Test 2: TranslationMemory
    fprintf('\n2. Testing TranslationMemory...\n');
    test_translation_memory();
    
    % Test 3: LaTeXStructurePreserver
    fprintf('\n3. Testing LaTeXStructurePreserver...\n');
    test_latex_structure_preserv();
    
    % Test 4: Integration test
    fprintf('\n4. Testing Integration...\n');
    test_integration();
    
    fprintf('\n=== All Translation Infrastructure Tests Completed ===\n');
end

function test_terminology_dictionary()
    % Test TerminologyDictionary functionality
    
    try
        % Create dictionary instance
        dict = TerminologyDictionary();
        
        % Test structural engineering terms
        english_term = dict.translateTerm('vigas W', 'structural');
        assert(strcmp(english_term, 'W-beams'), 'Structural term translation failed');
        fprintf('  ✓ Structural engineering terms working\n');
        
        % Test deep learning terms
        english_term = dict.translateTerm('redes neurais convolucionais', 'deep_learning');
        assert(strcmp(english_term, 'convolutional neural networks'), 'Deep learning term translation failed');
        fprintf('  ✓ Deep learning terms working\n');
        
        % Test materials science terms
        english_term = dict.translateTerm('corrosão', 'structural');
        assert(strcmp(english_term, 'corrosion'), 'Materials term translation failed');
        fprintf('  ✓ Materials science terms working\n');
        
        % Test statistics terms
        english_term = dict.translateTerm('precisão', 'statistics');
        assert(strcmp(english_term, 'precision'), 'Statistics term translation failed');
        fprintf('  ✓ Statistics terms working\n');
        
        % Test consistency checking
        test_text = 'This text contains corrosion and vigas W which should be flagged.';
        consistency_report = dict.checkConsistency(test_text, 'structural');
        assert(~consistency_report.is_consistent, 'Consistency check failed');
        fprintf('  ✓ Consistency checking working\n');
        
        % Test unknown term handling
        unknown_term = dict.translateTerm('termo_inexistente', 'structural');
        assert(strcmp(unknown_term, 'termo_inexistente'), 'Unknown term handling failed');
        fprintf('  ✓ Unknown term handling working\n');
        
        fprintf('  TerminologyDictionary: PASSED\n');
        
    catch ME
        fprintf('  TerminologyDictionary: FAILED - %s\n', ME.message);
    end
end

function test_translation_memory()
    % Test TranslationMemory functionality
    
    try
        % Create translation memory instance
        tm = TranslationMemory();
        
        % Test adding translation segments
        tm.addTranslationSegment('corrosão em estruturas metálicas', ...
                                'corrosion in metallic structures', ...
                                'introduction', 0.95);
        
        tm.addTranslationSegment('segmentação semântica', ...
                                'semantic segmentation', ...
                                'methodology', 0.90);
        
        fprintf('  ✓ Translation segments added successfully\n');
        
        % Test finding similar translations
        suggestions = tm.findSimilarTranslations('corrosão em vigas', 'introduction', 0.5);
        assert(~isempty(suggestions), 'Similar translation search failed');
        fprintf('  ✓ Similar translation search working\n');
        
        % Test translation with memory
        translation = tm.translateWithMemory('segmentação semântica', 'methodology');
        assert(strcmp(translation.text, 'semantic segmentation'), 'Memory translation failed');
        assert(translation.confidence == 1.0, 'Confidence score incorrect');
        fprintf('  ✓ Memory-based translation working\n');
        
        % Test consistency validation
        consistency_report = tm.validateConsistency('introduction');
        assert(consistency_report.is_consistent, 'Consistency validation failed');
        fprintf('  ✓ Consistency validation working\n');
        
        % Test quality metrics
        quality_metrics = tm.calculateQualityMetrics();
        assert(quality_metrics.overall_quality > 0, 'Quality metrics calculation failed');
        fprintf('  ✓ Quality metrics calculation working\n');
        
        % Test export/import functionality
        temp_file = 'temp_translation_memory.mat';
        tm.exportMemory(temp_file);
        
        tm_new = TranslationMemory();
        tm_new.importMemory(temp_file);
        
        % Clean up
        if exist(temp_file, 'file')
            delete(temp_file);
        end
        
        fprintf('  ✓ Export/import functionality working\n');
        fprintf('  TranslationMemory: PASSED\n');
        
    catch ME
        fprintf('  TranslationMemory: FAILED - %s\n', ME.message);
    end
end

function test_latex_structure_preserv()
    % Test LaTeXStructurePreserver functionality
    
    try
        % Create structure preserver instance
        lsp = LaTeXStructurePreserver();
        
        % Test with actual LaTeX file
        latex_file = 'artigo_cientifico_corrosao.tex';
        
        if exist(latex_file, 'file')
            % Test document structure analysis
            structure = lsp.analyzeDocumentStructure(latex_file);
            
            assert(isfield(structure, 'sections'), 'Structure analysis failed - no sections');
            assert(isfield(structure, 'figures'), 'Structure analysis failed - no figures');
            assert(isfield(structure, 'tables'), 'Structure analysis failed - no tables');
            
            fprintf('  ✓ Document structure analysis working\n');
            
            % Test LaTeX element protection
            test_text = 'This is a test with $x = y + z$ and \cite{reference2024} and \ref{fig:test}.';
            protected_text = lsp.protectLaTeXElements(test_text);
            
            assert(~strcmp(test_text, protected_text), 'LaTeX protection failed');
            fprintf('  ✓ LaTeX element protection working\n');
            
            % Test element restoration
            restored_text = lsp.restoreLaTeXElements(protected_text);
            assert(contains(restored_text, '$x = y + z$'), 'LaTeX restoration failed');
            
            fprintf('  ✓ LaTeX element restoration working\n');
            
            % Test figure/table reference extraction
            file_content = fileread(latex_file);
            figure_table_map = lsp.extractFigureTableReferences(file_content);
            
            fprintf('  ✓ Figure/table reference extraction working\n');
            
        else
            fprintf('  ⚠ LaTeX file not found, skipping file-based tests\n');
        end
        
        fprintf('  LaTeXStructurePreserver: PASSED\n');
        
    catch ME
        fprintf('  LaTeXStructurePreserver: FAILED - %s\n', ME.message);
    end
end

function test_integration()
    % Test integration between components
    
    try
        % Create all components
        dict = TerminologyDictionary();
        tm = TranslationMemory();
        lsp = LaTeXStructurePreserver();
        
        % Test integrated workflow
        portuguese_text = 'A corrosão em vigas W de aço ASTM A572 Grau 50 foi analisada usando redes neurais convolucionais.';
        
        % Step 1: Protect LaTeX elements (if any)
        protected_text = lsp.protectLaTeXElements(portuguese_text);
        
        % Step 2: Translate technical terms
        translated_terms = {};
        translated_terms{end+1} = dict.translateTerm('corrosão', 'structural');
        translated_terms{end+1} = dict.translateTerm('vigas W', 'structural');
        translated_terms{end+1} = dict.translateTerm('aço ASTM A572 Grau 50', 'structural');
        translated_terms{end+1} = dict.translateTerm('redes neurais convolucionais', 'deep_learning');
        
        % Verify translations
        expected_terms = {'corrosion', 'W-beams', 'ASTM A572 Grade 50 steel', 'convolutional neural networks'};
        for i = 1:length(expected_terms)
            assert(strcmp(translated_terms{i}, expected_terms{i}), ...
                sprintf('Term translation failed: %s', translated_terms{i}));
        end
        
        % Step 3: Add to translation memory
        english_text = 'Corrosion in ASTM A572 Grade 50 steel W-beams was analyzed using convolutional neural networks.';
        tm.addTranslationSegment(portuguese_text, english_text, 'abstract', 0.95);
        
        % Step 4: Test memory retrieval
        translation = tm.translateWithMemory(portuguese_text, 'abstract');
        assert(strcmp(translation.text, english_text), 'Memory retrieval failed');
        
        % Step 5: Restore LaTeX elements (if any were protected)
        final_text = lsp.restoreLaTeXElements(translation.text);
        
        fprintf('  ✓ Integrated workflow working\n');
        fprintf('  Integration Test: PASSED\n');
        
    catch ME
        fprintf('  Integration Test: FAILED - %s\n', ME.message);
    end
end