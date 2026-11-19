extends CharacterBody3D
class_name TrainingEnemy

signal player_hit(damage: int)
signal attack_windup_started
signal defeated

@export var max_health: int = 40
@export var move_speed: float = 2.0
@export var attack_range: float = 1.8
@export var attack_damage: int = 5
@export var attack_windup_time: float = 0.55

var health: int = 40
var attack_timer: float = 0.0
var windup_timer: float = 0.0
var target: Node3D

func _ready() -> void:
    health = max_health
    target = get_parent().get_node_or_null("Player") as Node3D

func _physics_process(delta: float) -> void:
    attack_timer = maxf(attack_timer - delta, 0.0)

    if not is_instance_valid(target):
        return

    if windup_timer > 0.0:
        windup_timer -= delta
        velocity.x = 0.0
        velocity.z = 0.0
        _apply_gravity(delta)
        move_and_slide()
        if windup_timer <= 0.0:
            player_hit.emit(attack_damage)
            attack_timer = 1.25
        return

    var offset: Vector3 = target.global_position - global_position
    var flat_offset := Vector3(offset.x, 0.0, offset.z)
    var distance := flat_offset.length()

    if distance <= attack_range and attack_timer <= 0.0:
        windup_timer = attack_windup_time
        attack_windup_started.emit()
        velocity.x = 0.0
        velocity.z = 0.0
    elif distance < 12.0 and distance > attack_range:
        var direction := flat_offset.normalized()
        velocity.x = direction.x * move_speed
        velocity.z = direction.z * move_speed
    else:
        velocity.x = move_toward(velocity.x, 0.0, move_speed * 3.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, move_speed * 3.0 * delta)

    _apply_gravity(delta)
    move_and_slide()


func _apply_gravity(delta: float) -> void:
    if is_on_floor():
        velocity.y = 0.0
    else:
        velocity.y -= 18.0 * delta

func take_damage(amount: int) -> void:
    if health <= 0:
        return

    health = maxi(health - maxi(amount, 0), 0)
    if health == 0:
        defeated.emit()
        queue_free()
