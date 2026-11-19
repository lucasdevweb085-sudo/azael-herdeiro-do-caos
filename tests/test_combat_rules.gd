extends SceneTree

const PlayerScript := preload("res://scripts/player/player_controller.gd")


func _initialize() -> void:
    assert(PlayerScript.combo_damage_for_stage(10, 1, 1) == 10)
    assert(PlayerScript.combo_damage_for_stage(10, 2, 1) == 13)
    assert(PlayerScript.combo_damage_for_stage(10, 3, 1) == 17)
    assert(PlayerScript.combo_damage_for_stage(10, 1, 3) == 14)
    print("OK: combo damage rules")
    quit()
