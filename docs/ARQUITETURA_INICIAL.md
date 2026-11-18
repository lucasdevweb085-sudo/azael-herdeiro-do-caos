# Arquitetura inicial

`GameState` centraliza flags de história, decisões e relações. Nesta base, os dados ficam em memória durante a execução; salvamento em disco será adicionado depois.

Diálogos e missões ficam em `data/`, separados da lógica. Consequências devem ser explícitas e testáveis. Ramificações podem convergir em pontos narrativos planejados, mas escolhas importantes não podem ser cosméticas.

Começar com geometria simples, poucos materiais e cenas pequenas. Medir desempenho antes de assumir compatibilidade com o notebook ou celulares.
