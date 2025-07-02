%% TESTE DA VERDADEIRA ATTENTION U-NET
%% Script para verificar se a implementação está funcionando corretamente

clc; clear; close all;

fprintf('🧪 TESTANDO IMPLEMENTAÇÃO DA VERDADEIRA ATTENTION U-NET\n\n');

%% 1. TESTAR CRIAÇÃO DA ARQUITETURA
fprintf('1. Testando criação da arquitetura...\n');

inputSize = [256, 256, 3];
numClasses = 2;

try
    % Tentar criar a verdadeira Attention U-Net
    lgraph_attention = create_true_attention_unet(inputSize, numClasses);
    fprintf('✅ Attention U-Net criada com sucesso!\n');
    
    % Verificar se é diferente da U-Net clássica
    lgraph_unet = unetLayers(inputSize, numClasses, 'EncoderDepth', 4);
    
    % Comparar número de layers
    num_layers_attention = length(lgraph_attention.Layers);
    num_layers_unet = length(lgraph_unet.Layers);
    
    fprintf('   📊 U-Net clássica: %d layers\n', num_layers_unet);
    fprintf('   📊 Attention U-Net: %d layers\n', num_layers_attention);
    
    if num_layers_attention > num_layers_unet
        fprintf('✅ Attention U-Net tem mais layers (atenção implementada!)\n');
    else
        fprintf('⚠️ Attention U-Net não tem layers adicionais\n');
    end
    
catch ME
    fprintf('❌ Erro ao criar Attention U-Net: %s\n', ME.message);
    return;
end

%% 2. ANALISAR ARQUITETURA
fprintf('\n2. Analisando arquitetura...\n');

% Procurar por attention components
attention_layers = {};
se_layers = {};

for i = 1:length(lgraph_attention.Layers)
    layerName = lgraph_attention.Layers(i).Name;
    
    if contains(layerName, 'att') || contains(layerName, 'attention')
        attention_layers{end+1} = layerName;
    end
    
    if contains(layerName, 'SE') || contains(layerName, 'se')
        se_layers{end+1} = layerName;
    end
end

fprintf('   🎯 Attention layers encontradas: %d\n', length(attention_layers));
if ~isempty(attention_layers)
    for i = 1:min(5, length(attention_layers))
        fprintf('      - %s\n', attention_layers{i});
    end
    if length(attention_layers) > 5
        fprintf('      ... e mais %d\n', length(attention_layers) - 5);
    end
end

fprintf('   🔧 SE layers encontradas: %d\n', length(se_layers));
if ~isempty(se_layers)
    for i = 1:min(5, length(se_layers))
        fprintf('      - %s\n', se_layers{i});
    end
    if length(se_layers) > 5
        fprintf('      ... e mais %d\n', length(se_layers) - 5);
    end
end

%% 3. VERIFICAR CONEXÕES
fprintf('\n3. Verificando conexões...\n');

connections = lgraph_attention.Connections;
num_connections = height(connections);

fprintf('   🔗 Total de conexões: %d\n', num_connections);

% Procurar conexões de atenção
attention_connections = 0;
for i = 1:height(connections)
    if contains(connections.Source{i}, 'att') || contains(connections.Destination{i}, 'att')
        attention_connections = attention_connections + 1;
    end
end

fprintf('   🎯 Conexões de atenção: %d\n', attention_connections);

%% 4. TESTE DE FORWARD PASS (SIMULADO)
fprintf('\n4. Testando forward pass...\n');

try
    % Criar dados sintéticos para teste
    testImage = rand(256, 256, 3, 'single');
    
    % Simular passagem pela rede (apenas verificar se não dá erro)
    fprintf('   📥 Imagem de teste criada: 256x256x3\n');
    
    % Verificar se a rede pode ser compilada
    analyzeNetwork(lgraph_attention);
    fprintf('   ✅ Rede pode ser compilada sem erros!\n');
    
catch ME
    fprintf('   ⚠️ Erro no forward pass: %s\n', ME.message);
end

%% 5. COMPARAÇÃO COM U-NET CLÁSSICA
fprintf('\n5. Comparação detalhada com U-Net clássica...\n');

