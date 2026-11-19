extends SceneTree

const SaveSystemScript := preload("res://scripts/core/save_system.gd")
const GameStateScript := preload("res://scripts/core/game_state.gd")


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

    if not _test_save_load_round_trip():
        quit(1)
        return

    print("OK: save payload, keyboard shortcuts and save/load round trip")
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


func _test_save_load_round_trip() -> bool:
    var game_state = GameStateScript.new()
    game_state.name = "GameState"
    root.add_child(game_state)

    var save_system = SaveSystemScript.new()
    save_system.name = "SaveSystem"
    root.add_child(save_system)

    game_state.call("set_flag", "save_round_trip_flag", true)
    game_state.call("change_relationship", "village", 3)
    game_state.call("record_decision", "test_dialogue", "help")

    if not _check(bool(save_system.call("save_game", {"player_health": 73})), "SaveSystem.save_game falhou"):
        return false

    game_state.call("set_flag", "save_round_trip_flag", false)
    game_state.call("change_relationship", "village", -3)
    var decisions: Array = game_state.get("decisions")
    decisions.clear()

    var loaded_extra: Dictionary = save_system.call("load_game")
    if not _check(int(loaded_extra.get("player_health", 0)) == 73, "Dado extra da cena não foi recuperado"):
        return false
    if not _check(bool(game_state.call("get_flag", "save_round_trip_flag", false)), "Flag de história não foi recuperada"):
        return false
    if not _check(int(game_state.get("relationships").get("village", 0)) == 3, "Relação não foi recuperada"):
        return false

    var restored_decisions: Array = game_state.get("decisions")
    if not _check(restored_decisions.size() == 1, "Decisão não foi recuperada"):
        return false
    if not _check(str(restored_decisions[0].get("option_id", "")) == "help", "Opção escolhida não foi recuperada"):
        return false

    var save_path := ProjectSettings.globalize_path("user://azael_save.json")
    if FileAccess.file_exists("user://azael_save.json"):
        DirAccess.remove_absolute(save_path)
    game_state.queue_free()
    save_system.queue_free()
    return true


func _check(condition: bool, message: String) -> bool:
    if not condition:
        push_error(message)
        return false
    return true
