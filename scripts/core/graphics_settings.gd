extends Node
## Perfis leves de qualidade para manter a mesma arte em aparelhos diferentes.

enum Preset { PERFORMANCE, BALANCED, HIGH }

signal quality_changed(preset_name: String)

var current_preset: int = Preset.BALANCED
var is_mobile: bool = false

func _ready() -> void:
    is_mobile = OS.get_name() == "Android" or OS.get_name() == "iOS"
    current_preset = Preset.BALANCED if is_mobile else Preset.HIGH
    apply_recommended()

func apply_recommended() -> void:
    apply_preset(current_preset)

func apply_preset(preset: int) -> void:
    current_preset = clampi(preset, Preset.PERFORMANCE, Preset.HIGH)

    match current_preset:
        Preset.PERFORMANCE:
            Engine.max_fps = 45
        Preset.BALANCED:
            Engine.max_fps = 60
        Preset.HIGH:
            Engine.max_fps = 60

    var shadows_enabled := current_preset != Preset.PERFORMANCE
    for light in get_tree().get_nodes_in_group("main_sun"):
        if light is DirectionalLight3D:
            light.shadow_enabled = shadows_enabled

    var show_optional_detail := current_preset != Preset.PERFORMANCE
    for detail in get_tree().get_nodes_in_group("optional_detail"):
        if detail is VisualInstance3D:
            detail.visible = show_optional_detail

    quality_changed.emit(get_preset_name())

func cycle_preset() -> void:
    var next_preset := (current_preset + 1) % 3
    apply_preset(next_preset)

func get_preset_name() -> String:
    match current_preset:
        Preset.PERFORMANCE:
            return "Desempenho"
        Preset.BALANCED:
            return "Equilibrado"
        Preset.HIGH:
            return "Alto"
    return "Equilibrado"

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F7:
        cycle_preset()
        get_viewport().set_input_as_handled()