% Contar tipos de layers
tipos_attention = containers.Map();
tipos_unet = containers.Map();

for i = 1:length(lgraph_attention.Layers)
    tipo = class(lgraph_attention.Layers(i));
    if isKey(tipos_attention, tipo)
        tipos_attention(tipo) = tipos_attention(tipo) + 1;
    else
        tipos_attention(tipo) = 1;
    end
end

for i = 1:length(lgraph_unet.Layers)
    tipo = class(lgraph_unet.Layers(i));
    if isKey(tipos_unet, tipo)
        tipos_unet(tipo) = tipos_unet(tipo) + 1;
    else
        tipos_unet(tipo) = 1;
    end
end

fprintf('   📊 Tipos de layers:\n');
tipos_unicos = unique([keys(tipos_attention), keys(tipos_unet)]);

for i = 1:length(tipos_unicos)
    tipo = tipos_unicos{i};
    
    if isKey(tipos_attention, tipo)
        count_att = tipos_attention(tipo);
    else
        count_att = 0;
    end
    
    if isKey(tipos_unet, tipo)
        count_unet = tipos_unet(tipo);
    else
        count_unet = 0;
    end
    
    diff = count_att - count_unet;
    if diff > 0
        status = sprintf('(+%d)', diff);
    elseif diff < 0
        status = sprintf('(%d)', diff);
    else
        status = '(=)';
    end
    
    [~, shortType] = fileparts(tipo);
    fprintf('      %-20s: U-Net:%2d, Attention:%2d %s\n', ...
        shortType, count_unet, count_att, status);
end

%% 6. VERIFICAÇÃO FINAL
fprintf('\n6. Verificação final...\n');

% Critérios para validar se é uma verdadeira Attention U-Net
criterios_atendidos = 0;
total_criterios = 4;

% Critério 1: Mais layers que U-Net clássica
if num_layers_attention > num_layers_unet
    fprintf('   ✅ Critério 1: Tem mais layers que U-Net clássica\n');
    criterios_atendidos = criterios_atendidos + 1;
else
    fprintf('   ❌ Critério 1: Não tem layers suficientes\n');
end

% Critério 2: Tem attention/SE layers
if length(attention_layers) > 0 || length(se_layers) > 0
    fprintf('   ✅ Critério 2: Tem layers de atenção\n');
    criterios_atendidos = criterios_atendidos + 1;
else
    fprintf('   ❌ Critério 2: Não tem layers de atenção\n');
end

% Critério 3: Tem conexões de atenção
if attention_connections > 0
    fprintf('   ✅ Critério 3: Tem conexões de atenção\n');
    criterios_atendidos = criterios_atendidos + 1;
else
    fprintf('   ❌ Critério 3: Não tem conexões de atenção\n');
end

% Critério 4: Pode ser compilada
try
    analyzeNetwork(lgraph_attention);
    fprintf('   ✅ Critério 4: Arquitetura válida\n');
    criterios_atendidos = criterios_atendidos + 1;
catch
    fprintf('   ❌ Critério 4: Arquitetura inválida\n');
end

%% RESULTADO FINAL
fprintf('\n🏁 RESULTADO FINAL:\n');
fprintf('   Critérios atendidos: %d/%d\n', criterios_atendidos, total_criterios);

if criterios_atendidos == total_criterios
    fprintf('   🎉 SUCESSO! Verdadeira Attention U-Net implementada!\n');
    fprintf('   🚀 Pronta para usar no executar_comparacao()!\n');
elseif criterios_atendidos >= 3
    fprintf('   ✅ BOA! Implementação funcional (com ressalvas)\n');
    fprintf('   🔧 Pode precisar de ajustes menores\n');
else
    fprintf('   ⚠️ ATENÇÃO! Implementação incompleta\n');
    fprintf('   🔨 Precisa de mais trabalho\n');
end

fprintf('\n📝 Para usar: execute executar_comparacao() e escolha opção 4\n');
fprintf('📊 Agora você deve ver diferenças reais entre os modelos!\n');
