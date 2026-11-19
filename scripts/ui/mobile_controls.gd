extends Control
class_name MobileControls

signal action_triggered(action_name: String)

const MOVEMENT_ACTIONS := ["move_left", "move_right", "move_forward", "move_back"]
const JOYSTICK_MAX_DISTANCE := 54.0

class VirtualJoystick extends Control:
    var knob_offset: Vector2 = Vector2.ZERO

    func _ready() -> void:
        custom_minimum_size = Vector2(164.0, 164.0)
        mouse_filter = Control.MOUSE_FILTER_IGNORE

    func update_from_screen_position(screen_position: Vector2) -> Vector2:
        var center := get_global_rect().get_center()
        knob_offset = (screen_position - center).limit_length(MobileControls.JOYSTICK_MAX_DISTANCE)
        queue_redraw()
        return knob_offset / MobileControls.JOYSTICK_MAX_DISTANCE

    func reset() -> void:
        knob_offset = Vector2.ZERO
        queue_redraw()

    func _draw() -> void:
        var center := size * 0.5
        draw_circle(center, 66.0, Color(0.035, 0.055, 0.08, 0.48))
        draw_arc(center, 66.0, 0.0, TAU, 56, Color(0.84, 0.72, 0.48, 0.72), 3.0, true)
        draw_circle(center + knob_offset, 28.0, Color(0.10, 0.14, 0.18, 0.9))
        draw_arc(center + knob_offset, 28.0, 0.0, TAU, 32, Color(1.0, 0.84, 0.56, 0.95), 2.0, true)


var joystick: VirtualJoystick
var joystick_touch_index: int = -1
var controls_enabled: bool = true


static func vector_to_strengths(direction: Vector2) -> Dictionary:
    var normalized := direction.limit_length(1.0)
    return {
        "move_left": maxf(-normalized.x, 0.0),
        "move_right": maxf(normalized.x, 0.0),
        "move_forward": maxf(-normalized.y, 0.0),
        "move_back": maxf(normalized.y, 0.0)
    }


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _build_joystick()
    _build_action_buttons()
    _build_save_button()


func _input(event: InputEvent) -> void:
    if not controls_enabled:
        return

    if event is InputEventScreenTouch:
        if event.pressed and joystick_touch_index == -1 and joystick.get_global_rect().has_point(event.position):
            joystick_touch_index = event.index
            _update_joystick(event.position)
            get_viewport().set_input_as_handled()
        elif (not event.pressed or event.canceled) and event.index == joystick_touch_index:
            _release_joystick()
            get_viewport().set_input_as_handled()
    elif event is InputEventScreenDrag and event.index == joystick_touch_index:
        _update_joystick(event.position)
        get_viewport().set_input_as_handled()


func _build_joystick() -> void:
    joystick = VirtualJoystick.new()
    joystick.name = "VirtualJoystick"
    joystick.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
    joystick.offset_left = 24.0
    joystick.offset_top = -188.0
    joystick.offset_right = 188.0
    joystick.offset_bottom = -24.0
    add_child(joystick)


func _build_action_buttons() -> void:
    var row := HBoxContainer.new()
    row.name = "ActionButtons"
    row.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
    row.offset_left = -360.0
    row.offset_top = -112.0
    row.offset_right = -20.0
    row.offset_bottom = -20.0
    row.add_theme_constant_override("separation", 12)
    add_child(row)

    row.add_child(_create_action_button("INTERAGIR", "interact"))
    row.add_child(_create_action_button("ATACAR", "attack"))
    row.add_child(_create_action_button("ESQUIVAR", "dodge"))
    row.add_child(_create_hold_button("DEFENDER", "block"))


func _create_action_button(label_text: String, action_name: String) -> Button:
    var button := Button.new()
    button.text = label_text
    button.custom_minimum_size = Vector2(94.0, 84.0)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.focus_mode = Control.FOCUS_NONE
    button.add_theme_font_size_override("font_size", 14)

    var normal_style := StyleBoxFlat.new()
    normal_style.bg_color = Color(0.035, 0.06, 0.09, 0.78)
    normal_style.border_color = Color(0.84, 0.70, 0.44, 0.95)
    normal_style.set_border_width_all(2)
    normal_style.set_corner_radius_all(18)
    normal_style.content_margin_left = 8.0
    normal_style.content_margin_right = 8.0
    button.add_theme_stylebox_override("normal", normal_style)

    var pressed_style := normal_style.duplicate() as StyleBoxFlat
    pressed_style.bg_color = Color(0.22, 0.17, 0.10, 0.92)
    button.add_theme_stylebox_override("pressed", pressed_style)
    button.pressed.connect(_emit_action.bind(action_name))
    return button



func _create_hold_button(label_text: String, action_name: String) -> Button:
    var button := _create_action_button(label_text, "")
    button.pressed.disconnect(_emit_action)
    button.button_down.connect(_set_held_action.bind(action_name, true))
    button.button_up.connect(_set_held_action.bind(action_name, false))
    return button


func _set_held_action(action_name: String, pressed: bool) -> void:
    if pressed and controls_enabled:
        Input.action_press(StringName(action_name))
    else:
        Input.action_release(StringName(action_name))


func _emit_action(action_name: String) -> void:
    if controls_enabled:
        action_triggered.emit(action_name)


func _update_joystick(screen_position: Vector2) -> void:
    var strengths := vector_to_strengths(joystick.update_from_screen_position(screen_position))
    for action_name in strengths:
        var strength := float(strengths[action_name])
        if strength > 0.001:
            Input.action_press(StringName(action_name), strength)
        else:
            Input.action_release(StringName(action_name))


func _release_joystick() -> void:
    joystick_touch_index = -1
    if is_instance_valid(joystick):
        joystick.reset()
    for action_name in MOVEMENT_ACTIONS:
        Input.action_release(action_name)
    Input.action_release("block")


func set_controls_enabled(enabled: bool) -> void:
    controls_enabled = enabled
    set_process_input(enabled)
    visible = enabled
    if not enabled:
        _release_joystick()


func _notification(what: int) -> void:
    if what == NOTIFICATION_PREDELETE or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        for action_name in MOVEMENT_ACTIONS:
            Input.action_release(action_name)
        Input.action_release("block")


func _build_save_button() -> void:
    var button := _create_action_button("SALVAR", "save")
    button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    button.offset_left = -112.0
    button.offset_top = 20.0
    button.offset_right = -20.0
    button.offset_bottom = 66.0
    button.custom_minimum_size = Vector2(92.0, 46.0)
    add_child(button)
