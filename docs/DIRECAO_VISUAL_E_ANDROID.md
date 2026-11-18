# Direção visual e desempenho Android

## Direção de arte

AZAEL seguirá uma direção de fantasia anime estilizada em 3D. A prioridade é criar cenários legíveis, coloridos e cheios de personalidade sem depender de efeitos caros em tempo real.

A primeira vila usa:
- Paleta de cores coerente para grama, madeira, pedra, telhados e água.
- Formas de baixo polígono com silhuetas fáceis de reconhecer.
- Telhados inclinados, portas, janelas, cercas, árvores em camadas, lanternas e poço.
- Névoa de distância discreta para separar planos do cenário.
- Materiais reaproveitados e detalhes repetidos por MultiMesh.

## Perfis gráficos

O autoload `GraphicsSettings` oferece três perfis:

| Perfil | Limite de quadros | Sombras | Detalhes de grama e pedras |
|---|---:|---|---|
| Desempenho | 45 FPS | Desligadas | Ocultos |
| Equilibrado | 60 FPS | Ligadas | Visíveis |
| Alto | 60 FPS | Ligadas | Visíveis |

No Android, o perfil inicial é **Equilibrado**. No computador, o perfil inicial é **Alto**. Durante o protótipo para PC, pressione **F7** para alternar entre os três perfis.

O perfil é apenas um ponto de partida. O limite de FPS não garante que o aparelho consiga atingir essa taxa; isso depende do processador, GPU, resolução, temperatura e complexidade da cena.

## Decisões de compatibilidade

No Android, o projeto usa primeiro o renderizador **Mobile (Vulkan)** para aproveitar melhor os aparelhos compatíveis. Em Godot 4.4 ou posterior, o projeto mantém ativado o fallback para **Compatibility (OpenGL)** caso o RenderingDevice/Vulkan não esteja disponível. No computador, o padrão continua Compatibility para facilitar o desenvolvimento em hardware modesto.

Não usar como padrão:
- Iluminação global dinâmica pesada.
- Névoa volumétrica.
- Muitas luzes com sombras em tempo real.
- Texturas enormes ou materiais com múltiplas camadas caras.
- Vegetação individual excessiva sem instanciamento.

## Próximos ajustes após testes

1. Medir FPS, temperatura e uso de memória em pelo menos um Android de entrada e um intermediário.
2. Ajustar distância de visão, densidade de vegetação e resolução de renderização conforme os resultados.
3. Criar uma tela gráfica acessível por toque para selecionar os perfis no celular.
4. Substituir gradualmente os modelos provisórios por modelos finais otimizados, com LODs e texturas compactadas.

A escolha Mobile com fallback para Compatibility amplia o alcance, mas não substitui testes em dispositivos reais. Nenhuma meta de FPS ou compatibilidade é considerada aprovada até haver esses testes.
