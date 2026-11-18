# Teste da primeira área jogável

Esta etapa adiciona uma vila provisória para validar os sistemas básicos. Os modelos e a arte ainda são formas simples, não são os visuais finais de AZAEL.

## Como abrir

1. Abra o Godot 4.x.
2. Escolha **Importar** e selecione o arquivo `project.godot` baixado deste repositório.
3. Abra o projeto e aguarde a importação.
4. Pressione **F6** para executar a cena principal ou **F5** para executar o projeto.

## O que testar

- **W, A, S, D:** movimentar Azael.
- **Mouse:** girar a câmera.
- **E perto do morador:** abrir o diálogo.
- Escolha uma das três respostas. A mensagem de resultado muda conforme a opção e a decisão fica registrada no estado do jogo durante a sessão.
- **F perto do alvo vermelho:** atacar. Cada golpe causa 10 de dano; o inimigo tem 40 pontos de vida.
- O inimigo se aproxima e causa dano quando chega perto.
- **ESC:** liberar ou capturar o mouse novamente.

## O que ainda não está pronto

- As decisões ainda não são salvas em arquivo entre sessões.
- Não há animações, modelos finais, áudio ou efeitos de combate.
- A vila é um cenário de protótipo para validar movimentação, interação, escolhas e combate.
- O teste precisa ser executado no Godot para confirmar compatibilidade com o notebook e corrigir eventuais erros do editor.

## Como relatar um problema

Envie uma captura de tela do erro ou copie o texto que aparece nas abas **Erros** e **Saída** do Godot. Diga também em qual passo aconteceu.
