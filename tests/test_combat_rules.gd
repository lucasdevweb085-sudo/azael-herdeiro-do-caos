extends SceneTree

const PlayerScript := preload("res://scripts/player/player_controller.gd")


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
    quit()


func _check(condition: bool, message: String) -> bool:
    if not condition:
        push_error(message)
        return false
    return true
