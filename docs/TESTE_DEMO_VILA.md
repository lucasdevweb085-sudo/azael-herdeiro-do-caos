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
- **F7 (teclado no PC):** alternar entre Desempenho, Equilibrado e Alto. No Android, o perfil inicial é escolhido automaticamente conforme o renderizador disponível.

## O que ainda não está pronto

- As decisões ainda não são salvas em arquivo entre sessões.
- Não há animações, modelos finais, áudio ou efeitos de combate.
- A vila é um cenário de protótipo para validar movimentação, interação, escolhas e combate.
- O teste precisa ser executado no Godot para confirmar compatibilidade com o notebook e corrigir eventuais erros do editor.

## Como relatar um problema

Envie uma captura de tela do erro ou copie o texto que aparece nas abas **Erros** e **Saída** do Godot. Diga também em qual passo aconteceu.


## Controles da primeira etapa Android

No notebook, os controles continuam sendo:
- WASD: movimentar.
- Mouse: controlar a câmera.
- E: conversar com o morador.
- F: atacar o alvo.
- ESC: liberar/capturar o mouse.

Em Android/iOS, a interface de toque aparece automaticamente:
- Joystick virtual no canto inferior esquerdo: movimentar Azael.
- Arrastar no lado direito da tela: controlar a câmera.
- Botões **ATACAR** e **INTERAGIR** no canto inferior direito.

Os controles de esquiva e defesa foram adicionados junto ao protótipo de combate. Habilidades ainda não estão implementadas.

### Verificação do joystick

Depois de abrir o projeto no Godot, rode no terminal do sistema, dentro da pasta do projeto:

```bash
godot --headless --path . --script tests/test_mobile_controls.gd
```

No Windows, use o nome do executável baixado (por exemplo, `Godot_v4.7.2-stable_win64.exe`) no lugar de `godot`.

Os testes automatizados cobrem o mapeamento do joystick, o botão de defesa, a validação do formato do salvamento e as regras de dano do combo. Os comandos estão em tests/README.md. O teste em Android ainda é obrigatório para confirmar gestos, áreas de toque e comportamento em tela real.


## Salvamento e carregamento

- **F5 no PC** ou **SALVAR no Android:** salva o progresso no arquivo local `user://azael_save.json`.
- **F9 no PC:** carrega o último salvamento.
- Ao iniciar o jogo, o último salvamento é carregado automaticamente.
- O jogo salva automaticamente depois de uma escolha narrativa, ao derrotar o inimigo e quando o aplicativo é pausado/fechado. Ao iniciar, a flag de inimigo derrotado é respeitada para que o alvo não reapareça após reiniciar.
- O arquivo contém decisões, flags de história, relações, posição de Azael e vida. Os dados de missões e evolução serão incorporados pelas próximas etapas.

Para verificar o arquivo no editor, abra **Projeto → Abrir pasta de dados do projeto** (ou use a pasta de dados do usuário do Godot). O arquivo fica no diretório de usuário do aplicativo, não dentro da pasta do repositório.


## Combate aprimorado

- **F:** sequência de três golpes; o dano aumenta se os ataques forem encadeados rapidamente.
- **Q:** esquiva com custo de vigor, recarga e breve janela de invulnerabilidade.
- **Shift pressionado:** defesa reduzindo o dano, com consumo contínuo e por golpe de vigor.
- No Android, use os botões **ESQUIVAR** e **DEFENDER**.
- O inimigo sinaliza antes de atacar; esquive ou segure a defesa para reduzir o dano.
- A barra/valor de vigor será exibida junto à interface na etapa de evolução da interface.

Essas ações ainda usam modelos provisórios e não têm animações definitivas. O comportamento precisa ser validado no Godot.


### Teste de retomada após derrotar o inimigo

1. Inicie a vila e derrote o alvo de treinamento.
2. Aguarde a mensagem de confirmação do salvamento automático.
3. Feche o jogo e abra novamente.
4. Confirme que o alvo continua derrotado e que a posição/vida salvas foram recuperadas.

Se o alvo reaparecer, envie a mensagem da aba Saída do Godot.
