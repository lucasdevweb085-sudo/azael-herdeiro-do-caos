extends SceneTree

const SaveSystemScript := preload("res://scripts/core/save_system.gd")


func _initialize() -> void:
    var valid_payload := {
        "version": 1,
        "game_state": {},
        "extra_state": {}
    }
    assert(SaveSystemScript.is_valid_payload(valid_payload))
    assert(not SaveSystemScript.is_valid_payload({"version": 2, "game_state": {}, "extra_state": {}}))
    assert(not SaveSystemScript.is_valid_payload({"version": 1, "game_state": []}))
    assert(not SaveSystemScript.is_valid_payload("invalid"))
    print("OK: save payload validation")
    quit()
