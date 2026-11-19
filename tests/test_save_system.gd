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

    assert(InputMap.has_action("save_game"))
    assert(InputMap.has_action("load_game"))
    var save_events := InputMap.action_get_events("save_game")
    var load_events := InputMap.action_get_events("load_game")
    assert(not save_events.is_empty())
    assert(not load_events.is_empty())
    assert(save_events[0] is InputEventKey)
    assert(load_events[0] is InputEventKey)
    assert((save_events[0] as InputEventKey).physical_keycode == KEY_F5)
    assert((load_events[0] as InputEventKey).physical_keycode == KEY_F9)

    print("OK: save payload validation and keyboard shortcuts")
    quit()
