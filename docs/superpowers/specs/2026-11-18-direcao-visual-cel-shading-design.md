# Direção visual — Anime 3D com cel shading

**Status:** proposta técnica preparada; aguarda aprovação final do usuário antes da implementação.  
**Projeto:** AZAEL — HERDEIRO DO CAOS  
**Data:** 18/11/2026

## 1. Objetivo

Definir uma identidade visual consistente para o RPG 3D: anime com cel shading marcado, contornos seletivos e cenários de fantasia estilizados, equilibrando qualidade visual e desempenho em celulares Android.

A imagem de referência fornecida pelo usuário continua sendo a base de Azael no início da aventura. A princesa terá a mesma qualidade artística, mas identidade, silhueta, roupa, personalidade e habilidades próprias. As decisões não alteram o cânone narrativo nem as quatro formas já estabelecidas de Azael.

## 2. Decisões aprovadas

- Estilo principal: anime 3D com cel shading forte.
- Abordagem: cel shading nos materiais dos personagens e contornos seletivos; elementos estilizados de cenário inspirados no mesmo desenho.
- Prioridade de plataforma: equilíbrio entre qualidade gráfica e desempenho Android.
- O estilo deve permanecer reconhecível nos três perfis gráficos; os perfis reduzem densidade, resolução e efeitos, não substituem a identidade artística.
- Os ícones 2D seguem a referência do usuário: ilustração colorida, contorno escuro e silhueta legível em telas pequenas.

## 3. Abordagens consideradas

### A — Cel shading nos materiais e contornos seletivos — escolhida

Usar shaders espaciais com iluminação toon nos personagens e objetos importantes. Contornos de silhueta serão aplicados seletivamente, preferencialmente por técnica de malha expandida/inverted hull ou solução equivalente validada nos dois renderizadores. Cenários usam materiais estilizados, paleta coerente e sombras simplificadas, sem exigir contorno em cada folha ou objeto.

**Motivo:** oferece a identidade anime pretendida sem exigir um efeito de tela inteira para todos os pixels.

### B — Contorno e pós-processamento na tela inteira — não escolhida como base

Pode gerar aparência uniforme, mas o processamento de bordas em tela inteira e a dependência de buffers/efeitos de pós-processamento aumentam a complexidade e podem variar entre renderizadores. Pode ser reavaliada apenas como opção de alto desempenho gráfico depois de medição.

### C — Toon shading uniforme em todo o cenário — não escolhida isoladamente

Daria grande unidade visual, mas pode tornar superfícies naturais e detalhes do ambiente excessivamente gráficos. Elementos dessa abordagem serão usados de maneira seletiva em construções, rochas, árvores e props.

## 4. Direção de arte por categoria

### Personagens principais
- Azael: preservar aparência inicial da referência do usuário; roupa, cabelo, rosto e proporções devem permitir leitura clara em câmera de terceira pessoa.
- Princesa: compartilhar o mesmo padrão de modelagem, materiais, iluminação e animação, sem copiar o desenho de Azael.
- Modelos com silhuetas limpas, topologia adequada à deformação, materiais toon e paleta de cores planejada.
- Contornos escuros, consistentes e moderados; espessura deve ser validada em diferentes distâncias e resoluções.
- Animações futuras devem contemplar idle, caminhada, corrida, salto, ataques, dano, esquiva e ações especiais.

### NPCs, inimigos e chefes
- NPCs importantes recebem o mesmo padrão visual dos protagonistas.
- NPCs distantes usam menor detalhe e podem não receber contorno.
- Inimigos e chefes terão silhuetas, paletas e efeitos próprios para serem reconhecidos rapidamente.
- Contorno priorizado para protagonista, princesa quando presente, inimigos próximos e chefes; não aplicado indiscriminadamente a multidões.

### Cenários
- Cenários de fantasia 3D coloridos, com volumes e silhuetas legíveis.
- Construções com telhados, molduras, portas, janelas, variação de materiais e detalhes funcionais.
- Vegetação em camadas, variação de escala e cor; uso de MultiMesh para elementos repetidos.
- Terreno com relevo e transições visuais, trilhas, rochas, água e props distribuídos com intenção.
- Sombras e materiais estilizados; contorno geral do cenário não é obrigatório.
- Névoa de distância discreta para profundidade, sem névoa volumétrica como requisito.

### Interface e ícones
- Ícones 2D com contornos fortes, cores distintas, volume ilustrado e leitura em tamanhos pequenos.
- HUD adaptável a diferentes proporções de tela Android.
- Botões e textos devem manter área de toque e legibilidade adequadas; a interface não deve depender de uma resolução física fixa.

### Poderes e efeitos
- Efeitos com formas gráficas claras, cores associadas ao poder e duração curta.
- Partículas e brilhos escaláveis por perfil.
- Evitar dezenas de luzes dinâmicas, transparências sobrepostas e partículas excessivas.
- As manifestações involuntárias dos poderes de Azael devem ganhar intensidade visual com a progressão narrativa, sem mudar a regra de que inicialmente ele não domina conscientemente seus poderes.

## 5. Diretrizes técnicas Godot e Android

