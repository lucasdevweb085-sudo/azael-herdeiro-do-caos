extends Node3D
## Área de demonstração: vila, conversa com escolhas e combate básico.

const DIALOGUE_PATH := "res://data/dialogues/demo_village.json"

@onready var player: CharacterBody3D = $Player
@onready var ui_layer: CanvasLayer = $HUD
@onready var status_label: Label = $HUD/StatusLabel

var npc: Node3D
var enemy: CharacterBody3D
var information_label: Label
var dialogue_panel: PanelContainer
var dialogue_title: Label
var dialogue_text: Label
var options_container: VBoxContainer

var current_dialogue: Dictionary = {}
var dialogue_open: bool = false
var player_health: int = 100
var last_choice_result: String = "Ainda não há uma decisão registrada."

func _ready() -> void:
    player.add_to_group("player")
    _build_village()
    _create_npc()
    _create_enemy()
    _create_interface()
    _refresh_status("Objetivo: converse com o morador e teste o combate.")

func _unhandled_input(event: InputEvent) -> void:
    if not event is InputEventKey:
        return
    if not event.pressed or event.echo or dialogue_open:
        return

    if event.keycode == KEY_E:
        _try_interact()
        get_viewport().set_input_as_handled()
    elif event.keycode == KEY_F:
        _try_attack()
        get_viewport().set_input_as_handled()

func _build_village() -> void:
    _make_visual_box("Estrada", self, Vector3(0, 0.015, -7), Vector3(5, 0.03, 30), Color(0.42, 0.34, 0.25))
    _make_box("CasaEsquerda", Vector3(-12, 0, -12), Vector3(6, 4, 5), Color(0.55, 0.34, 0.24))
    _make_visual_box("TelhadoEsquerdo", self, Vector3(-12, 4.1, -12), Vector3(6.8, 0.7, 5.8), Color(0.28, 0.16, 0.13))
    _make_box("CasaDireita", Vector3(12, 0, -15), Vector3(6, 4, 5), Color(0.67, 0.55, 0.36))
    _make_visual_box("TelhadoDireito", self, Vector3(12, 4.1, -15), Vector3(6.8, 0.7, 5.8), Color(0.34, 0.22, 0.16))
    _make_box("Deposito", Vector3(14, 0, 5), Vector3(5, 3.2, 5), Color(0.42, 0.43, 0.37))
    _make_visual_box("TelhadoDeposito", self, Vector3(14, 3.3, 5), Vector3(5.8, 0.6, 5.8), Color(0.25, 0.28, 0.25))

    _make_tree(Vector3(-8, 0, -3))
    _make_tree(Vector3(8, 0, -5))
    _make_tree(Vector3(-17, 0, 6))
    _make_tree(Vector3(18, 0, -4))
    _make_tree(Vector3(5, 0, -18))
    _make_tree(Vector3(-5, 0, -20))

    var well := MeshInstance3D.new()
    well.name = "PocoDaVila"
    var well_mesh := CylinderMesh.new()
    well_mesh.top_radius = 1.0
    well_mesh.bottom_radius = 1.0
    well_mesh.height = 0.8
    well.mesh = well_mesh
    well.position = Vector3(7, 0.4, 6)
    well.material_override = _material(Color(0.38, 0.4, 0.42))
    add_child(well)

func _create_npc() -> void:
    npc = Node3D.new()
    npc.name = "MoradorDaVila"
    npc.position = Vector3(2.3, 0, -1.2)
    add_child(npc)

    var body_mesh := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.35
    capsule.height = 1.7
    body_mesh.mesh = capsule
    body_mesh.position.y = 0.85
    body_mesh.material_override = _material(Color(0.18, 0.43, 0.72))
    npc.add_child(body_mesh)

    var marker := Label3D.new()
    marker.text = "MORADOR"
    marker.position = Vector3(0, 2.0, 0)
    marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    marker.font_size = 32
    npc.add_child(marker)

