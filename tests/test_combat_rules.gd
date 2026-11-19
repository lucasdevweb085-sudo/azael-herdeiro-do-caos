extends SceneTree

const PlayerScript := preload("res://scripts/player/player_controller.gd")
const TrainingEnemyScript := preload("res://scripts/combat/training_enemy.gd")


func _initialize() -> void:
    if not _check(PlayerScript.combo_damage_for_stage(10, 1, 1) == 10, "Dano do primeiro golpe incorreto"):
        quit(1)
        return
    if not _check(PlayerScript.combo_damage_for_stage(10, 2, 1) == 13, "Dano do segundo golpe incorreto"):
        quit(1)
        return
    if not _check(PlayerScript.combo_damage_for_stage(10, 3, 1) == 17, "Dano do terceiro golpe incorreto"):
        quit(1)
        return
    if not _check(PlayerScript.combo_damage_for_stage(10, 1, 3) == 14, "Bônus de força aplicado incorretamente"):
        quit(1)
        return
    print("OK: combo damage rules")
    call_deferred("_test_enemy_damage_boundaries")


func _test_enemy_damage_boundaries() -> void:
    var enemy = TrainingEnemyScript.new()
    root.add_child(enemy)
    await process_frame

    enemy.call("take_damage", 10)
    var health_after_hit := int(enemy.get("health"))
    enemy.call("take_damage", -5)
    if not _check(int(enemy.get("health")) == health_after_hit, "Dano negativo não pode curar o inimigo"):
        quit(1)
        return

    var defeated_count := [0]
    enemy.connect("defeated", func() -> void: defeated_count[0] += 1)
    enemy.call("take_damage", 100)
    enemy.call("take_damage", 1)
    if not _check(int(defeated_count[0]) == 1, "Inimigo derrotado não pode emitir derrotado novamente"):
        quit(1)
        return

    print("OK: enemy damage boundaries")
    quit()



func _check(condition: bool, message: String) -> bool:
    if not condition:
        push_error(message)
        return false
    return true