- Continuar no Godot 4.x e validar os shaders na versão efetivamente usada pelo projeto.
- Usar renderizador Mobile em aparelhos compatíveis com Vulkan e manter Compatibility como caminho para aparelhos mais antigos. A documentação oficial recomenda Mobile para dispositivos móveis mais novos e Compatibility para dispositivos antigos/baixo desempenho.
- Não assumir que o renderizador Mobile é automaticamente mais rápido em todo celular; validar os dois caminhos.
- Usar os modos espaciais toon nativos `diffuse_toon` e `specular_toon` onde forem suficientes. A documentação do Godot lista esses modos na referência de Spatial shaders.
- Para contornos, começar com solução simples por personagem (ex.: inverted hull/mesh shell com `cull_front`) e validar artefatos, espessura, sombras e custo de chamadas de desenho. Não depender de stencil experimental nem de um efeito de tela inteira como requisito.
- Materiais compartilhados e shaders simples; evitar cálculos caros por pixel, loops grandes e dependência de compute shaders.
- Instanciar vegetação e props repetidos com MultiMesh quando apropriado.
- Usar LODs para personagens, edifícios e objetos de cenário; reduzir geometria e detalhes à distância.
- Definir resoluções e compressão de texturas por classe de asset. Personagens principais podem receber mais detalhe que props comuns; o formato final de compressão deve ser validado nos dispositivos-alvo.
- Considerar escala de resolução 3D configurável, preservando HUD e textos em resolução nativa. A documentação do Godot recomenda essa opção para ajustar custo de renderização 3D separadamente da interface.
- Evitar como configuração padrão: iluminação global dinâmica pesada, SSAO obrigatório, SSR, névoa volumétrica, múltiplas luzes com sombras e pós-processamento integral complexo.
- Manter uma luz direcional principal com sombras controladas; usar iluminação assada em cenários estáticos quando fizer sentido e após validar o pipeline.
- Não prometer compatibilidade, FPS ou temperatura sem testes em aparelhos reais.

## 6. Perfis gráficos propostos

Os números abaixo são limites/objetivos de configuração, não garantias de desempenho.

| Perfil | Limite inicial de FPS | Qualidade e custo |
|---|---:|---|
| Desempenho | 30 | Resolução 3D reduzida, pouca vegetação, sombras desligadas ou mínimas, partículas reduzidas e contornos apenas no protagonista/alvo próximo. |
| Equilibrado | 45 | Perfil Android recomendado: resolução 3D adaptativa, sombras da luz principal controladas, vegetação moderada, contornos seletivos e efeitos moderados. |
| Alto | 60 | Maior escala de resolução, mais densidade de cenário, sombras e partículas adicionais, respeitando o limite térmico do aparelho. |

Os limites poderão ser revistos após medições. Em aparelhos que não sustentem o objetivo do perfil, o jogo deverá permitir reduzir a qualidade sem perder o estilo toon.

## 7. Escopo da primeira implementação visual

A primeira fatia implementável deve ser pequena e verificável:
1. Criar material/shader toon base com parâmetros de paleta e intensidade de brilho.
2. Criar material de contorno seletivo para um modelo de teste, com espessura ajustável.
3. Aplicar os materiais a um personagem de teste e a um inimigo, sem substituir ainda todos os modelos provisórios.
4. Ajustar a luz principal, ambiente, paleta e materiais de uma área pequena da vila.
5. Estender perfis gráficos para controlar contornos, sombras, densidade e escala de resolução 3D.
6. Documentar como importar modelos, configurar materiais e preparar LODs.

Assets finais de Azael, princesa, NPCs e chefes serão uma etapa de produção de conteúdo separada; esta proposta não inventa ou altera o design canônico deles.

## 8. Fora do escopo desta etapa

- Refazer todo o continente, cidades ou regiões.
- Produzir todos os modelos finais e animações dos protagonistas.
- Alterar história, poderes, transformações ou cânone.
- Prometer um APK pronto ou desempenho aprovado antes dos testes.
- Adicionar efeitos avançados apenas para parecer mais realista, se prejudicarem Android.

## 9. Critérios de aceitação

A primeira implementação será considerada tecnicamente aceitável quando:
- O projeto importar e abrir sem erros de parser/shader na versão Godot acordada.
- O material toon funcionar na amostra com renderizador Mobile e Compatibility.
- O contorno não apresentar z-fighting evidente, inversão de faces, cortes ou espessura excessiva.
- O estilo continuar legível em resoluções e proporções de tela diferentes.
- Os três perfis alterarem os custos gráficos sem remover a identidade visual.
- Não houver dependência obrigatória de efeitos não suportados pelo Compatibility.
- Houver medições de FPS, memória, temperatura e estabilidade em ao menos um Android de entrada e um intermediário antes de declarar o equilíbrio aprovado.

## 10. Referências técnicas

- Godot 4.7 — Spatial shaders: https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/spatial_shader.html
- Godot — Overview of renderers: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Godot — Multiple resolutions (inclui escala de resolução 3D e orientação para celular): https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html

## 11. Pendências para aprovação

- Confirmar que esta proposta representa a direção visual desejada.
- Após aprovação, preparar plano de implementação detalhado e então começar a primeira amostra de shader/contorno.
- A versão Godot e os aparelhos Android para validação precisam ser confirmados quando o usuário tiver acesso ao notebook e aos dispositivos.
