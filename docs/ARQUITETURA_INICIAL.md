# Arquitetura inicial

O GameState centraliza flags de história, decisões e relações. O SaveSystem serializa esse estado em JSON local versionado (user://azael_save.json) junto com os dados específicos da cena.

Diálogos e missões ficam em data/, separados da lógica. Consequências devem ser explícitas e testáveis. Ramificações podem convergir em pontos narrativos planejados, mas escolhas importantes não podem ser cosméticas.

Começar com geometria simples, poucos materiais e cenas pequenas. Medir desempenho antes de assumir compatibilidade com o notebook ou celulares.
