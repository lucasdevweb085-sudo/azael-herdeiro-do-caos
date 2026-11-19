# Testes automatizados

Os testes usam o Godot em modo headless. Na pasta raiz do projeto, execute cada comando:

    godot --headless --path . --script tests/test_mobile_controls.gd
    godot --headless --path . --script tests/test_save_system.gd
    godot --headless --path . --script tests/test_combat_rules.gd

No Windows, substitua godot pelo executável de console baixado, por exemplo:

    .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tests/test_mobile_controls.gd
    .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tests/test_save_system.gd
    .\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tests/test_combat_rules.gd

Cada execução deve terminar com código de saída zero e imprimir uma mensagem OK. Esses testes não substituem a abertura do projeto no editor nem o teste dos gestos em um Android real.
