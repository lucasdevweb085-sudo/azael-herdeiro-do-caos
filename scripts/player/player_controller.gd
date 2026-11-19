extends CharacterBody3D
class_name PlayerController

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var gravity: float = 18.0
@export var mouse_sensitivity: float = 0.003

@onready var spring_arm: SpringArm3D = $SpringArm3D
var camera_pitch: float = -0.22

var stamina: float = 100.0
var is_blocking: bool = false
var dodge_time_remaining: float = 0.0
var dodge_cooldown_remaining: float = 0.0
var invulnerability_time_remaining: float = 0.0
var combo_time_remaining: float = 0.0
var combo_stage: int = 0
var dodge_direction: Vector3 = Vector3.ZERO

func _ready() -> void:
    if OS.get_name() != "Android" and OS.get_name() != "iOS":
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    spring_arm.rotation.x = camera_pitch

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        _rotate_camera(event.relative)
    elif event is InputEventScreenDrag:
        var viewport_size := get_viewport().get_visible_rect().size
        if event.position.x >= viewport_size.x * 0.42 and event.position.y <= viewport_size.y - 150.0:
            _rotate_camera(event.screen_relative)
    elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED


func _rotate_camera(delta_position: Vector2) -> void:
    rotate_y(-delta_position.x * mouse_sensitivity)
    camera_pitch = clampf(camera_pitch - delta_position.y * mouse_sensitivity, deg_to_rad(-55.0), deg_to_rad(25.0))
    spring_arm.rotation.x = camera_pitch

func _physics_process(delta: float) -> void:
    dodge_cooldown_remaining = maxf(dodge_cooldown_remaining - delta, 0.0)
    invulnerability_time_remaining = maxf(invulnerability_time_remaining - delta, 0.0)
    combo_time_remaining = maxf(combo_time_remaining - delta, 0.0)
    if combo_time_remaining <= 0.0:
        combo_stage = 0

    is_blocking = Input.is_action_pressed("block") and stamina > 0.0
    if is_blocking:
        stamina = maxf(stamina - 28.0 * delta, 0.0)
    else:
        stamina = minf(stamina + 18.0 * delta, 100.0)

    var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if Input.is_action_just_pressed("dodge"):
        perform_dodge(input_vector)

    if dodge_time_remaining > 0.0:
        dodge_time_remaining = maxf(dodge_time_remaining - delta, 0.0)
        velocity.x = dodge_direction.x * move_speed * 2.7
        velocity.z = dodge_direction.z * move_speed * 2.7
        _apply_gravity(delta)
        move_and_slide()
        return

    var direction := (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
    var current_speed := move_speed * (0.42 if is_blocking else 1.0)
    if direction.length() > 0.01:
        velocity.x = move_toward(velocity.x, direction.x * current_speed, acceleration * delta)
        velocity.z = move_toward(velocity.z, direction.z * current_speed, acceleration * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
        velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
    _apply_gravity(delta)
    move_and_slide()


func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0.0


func perform_dodge(input_vector: Vector2 = Vector2.ZERO) -> bool:
    if dodge_cooldown_remaining > 0.0 or stamina < 25.0:
        return false
    var direction := transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)
    if direction.length() < 0.1:
        direction = -global_transform.basis.z
    dodge_direction = direction.normalized()
    stamina -= 25.0
    dodge_time_remaining = 0.22
    dodge_cooldown_remaining = 0.85
    invulnerability_time_remaining = 0.32
    is_blocking = false
    return true


func receive_hit(incoming_damage: int) -> int:
    if invulnerability_time_remaining > 0.0:
        return 0
    if is_blocking and stamina >= 15.0:
        stamina -= 15.0
        return maxi(1, roundi(float(incoming_damage) * 0.25))
    is_blocking = false
    return maxi(incoming_damage, 0)


static func combo_damage_for_stage(base_damage: int, stage: int, strength_rank: int = 1) -> int:
    var multipliers := [1.0, 1.3, 1.65]
    var safe_stage := clampi(stage, 1, multipliers.size())
    return roundi(float(base_damage) * multipliers[safe_stage - 1]) + maxi(strength_rank - 1, 0) * 2


func get_combo_attack_damage(base_damage: int) -> int:
    combo_stage = (combo_stage % 3) + 1 if combo_time_remaining > 0.0 else 1
    combo_time_remaining = 0.85
    var strength_rank := 1
    var progression := get_node_or_null("/root/CharacterProgression")
    if progression != null and progression.has_method("get_attribute"):
        strength_rank = int(progression.call("get_attribute", "azael", "strength"))
    return combo_damage_for_stage(base_damage, combo_stage, strength_rank)