func _create_enemy() -> void:
    var enemy_body := CharacterBody3D.new()
    enemy_body.name = "InimigoDeTreinamento"
    enemy_body.set_script(load("res://scripts/combat/training_enemy.gd"))
    enemy_body.position = Vector3(-6, 0, -8)
    add_child(enemy_body)
    enemy = enemy_body

    var collision := CollisionShape3D.new()
    var capsule_shape := CapsuleShape3D.new()
    capsule_shape.radius = 0.48
    capsule_shape.height = 1.8
    collision.shape = capsule_shape
    collision.position.y = 0.9
    enemy_body.add_child(collision)

    var visual := MeshInstance3D.new()
    var capsule_mesh := CapsuleMesh.new()
    capsule_mesh.radius = 0.48
    capsule_mesh.height = 1.8
    visual.mesh = capsule_mesh
    visual.position.y = 0.9
    visual.material_override = _material(Color(0.65, 0.2, 0.18))
    enemy_body.add_child(visual)

    var marker := Label3D.new()
    marker.text = "ALVO DE TREINO"
    marker.position.y = 2.0
    marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    marker.font_size = 28
    enemy_body.add_child(marker)

    enemy_body.connect("player_hit", Callable(self, "_on_player_hit"))
    enemy_body.connect("defeated", Callable(self, "_on_enemy_defeated"))

func _create_interface() -> void:
    status_label.text = "AZAEL — VILA DE TESTE\nWASD: mover | Mouse: câmera | E: conversar | F: atacar | ESC: soltar mouse"
    status_label.add_theme_font_size_override("font_size", 16)

    information_label = Label.new()
    information_label.position = Vector2(18, 105)
    information_label.size = Vector2(620, 70)
    information_label.add_theme_font_size_override("font_size", 16)
    information_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    ui_layer.add_child(information_label)

    dialogue_panel = PanelContainer.new()
    dialogue_panel.name = "DialoguePanel"
    dialogue_panel.anchor_left = 0.5
    dialogue_panel.anchor_top = 0.5
    dialogue_panel.anchor_right = 0.5
    dialogue_panel.anchor_bottom = 0.5
    dialogue_panel.offset_left = -270
    dialogue_panel.offset_top = -175
    dialogue_panel.offset_right = 270
    dialogue_panel.offset_bottom = 175
    dialogue_panel.visible = false
    ui_layer.add_child(dialogue_panel)

    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 12)
    dialogue_panel.add_child(layout)

    dialogue_title = Label.new()
    dialogue_title.add_theme_font_size_override("font_size", 22)
    layout.add_child(dialogue_title)

    dialogue_text = Label.new()
    dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_text.custom_minimum_size = Vector2(500, 70)
    layout.add_child(dialogue_text)

    options_container = VBoxContainer.new()
    options_container.add_theme_constant_override("separation", 8)
    layout.add_child(options_container)

func _try_interact() -> void:
    if not is_instance_valid(npc):
        return
    var distance := Vector2(
        player.global_position.x - npc.global_position.x,
        player.global_position.z - npc.global_position.z
    ).length()
    if distance > 3.2:
        _refresh_status("Chegue mais perto do morador para conversar.")
        return

    if GameState.get_flag("village_first_choice_complete", false):
        _refresh_status(last_choice_result)
        return
    _open_dialogue()

