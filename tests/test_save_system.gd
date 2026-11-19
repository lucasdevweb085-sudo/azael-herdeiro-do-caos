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

    _assert_key_action("save_game", KEY_F5)
    _assert_key_action("load_game", KEY_F9)
    _assert_key_action("block", KEY_SHIFT)
    _assert_key_action("dodge", KEY_Q)
    _assert_key_action("interact", KEY_E)
    _assert_key_action("attack", KEY_F)

    print("OK: save payload validation and keyboard shortcuts")
    quit()


func _assert_key_action(action_name: StringName, expected_key: Key) -> void:
    assert(InputMap.has_action(action_name), "A ação %s precisa existir" % action_name)
    var events := InputMap.action_get_events(action_name)
    assert(not events.is_empty(), "A ação %s precisa ter uma tecla" % action_name)
    assert(events[0] is InputEventKey, "A ação %s precisa usar teclado" % action_name)
    assert((events[0] as InputEventKey).physical_keycode == expected_key, "Tecla incorreta na ação %s" % action_name)
