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
var mobile_controls: Control

var current_dialogue: Dictionary = {}
var dialogue_open: bool = false
var player_health: int = 100
var last_choice_result: String = "Ainda não há uma decisão registrada."
var material_cache: Dictionary = {}

func _ready() -> void:
    player.add_to_group("player")
    var saved_scene_state := SaveSystem.load_game()
    _restore_scene_state(saved_scene_state)
    _build_village()
    _create_npc()
    _create_enemy()
    _create_interface()
    GraphicsSettings.quality_changed.connect(_on_quality_changed)
    GraphicsSettings.apply_recommended()
    _refresh_status("Objetivo: converse com o morador e teste o combate.")

func _process(_delta: float) -> void:
    if dialogue_open:
        return
    if Input.is_action_just_pressed("save_game"):
        _save_game()
    if Input.is_action_just_pressed("load_game"):
        _load_game()
    if Input.is_action_just_pressed("interact"):
        _try_interact()
    if Input.is_action_just_pressed("attack"):
        _try_attack()

func _build_village() -> void:
    var ground: MeshInstance3D = get_node("Ground/MeshInstance3D")
    ground.material_override = _material(Color(0.25, 0.39, 0.23), 1.0)

    _make_visual_box("Estrada", self, Vector3(0, 0.025, -7), Vector3(5.4, 0.05, 30), Color(0.48, 0.36, 0.24))
    _make_visual_box("TrilhaLateral", self, Vector3(8.5, 0.018, 1), Vector3(2.2, 0.035, 15), Color(0.43, 0.34, 0.24))

    _make_house("CasaDoArtesao", Vector3(-12, 0, -12), Vector3(6, 4, 5), Color(0.69, 0.43, 0.29), Color(0.35, 0.18, 0.15))
    _make_house("CasaDaEstalagem", Vector3(12, 0, -15), Vector3(6, 4, 5), Color(0.77, 0.65, 0.43), Color(0.34, 0.22, 0.16))
    _make_house("Deposito", Vector3(14, 0, 5), Vector3(5, 3.2, 5), Color(0.48, 0.49, 0.39), Color(0.25, 0.28, 0.23), false)

    _make_tree(Vector3(-8, 0, -3), 1.0)
    _make_tree(Vector3(8, 0, -5), 0.9)
    _make_tree(Vector3(-17, 0, 6), 1.15)
    _make_tree(Vector3(18, 0, -4), 1.1)
    _make_tree(Vector3(5, 0, -22), 0.95)
    _make_tree(Vector3(-5, 0, -22), 1.0)
    _make_tree(Vector3(22, 0, 11), 1.2)
    _make_tree(Vector3(-22, 0, -12), 1.15)
    _make_hill(Vector3(-27, 2.7, -29), Vector3(10, 3.2, 8), Color(0.24, 0.36, 0.25))
    _make_hill(Vector3(-8, 2.2, -34), Vector3(11, 2.7, 7), Color(0.3, 0.42, 0.28))
    _make_hill(Vector3(17, 2.8, -32), Vector3(13, 3.3, 9), Color(0.22, 0.34, 0.24))
    _make_hill(Vector3(31, 2.5, -10), Vector3(9, 3.0, 10), Color(0.27, 0.39, 0.26))

    _make_well(Vector3(7, 0, 6))
    _make_lantern(Vector3(-3.7, 0, -5))
    _make_lantern(Vector3(3.7, 0, -13))
    _make_lantern(Vector3(-3.7, 0, -20))
    _make_fence(Vector3(-19, 0, 1), 5)
    _make_fence(Vector3(-19, 0, 4), 5)
    _make_ground_details()

