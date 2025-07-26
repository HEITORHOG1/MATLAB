function criar_estrutura_diretorios()
% CRIAR_ESTRUTURA_DIRETORIOS - Cria a estrutura organizacional de diretórios
%
% Esta função implementa a estrutura de diretórios conforme especificado
% no documento de design do sistema de comparação U-Net vs Attention U-Net.
%
% Referência: Tutorial MATLAB File Management
% https://www.mathworks.com/help/matlab/ref/mkdir.html

    fprintf('=== CRIANDO ESTRUTURA DE DIRETÓRIOS ===\n\n');
    
    % Definir estrutura de diretórios conforme design
    diretorios = {
        'src',
        'src/core',
        'src/data', 
        'src/models',
        'src/evaluation',
        'src/visualization',
        'src/utils',
        'tests',
        'tests/unit',
        'tests/integration', 
        'tests/performance',
        'docs',
        'docs/examples',
        'config',
        'output',
        'output/models',
        'output/reports',
        'output/visualizations'
    };
    
    % Criar diretórios
    fprintf('Criando diretórios:\n');
    for i = 1:length(diretorios)
        dir_path = diretorios{i};
        
        if ~exist(dir_path, 'dir')
            mkdir(dir_path);
            fprintf('  ✓ %s\n', dir_path);
        else
            fprintf('  → %s (já existe)\n', dir_path);
        end
    end
    
    fprintf('\n=== ESTRUTURA CRIADA COM SUCESSO ===\n');
    
    % Criar arquivos README.md para cada diretório principal
    criar_readmes();
end

function criar_readmes()
% Criar arquivos README.md explicando o propósito de cada diretório
    
    fprintf('\nCriando arquivos README.md explicativos:\n');
    
    % README para src/
    readme_src = sprintf(['# Código Fonte\n\n' ...
        'Este diretório contém todo o código fonte do sistema de comparação U-Net vs Attention U-Net.\n\n' ...
        '## Estrutura\n\n' ...
        '- **core/**: Componentes principais do sistema (interface, controladores)\n' ...
        '- **data/**: Módulos de carregamento e preprocessamento de dados\n' ...
        '- **models/**: Arquiteturas de modelos e treinamento\n' ...
        '- **evaluation/**: Cálculo de métricas e análises estatísticas\n' ...
        '- **visualization/**: Geração de gráficos e relatórios\n' ...
        '- **utils/**: Utilitários e funções auxiliares\n']);
    
    escrever_readme('src/README.md', readme_src);
    
    % README para tests/
    readme_tests = sprintf(['# Testes\n\n' ...
        'Este diretório contém todos os testes do sistema.\n\n' ...
        '## Estrutura\n\n' ...
        '- **unit/**: Testes unitários para funções individuais\n' ...
        '- **integration/**: Testes de integração entre componentes\n' ...
        '- **performance/**: Testes de performance e benchmarks\n\n' ...
        '## Execução\n\n' ...
        'Execute `TestSuite.runAllTests()` para executar todos os testes.\n']);
    
    escrever_readme('tests/README.md', readme_tests);
    
    % README para docs/
    readme_docs = sprintf(['# Documentação\n\n' ...
        'Este diretório contém toda a documentação do sistema.\n\n' ...
        '## Arquivos\n\n' ...
        '- **user_guide.md**: Guia completo do usuário\n' ...
        '- **api_reference.md**: Referência da API\n' ...
        '- **examples/**: Exemplos de uso\n']);
    
    escrever_readme('docs/README.md', readme_docs);
    
    % README para config/
    readme_config = sprintf(['# Configurações\n\n' ...
        'Este diretório contém arquivos de configuração do sistema.\n\n' ...
        '## Arquivos\n\n' ...
        '- **default_config.m**: Configurações padrão do sistema\n' ...
        '- Arquivos de configuração personalizados serão salvos aqui\n']);
    
    escrever_readme('config/README.md', readme_config);
    
    % README para output/
    readme_output = sprintf(['# Saídas\n\n' ...
        'Este diretório contém todas as saídas geradas pelo sistema.\n\n' ...
        '## Estrutura\n\n' ...
        '- **models/**: Modelos treinados salvos\n' ...
        '- **reports/**: Relatórios de comparação gerados\n' ...
        '- **visualizations/**: Gráficos e visualizações\n']);
    
    escrever_readme('output/README.md', readme_output);
end

function escrever_readme(caminho, conteudo)
% Escrever arquivo README.md se não existir
    if ~exist(caminho, 'file')
        fid = fopen(caminho, 'w', 'n', 'UTF-8');
        if fid ~= -1
            fprintf(fid, '%s', conteudo);
            fclose(fid);
            fprintf('  ✓ %s\n', caminho);
        else
            fprintf('  ❌ Erro ao criar %s\n', caminho);
        end
    else
        fprintf('  → %s (já existe)\n', caminho);
    end
end