function exemplo_treinamento_unet()
    % Exemplo de uso da classe TreinadorUNet
    % Este script demonstra como usar o TreinadorUNet para treinar um modelo
    
    fprintf('=== EXEMPLO DE TREINAMENTO U-NET ===\n');
    
    try
        % Definir caminhos
        caminhoImagens = 'C:\Users\heito\Documents\MATLAB\img\original';
        caminhoMascaras = 'C:\Users\heito\Documents\MATLAB\img\masks';
        
        % Criar treinador
        fprintf('Criando TreinadorUNet...\n');
        treinador = TreinadorUNet(caminhoImagens, caminhoMascaras);
        
        % Executar treinamento
        fprintf('Iniciando treinamento...\n');
        modelo = treinador.treinar();
        
        fprintf('✅ Treinamento concluído com sucesso!\n');
        fprintf('Modelo salvo em: resultados_segmentacao/modelos/modelo_unet.mat\n');
        
    catch ME
        fprintf('❌ Erro durante treinamento: %s\n', ME.message);
    end
end