func _open_dialogue() -> void:
    var file := FileAccess.open(DIALOGUE_PATH, FileAccess.READ)
    if file == null:
        _refresh_status("Não foi possível abrir o arquivo de diálogo.")
        return
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary:
        _refresh_status("O arquivo de diálogo contém dados inválidos.")
        return

    current_dialogue = parsed
    dialogue_title.text = str(current_dialogue.get("speaker", "Morador"))
    dialogue_text.text = str(current_dialogue.get("text", ""))
    for child in options_container.get_children():
        child.queue_free()

    for option in current_dialogue.get("options", []):
        var choice_button := Button.new()
        choice_button.text = str(option.get("text", "Escolher"))
        choice_button.custom_minimum_size = Vector2(500, 42)
        choice_button.pressed.connect(_on_choice_button_pressed.bind(str(option.get("id", ""))))
        options_container.add_child(choice_button)

    dialogue_open = true
    dialogue_panel.visible = true
    player.set_physics_process(false)
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_choice_button_pressed(option_id: String) -> void:
    for option in current_dialogue.get("options", []):
        if str(option.get("id", "")) == option_id:
            GameState.apply_choice_effects(str(current_dialogue.get("id", "unknown")), option)
            GameState.set_flag("village_first_choice_complete", true)
            last_choice_result = str(option.get("result_text", "Sua decisão foi registrada."))
            break

    dialogue_open = false
    dialogue_panel.visible = false
    player.set_physics_process(true)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    _refresh_status(last_choice_result)

func _try_attack() -> void:
    if not is_instance_valid(enemy):
        _refresh_status("Não há inimigo ativo. A área está segura.")
        return
    var distance := Vector2(
        player.global_position.x - enemy.global_position.x,
        player.global_position.z - enemy.global_position.z
    ).length()
    if distance > 2.8:
        _refresh_status("Aproxime-se do alvo vermelho para acertar o ataque.")
        return

    enemy.call("take_damage", 10)
    if is_instance_valid(enemy):
        _refresh_status("Ataque acertou! Vida do alvo: %d." % int(enemy.get("health")))
    else:
        _refresh_status("Alvo derrotado!")

func _on_player_hit(damage: int) -> void:
    player_health = maxi(player_health - damage, 0)
    if player_health == 0:
        _refresh_status("Você ficou sem vida. Reinicie a cena para tentar novamente.")
    else:
        _refresh_status("O inimigo acertou você. Afaste-se ou derrote-o!")

func _on_enemy_defeated() -> void:
    GameState.set_flag("training_enemy_defeated", true)
    enemy = null
    _refresh_status("Alvo derrotado! Primeiro teste de combate concluído.")

func _refresh_status(message: String) -> void:
    if information_label == null:
        return
    information_label.text = "Vida: %d/100\n%s" % [player_health, message]

func _make_box(box_name: String, world_position: Vector3, box_size: Vector3, color: Color) -> void:
    var body := StaticBody3D.new()
    body.name = box_name
    body.position = world_position
    add_child(body)

    var mesh_instance := MeshInstance3D.new()
    var box_mesh := BoxMesh.new()
    box_mesh.size = box_size
    mesh_instance.mesh = box_mesh
    mesh_instance.position.y = box_size.y * 0.5
    mesh_instance.material_override = _material(color)
    body.add_child(mesh_instance)

    var collision := CollisionShape3D.new()
    var box_shape := BoxShape3D.new()
    box_shape.size = box_size
    collision.shape = box_shape
    collision.position.y = box_size.y * 0.5
    body.add_child(collision)

func _make_visual_box(node_name: String, parent: Node3D, world_position: Vector3, box_size: Vector3, color: Color) -> void:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = node_name
    var box_mesh := BoxMesh.new()
    box_mesh.size = box_size
    mesh_instance.mesh = box_mesh
    mesh_instance.position = world_position
    mesh_instance.material_override = _material(color)
    parent.add_child(mesh_instance)

func _make_tree(world_position: Vector3) -> void:
    var trunk := MeshInstance3D.new()
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.18
    trunk_mesh.bottom_radius = 0.28
    trunk_mesh.height = 2.2
    trunk.mesh = trunk_mesh
    trunk.position = world_position + Vector3(0, 1.1, 0)
    trunk.material_override = _material(Color(0.3, 0.19, 0.12))
    add_child(trunk)

    var crown := MeshInstance3D.new()
    var crown_mesh := SphereMesh.new()
    crown_mesh.radius = 1.0
    crown_mesh.height = 2.0
    crown.mesh = crown_mesh
    crown.position = world_position + Vector3(0, 2.6, 0)
    crown.material_override = _material(Color(0.18, 0.39, 0.22))
    add_child(crown)

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    return material
