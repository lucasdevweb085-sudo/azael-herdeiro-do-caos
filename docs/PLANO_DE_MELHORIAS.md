# Plano de melhorias — AZAEL

As cinco melhorias serão desenvolvidas **uma por vez**. A implementação de cada etapa deve ser validada no Godot antes de ser considerada aprovada. As decisões narrativas continuam preservadas.

## Ordem aprovada

1. **Controles Android** — joystick virtual, câmera por toque e botões de interação/ataque. Os botões de esquiva e defesa foram conectados quando o combate passou a existir.
2. **Salvamento** — gravação e recuperação de flags, decisões, relações, posição e vida; salvamento manual e automático. Dados de missões e evolução serão conectados quando esses sistemas existirem.
3. **Combate** — combos de três golpes, esquiva, bloqueio e aviso de preparação do inimigo. Habilidades e padrões específicos de chefes continuam planejados.
4. **Exploração e missões** — objetivos, mapa/minimapa, missões secundárias, segredos e escolhas persistentes com consequências reais.
5. **Evolução dos personagens** — atributos, equipamentos e melhorias; progressão gradual do domínio dos poderes de Azael e evolução própria da princesa.

## Regras de execução

- Concluir uma etapa por vez e registrar o resultado da anterior.
- Preservar o projeto em Godot 4 e a prioridade Android.
- Manter compatibilidade com teclado e mouse durante o desenvolvimento no notebook.
- Não considerar uma etapa aprovada até abrir e testar no Godot; funcionalidades específicas de toque exigem teste em Android.
- Separar metas configuradas de desempenho medido. Não prometer FPS sem teste em aparelhos reais.
- Não alterar o cânone, personagens ou transformações sem autorização explícita.

## Estado atual

- [x] Sequência de cinco melhorias organizada.
- [~] Etapa 1 — Controles: código presente; falta validar no editor Godot e em tela Android.
- [~] Etapa 2 — Salvamento: JSON local versionado e carregamento manual/automático implementados parcialmente; falta validar escrita, leitura e retomada do estado.
- [~] Etapa 3 — Combate: combos, esquiva, defesa e sinalização do golpe inimigo implementados como protótipo; faltam habilidades, padrões de chefes e validação no Godot.
- [ ] Etapa 4 — Exploração e missões.
- [ ] Etapa 5 — Evolução dos personagens.

## Pendências de validação

1. Executar os três testes automatizados listados em tests/README.md.
2. Abrir a vila e conferir movimentação, câmera, diálogo, combate e perfis gráficos no notebook.
3. Reabrir o jogo após derrotar o inimigo e confirmar que ele continua derrotado.
4. Em Android, testar joystick, câmera por gesto, botões simultâneos e liberação de comandos ao abrir diálogo ou perder foco.

A etapa 4 deve começar somente depois que as etapas anteriores tiverem um resultado de validação registrado.