func _create_npc() -> void:
    npc = Node3D.new()
    npc.name = "MoradorDaVila"
    npc.position = Vector3(2.3, 0, -1.2)
    add_child(npc)

    var body := MeshInstance3D.new()
    var body_mesh := CapsuleMesh.new()
    body_mesh.radius = 0.34
    body_mesh.height = 1.25
    body.mesh = body_mesh
    body.position.y = 0.82
    body.material_override = _material(Color(0.18, 0.39, 0.64))
    npc.add_child(body)

    var head := MeshInstance3D.new()
    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.25
    head_mesh.height = 0.5
    head_mesh.radial_segments = 10
    head_mesh.rings = 6
    head.mesh = head_mesh
    head.position = Vector3(0, 1.58, 0)
    head.material_override = _material(Color(0.83, 0.62, 0.46))
    npc.add_child(head)

    var hair := MeshInstance3D.new()
    var hair_mesh := SphereMesh.new()
    hair_mesh.radius = 0.26
    hair_mesh.height = 0.3
    hair.mesh = hair_mesh
    hair.position = Vector3(0, 1.76, -0.015)
    hair.material_override = _material(Color(0.22, 0.14, 0.1))
    npc.add_child(hair)

    var marker := Label3D.new()
    marker.text = "MORADOR"
    marker.position = Vector3(0, 2.15, 0)
    marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    marker.font_size = 30
    marker.modulate = Color(1.0, 0.91, 0.68)
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
    if OS.get_name() == "Android" or OS.get_name() == "iOS":
        status_label.text = "AZAEL — VILA DE TESTE\nJoystick: mover | Arraste à direita: câmera | Botões: ação | SALVAR"
    else:
        status_label.text = "AZAEL — VILA DE TESTE\nWASD: mover | Mouse: câmera | E: conversar | F: atacar | F5: salvar | F9: carregar | F7: qualidade"
    status_label.add_theme_font_size_override("font_size", 16)

    if OS.get_name() == "Android" or OS.get_name() == "iOS":
        var controls_script := load("res://scripts/ui/mobile_controls.gd") as Script
        if controls_script != null:
            mobile_controls = controls_script.new() as Control
            if mobile_controls != null:
                mobile_controls.connect("action_triggered", Callable(self, "_on_mobile_action"))
                ui_layer.add_child(mobile_controls)

    information_label = Label.new()
    information_label.position = Vector2(18, 105)
    information_label.size = Vector2(640, 70)
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

func _on_mobile_action(action_name: String) -> void:
    if dialogue_open:
        return
    match action_name:
        "interact":
            _try_interact()
        "attack":
            _try_attack()
        "save":
            _save_game()


func _restore_scene_state(data: Dictionary) -> void:
    if data.has("player_position") and data["player_position"] is Array and data["player_position"].size() == 3:
        var position_data: Array = data["player_position"]
        player.position = Vector3(float(position_data[0]), float(position_data[1]), float(position_data[2]))
    if data.has("player_health"):
        player_health = clampi(int(data["player_health"]), 0, 100)


func _capture_scene_state() -> Dictionary:
    return {
        "player_position": [player.position.x, player.position.y, player.position.z],
        "player_health": player_health
    }


func _save_game() -> void:
    if SaveSystem.save_game(_capture_scene_state()):
        _refresh_status("Progresso salvo neste dispositivo.")
    else:
        _refresh_status("Não foi possível salvar. Código: %s" % error_string(SaveSystem.last_error))


func _load_game() -> void:
    var data := SaveSystem.load_game()
    if data.is_empty():
        _refresh_status("Nenhum salvamento válido foi encontrado.")
        return
    _restore_scene_state(data)
    if GameState.get_flag("training_enemy_defeated", false) and is_instance_valid(enemy):
        enemy.queue_free()
        enemy = null
    elif not GameState.get_flag("training_enemy_defeated", false) and not is_instance_valid(enemy):
        _create_enemy()
    _refresh_status("Progresso carregado.")


func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
        SaveSystem.save_game(_capture_scene_state())


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
    if not (parsed is Dictionary):
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
    if is_instance_valid(mobile_controls):
        mobile_controls.call("set_controls_enabled", false)
    player.set_process_unhandled_input(false)
    player.set_physics_process(false)
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_choice_button_pressed(option_id: String) -> void:
    for option in current_dialogue.get("options", []):
        if str(option.get("id", "")) == option_id:
            GameState.apply_choice_effects(str(current_dialogue.get("id", "unknown")), option)
            GameState.set_flag("village_first_choice_complete", true)
            last_choice_result = str(option.get("result_text", "Sua decisão foi registrada."))
            SaveSystem.save_game(_capture_scene_state())
            break

    dialogue_open = false
    dialogue_panel.visible = false
    if is_instance_valid(mobile_controls):
        mobile_controls.call("set_controls_enabled", true)
    player.set_process_unhandled_input(true)
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
    SaveSystem.save_game(_capture_scene_state())
    _refresh_status("Alvo derrotado! Primeiro teste de combate concluído.")

