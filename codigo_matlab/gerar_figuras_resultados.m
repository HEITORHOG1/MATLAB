% gerar_figuras_resultados.m - Master script to generate all results figures
%
% This script generates all figures needed for the Results section (Section 3)
% of the classification article.
%
% Requirements: Task 5 - Write results section
%
% Figures generated:
%   - figura_matrizes_confusao.pdf (Task 5.2)
%   - figura_curvas_treinamento.pdf (Task 5.3)
%   - figura_comparacao_tempo_inferencia.pdf (Task 5.4)
%
% All figures are saved to figuras_classificacao/ directory

function gerar_figuras_resultados()
    fprintf('=================================================================\n');
    fprintf('Generating Results Section Figures for Classification Article\n');
    fprintf('=================================================================\n\n');
    
    % Create output directory
    if ~exist('figuras_classificacao', 'dir')
        mkdir('figuras_classificacao');
        fprintf('Created directory: figuras_classificacao/\n\n');
    end
    
    % Generate confusion matrices figure
    fprintf('1. Generating confusion matrices figure...\n');
    try
        gerar_figura_matrizes_confusao();
        fprintf('   ✓ Success\n\n');
    catch ME
        fprintf('   ✗ Error: %s\n\n', ME.message);
    end
    
    % Generate training curves figure
    fprintf('2. Generating training curves figure...\n');
    try
        gerar_figura_curvas_treinamento();
        fprintf('   ✓ Success\n\n');
    catch ME
        fprintf('   ✗ Error: %s\n\n', ME.message);
    end
    
    % Generate inference time comparison figure
    fprintf('3. Generating inference time comparison figure...\n');
    try
        gerar_figura_comparacao_tempo_inferencia();
        fprintf('   ✓ Success\n\n');
    catch ME
        fprintf('   ✗ Error: %s\n\n', ME.message);
    end
    
    fprintf('=================================================================\n');
    fprintf('Figure Generation Complete\n');
    fprintf('=================================================================\n\n');
    
    % List generated files
    fprintf('Generated files in figuras_classificacao/:\n');
    files = dir(fullfile('figuras_classificacao', '*.pdf'));
    for i = 1:length(files)
        fprintf('  - %s\n', files(i).name);
    end
    fprintf('\n');
    
    fprintf('Next steps:\n');
    fprintf('  1. Review the generated figures\n');
    fprintf('  2. Compile the LaTeX article: compile_artigo_classificacao.bat\n');
    fprintf('  3. Check that all figures appear correctly in the PDF\n');
    fprintf('\n');
end
