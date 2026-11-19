# Teste da primeira área jogável

Esta é uma vila provisória para testar os sistemas básicos. Os modelos e a arte ainda usam formas simples e não representam o visual final de AZAEL.

## Como abrir

1. Baixe o ZIP do repositório e extraia a pasta.
2. Abra o Godot 4.7 ou posterior.
3. Escolha **Importar**, selecione o arquivo project.godot e abra o projeto.
4. Aguarde a importação terminar.
5. Pressione **F5** para executar o projeto ou **F6** para executar a cena aberta.

## Controles no notebook

- **W, A, S, D:** movimentar Azael.
- **Mouse:** girar a câmera.
- **E:** conversar com o morador quando estiver perto.
- **F:** atacar o alvo; golpes encadeados formam um combo de três etapas.
- **Q:** esquivar, consumindo vigor.
- **Shift pressionado:** defender e reduzir o dano recebido.
- **F5:** salvar manualmente.
- **F9:** carregar o último salvamento.
- **F7:** alternar os perfis gráficos.

## Controles no Android

A interface de toque aparece automaticamente:

- **Joystick no canto inferior esquerdo:** movimentar Azael.
- **Arrastar na área direita:** girar a câmera.
- **INTERAGIR e ATACAR:** botões de ação no canto inferior direito.
- **ESQUIVAR:** executar uma esquiva.
- **DEFENDER:** manter pressionado para bloquear golpes.
- **SALVAR:** botão no canto superior direito.

Ao abrir um diálogo ou quando o aplicativo perde o foco, os comandos de movimento e defesa devem ser liberados para evitar que Azael continue andando ou defendendo sozinho.

## Diálogos, combate e salvamento

- Aproxime-se do morador e pressione **E** ou **INTERAGIR**.
- Escolha uma das três respostas. A decisão, as flags e as relações afetadas são gravadas.
- Aproxime-se do alvo vermelho e use **F** ou **ATACAR**. O alvo tem 40 pontos de vida.
- Encadeie três ataques para testar os aumentos de dano do combo.
- Observe o aviso do inimigo antes do golpe; tente esquivar ou defender.
- O progresso local é salvo em user://azael_save.json.
- O jogo carrega o último salvamento ao iniciar. O alvo de treinamento não deve reaparecer se já tiver sido derrotado.

O salvamento atual registra decisões, flags de história, relações, posição e vida de Azael. Missões e evolução serão adicionadas aos dados salvos quando esses sistemas forem implementados.

## Testes automatizados

Na pasta raiz do projeto, execute os três comandos descritos em tests/README.md. Eles verificam o mapeamento do joystick e o botão de defesa, o formato do salvamento e os atalhos F5/F9, além das regras de dano do combo.

No Windows, use o executável de console do Godot em vez de escrever apenas godot. Os testes devem terminar sem erros e imprimir uma mensagem OK.

## O que ainda não está pronto

- Modelos finais, animações, áudio e efeitos visuais.
- Habilidades especiais e padrões exclusivos de chefes.
- Mapa/minimapa, conteúdo completo de missões e segredos.
- Sistema de evolução com atributos, equipamentos e árvore de domínio de poderes.
- Validação do projeto no editor e teste real dos controles em Android.

## Retomada após derrotar o inimigo

1. Inicie a vila e derrote o alvo de treinamento.
2. Aguarde a confirmação do salvamento automático.
3. Feche o jogo e abra novamente.
4. Confirme que o alvo continua derrotado e que a posição e a vida salvas foram recuperadas.

Se encontrar um erro, envie uma captura de tela ou copie o texto das abas **Erros** e **Saída** do Godot, dizendo em qual etapa aconteceu.
