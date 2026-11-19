extends SceneTree

const SaveSystemScript := preload("res://scripts/core/save_system.gd")


func _initialize() -> void:
    var valid_payload := {
        "version": 1,
        "game_state": {},
        "extra_state": {}
    }
    if not _check(SaveSystemScript.is_valid_payload(valid_payload), "Payload válido foi rejeitado"):
        quit(1)
        return
    if not _check(not SaveSystemScript.is_valid_payload({"version": 2, "game_state": {}, "extra_state": {}}), "Versão incompatível foi aceita"):
        quit(1)
        return
    if not _check(not SaveSystemScript.is_valid_payload({"version": 1, "game_state": []}), "game_state inválido foi aceito"):
        quit(1)
        return
    if not _check(not SaveSystemScript.is_valid_payload("invalid"), "Payload que não é dicionário foi aceito"):
        quit(1)
        return

    if not _assert_key_action("save_game", KEY_F5):
        quit(1)
        return
    if not _assert_key_action("load_game", KEY_F9):
        quit(1)
        return
    if not _assert_key_action("block", KEY_SHIFT):
        quit(1)
        return
    if not _assert_key_action("dodge", KEY_Q):
        quit(1)
        return
    if not _assert_key_action("interact", KEY_E):
        quit(1)
        return
    if not _assert_key_action("attack", KEY_F):
        quit(1)
        return

    print("OK: save payload validation and keyboard shortcuts")
    quit()


func _assert_key_action(action_name: StringName, expected_key: int) -> bool:
    if not _check(InputMap.has_action(action_name), "A ação %s não existe" % action_name):
        return false
    var events := InputMap.action_get_events(action_name)
    if not _check(not events.is_empty(), "A ação %s não tem eventos" % action_name):
        return false
    if not _check(events[0] is InputEventKey, "A ação %s não usa teclado" % action_name):
        return false
    return _check((events[0] as InputEventKey).physical_keycode == expected_key, "Tecla incorreta na ação %s" % action_name)


func _check(condition: bool, message: String) -> bool:
    if not condition:
        push_error(message)
        return false
    return true