func _refresh_status(message: String) -> void:
    if information_label == null:
        return
    var quality_name := GraphicsSettings.get_preset_name()
    information_label.text = "Vida: %d/100 | Qualidade: %s\n%s" % [player_health, quality_name, message]

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

func _make_visual_box(node_name: String, parent: Node3D, world_position: Vector3, box_size: Vector3, color: Color, rotation_value: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = node_name
    var box_mesh := BoxMesh.new()
    box_mesh.size = box_size
    mesh_instance.mesh = box_mesh
    mesh_instance.position = world_position
    mesh_instance.rotation_degrees = rotation_value
    mesh_instance.material_override = _material(color)
    parent.add_child(mesh_instance)
    return mesh_instance

func _make_tree(world_position: Vector3, size_multiplier: float = 1.0) -> void:
    var trunk := MeshInstance3D.new()
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.16 * size_multiplier
    trunk_mesh.bottom_radius = 0.26 * size_multiplier
    trunk_mesh.height = 2.0 * size_multiplier
    trunk_mesh.radial_segments = 7
    trunk.mesh = trunk_mesh
    trunk.position = world_position + Vector3(0, size_multiplier, 0)
    trunk.material_override = _material(Color(0.31, 0.19, 0.12))
    add_child(trunk)

    var canopy_colors := [Color(0.13, 0.34, 0.19), Color(0.17, 0.42, 0.22), Color(0.22, 0.47, 0.26)]
    for layer in range(3):
        var canopy := MeshInstance3D.new()
        var cone := CylinderMesh.new()
        cone.top_radius = 0.0
        cone.bottom_radius = (1.15 - layer * 0.22) * size_multiplier
        cone.height = 1.7 * size_multiplier
        cone.radial_segments = 7
        canopy.mesh = cone
        canopy.position = world_position + Vector3(0, (2.0 + layer * 0.72) * size_multiplier, 0)
        canopy.material_override = _material(canopy_colors[layer])
        add_child(canopy)

func _material(color: Color, roughness: float = 0.9) -> StandardMaterial3D:
    var key := color.to_html(true) + "_" + str(roughness)
    if material_cache.has(key):
        return material_cache[key] as StandardMaterial3D

    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material_cache[key] = material
    return material

func _make_house(house_name: String, house_position: Vector3, size: Vector3, wall_color: Color, roof_color: Color, add_windows: bool = true) -> void:
    _make_box(house_name, house_position, size, wall_color)
    var front_z := house_position.z + size.z * 0.5 + 0.08
    var roof_y := size.y + 0.5
    _make_visual_box(house_name + "TelhadoFrente", self, Vector3(house_position.x, roof_y, house_position.z + 1.25), Vector3(size.x + 0.8, 0.34, 3.25), roof_color, Vector3(35, 0, 0))
    _make_visual_box(house_name + "TelhadoFundo", self, Vector3(house_position.x, roof_y, house_position.z - 1.25), Vector3(size.x + 0.8, 0.34, 3.25), roof_color, Vector3(-35, 0, 0))
    _make_visual_box(house_name + "Porta", self, Vector3(house_position.x, 1.15, front_z), Vector3(1.15, 2.3, 0.12), Color(0.25, 0.14, 0.09))
    _make_visual_box(house_name + "MolduraPorta", self, Vector3(house_position.x, 2.35, front_z - 0.015), Vector3(1.45, 0.14, 0.18), Color(0.78, 0.62, 0.38))
    if add_windows:
        for side in [-1.0, 1.0]:
            var window_x := house_position.x + side * 1.85
            _make_visual_box(house_name + "MolduraJanela", self, Vector3(window_x, 2.25, front_z - 0.02), Vector3(1.25, 1.15, 0.18), Color(0.3, 0.19, 0.12))
            _make_visual_box(house_name + "VidroJanela", self, Vector3(window_x, 2.25, front_z - 0.13), Vector3(0.98, 0.88, 0.04), Color(0.38, 0.63, 0.73))
    _make_visual_box(house_name + "Base", self, Vector3(house_position.x, 0.18, house_position.z + size.z * 0.5 + 0.12), Vector3(size.x + 0.15, 0.22, 0.18), Color(0.48, 0.39, 0.29))

func _make_well(world_position: Vector3) -> void:
    var base := MeshInstance3D.new()
    var base_mesh := CylinderMesh.new()
    base_mesh.top_radius = 0.86
    base_mesh.bottom_radius = 1.0
    base_mesh.height = 0.75
    base_mesh.radial_segments = 10
    base.mesh = base_mesh
    base.position = world_position + Vector3(0, 0.38, 0)
    base.material_override = _material(Color(0.42, 0.43, 0.4))
    add_child(base)

    var rim := MeshInstance3D.new()
    var rim_mesh := CylinderMesh.new()
    rim_mesh.top_radius = 0.98
    rim_mesh.bottom_radius = 0.98
    rim_mesh.height = 0.16
    rim_mesh.radial_segments = 10
    rim.mesh = rim_mesh
    rim.position = world_position + Vector3(0, 0.82, 0)
    rim.material_override = _material(Color(0.58, 0.56, 0.48))
    add_child(rim)

    var water := MeshInstance3D.new()
    var water_mesh := CylinderMesh.new()
    water_mesh.top_radius = 0.72
    water_mesh.bottom_radius = 0.72
    water_mesh.height = 0.025
    water_mesh.radial_segments = 10
    water.mesh = water_mesh
    water.position = world_position + Vector3(0, 0.88, 0)
    water.material_override = _material(Color(0.14, 0.36, 0.48), 0.25)
    add_child(water)

func _make_lantern(world_position: Vector3) -> void:
    var post := MeshInstance3D.new()
    var post_mesh := CylinderMesh.new()
    post_mesh.top_radius = 0.07
    post_mesh.bottom_radius = 0.11
    post_mesh.height = 2.25
    post_mesh.radial_segments = 6
    post.mesh = post_mesh
    post.position = world_position + Vector3(0, 1.12, 0)
    post.material_override = _material(Color(0.25, 0.17, 0.12))
    add_child(post)

    var cap := MeshInstance3D.new()
    var cap_mesh := BoxMesh.new()
    cap_mesh.size = Vector3(0.55, 0.12, 0.55)
    cap.mesh = cap_mesh
    cap.position = world_position + Vector3(0, 2.25, 0)
    cap.material_override = _material(Color(0.2, 0.14, 0.1))
    add_child(cap)

    var bulb := MeshInstance3D.new()
    var bulb_mesh := SphereMesh.new()
    bulb_mesh.radius = 0.16
    bulb_mesh.height = 0.32
    bulb.mesh = bulb_mesh
    bulb.position = world_position + Vector3(0, 1.9, 0)
    var glow := _material(Color(1.0, 0.72, 0.32), 0.35)
    glow.emission_enabled = true
    glow.emission = Color(1.0, 0.46, 0.12)
    glow.emission_energy_multiplier = 1.15
    bulb.material_override = glow
    add_child(bulb)

func _make_fence(world_position: Vector3, length: int) -> void:
    for index in range(length):
        var post := MeshInstance3D.new()
        var post_mesh := BoxMesh.new()
        post_mesh.size = Vector3(0.16, 0.9, 0.16)
        post.mesh = post_mesh
        post.position = world_position + Vector3(index * 1.0, 0.45, 0)
        post.material_override = _material(Color(0.34, 0.22, 0.14))
        add_child(post)

    var rail := MeshInstance3D.new()
    var rail_mesh := BoxMesh.new()
    rail_mesh.size = Vector3(float(length - 1), 0.14, 0.12)
    rail.mesh = rail_mesh
    rail.position = world_position + Vector3((length - 1) * 0.5, 0.65, 0)
    rail.material_override = _material(Color(0.42, 0.29, 0.18))
    add_child(rail)

func _make_ground_details() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 20261118
    var grass_transforms: Array[Transform3D] = []
    var rock_transforms: Array[Transform3D] = []
    var flower_transforms: Array[Transform3D] = []
    var attempts := 0
    while grass_transforms.size() < 110 and attempts < 900:
        attempts += 1
        var x := rng.randf_range(-28.0, 28.0)
        var z := rng.randf_range(-27.0, 27.0)
        if _is_reserved_detail_area(x, z):
            continue
        var grass_scale := Vector3(rng.randf_range(0.7, 1.4), rng.randf_range(0.45, 0.85), rng.randf_range(0.7, 1.4))
        grass_transforms.append(Transform3D(Basis.IDENTITY.scaled(grass_scale), Vector3(x, 0.12, z)))

    attempts = 0
    while rock_transforms.size() < 32 and attempts < 500:
        attempts += 1
        var x := rng.randf_range(-27.0, 27.0)
        var z := rng.randf_range(-26.0, 26.0)
        if _is_reserved_detail_area(x, z):
            continue
        var rock_scale := Vector3(rng.randf_range(0.18, 0.38), rng.randf_range(0.14, 0.26), rng.randf_range(0.18, 0.38))
        rock_transforms.append(Transform3D(Basis.IDENTITY.scaled(rock_scale), Vector3(x, rock_scale.y, z)))

    attempts = 0
    while flower_transforms.size() < 48 and attempts < 400:
        attempts += 1
        var x := rng.randf_range(-27.0, 27.0)
        var z := rng.randf_range(-26.0, 26.0)
        if _is_reserved_detail_area(x, z):
            continue
        var flower_scale := Vector3(0.6, 0.4, 0.6)
        flower_transforms.append(Transform3D(Basis.IDENTITY.scaled(flower_scale), Vector3(x, 0.08, z)))

    _add_multimesh_detail("GramaInstanciada", _make_low_poly_sphere(0.32, 0.42), grass_transforms, Color(0.35, 0.53, 0.27))
    _add_multimesh_detail("PedrasInstanciadas", _make_low_poly_sphere(0.42, 0.36), rock_transforms, Color(0.43, 0.43, 0.39))
    _add_multimesh_detail("FloresAltaQualidade", _make_low_poly_sphere(0.12, 0.12), flower_transforms, Color(0.92, 0.78, 0.42), "high_detail")

func _is_reserved_detail_area(x: float, z: float) -> bool:
    if absf(x) < 3.2 and z > -24.0 and z < 9.0:
        return true
    if x > -16.0 and x < -8.0 and z > -16.0 and z < -8.0:
        return true
    if x > 8.0 and x < 16.0 and z > -19.0 and z < -11.0:
        return true
    if x > 10.0 and x < 18.0 and z > 2.0 and z < 8.0:
        return true
    return false

func _make_low_poly_sphere(radius: float, height: float) -> SphereMesh:
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = height
    mesh.radial_segments = 6
    mesh.rings = 3
    return mesh

func _add_multimesh_detail(detail_name: String, mesh: Mesh, transforms: Array[Transform3D], color: Color, detail_group: String = "optional_detail") -> void:
    var multimesh := MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.mesh = mesh
    multimesh.instance_count = transforms.size()
    for index in range(transforms.size()):
        multimesh.set_instance_transform(index, transforms[index])

    var instance := MultiMeshInstance3D.new()
    instance.name = detail_name
    instance.multimesh = multimesh
    instance.material_override = _material(color)
    instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    instance.add_to_group(detail_group)
    add_child(instance)


func _on_quality_changed(preset_name: String) -> void:
    _refresh_status("Perfil gráfico alterado: %s." % preset_name)


func _make_hill(world_position: Vector3, hill_scale: Vector3, color: Color) -> void:
    var hill := MeshInstance3D.new()
    var hill_mesh := SphereMesh.new()
    hill_mesh.radial_segments = 8
    hill_mesh.rings = 4
    hill.mesh = hill_mesh
    hill.position = world_position
    hill.scale = hill_scale
    hill.material_override = _material(color)
    hill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(hill)
