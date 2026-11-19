
extends Node
## Salvamento local versionado. Os dados ficam no dispositivo do jogador.

const SAVE_PATH := "user://azael_save.json"
const SAVE_VERSION := 1

signal save_completed
signal load_completed

var last_error: Error = OK


static func is_valid_payload(payload: Variant) -> bool:
    if not (payload is Dictionary):
        return false
    if not payload.has("version"):
        return false
    var version_value: Variant = payload["version"]
    if typeof(version_value) != TYPE_INT and typeof(version_value) != TYPE_FLOAT:
        return false
    if float(version_value) != float(SAVE_VERSION):
        return false
    if not payload.has("game_state") or not payload.has("extra_state"):
        return false
    return payload["game_state"] is Dictionary and payload["extra_state"] is Dictionary


func has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)


func save_game(extra_state: Dictionary = {}) -> bool:
    var game_state := get_tree().root.get_node_or_null("GameState")
    if game_state == null or not game_state.has_method("export_state"):
        last_error = ERR_DOES_NOT_EXIST
        push_error("AZAEL: o autoload GameState não está disponível para salvar.")
        return false

    var payload := {
        "version": SAVE_VERSION,
        "saved_at": Time.get_datetime_string_from_system(),
        "game_state": game_state.call("export_state"),
        "extra_state": extra_state.duplicate(true)
    }

    var root := get_tree().root
    var quest_manager := root.get_node_or_null("QuestManager")
    if quest_manager != null and quest_manager.has_method("export_state"):
        payload["quest_state"] = quest_manager.call("export_state")

    var progression := root.get_node_or_null("CharacterProgression")
    if progression != null and progression.has_method("export_state"):
        payload["progression_state"] = progression.call("export_state")

    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        last_error = FileAccess.get_open_error()
        push_error("AZAEL: não foi possível abrir o arquivo de salvamento: %s" % error_string(last_error))
        return false

    file.store_string(JSON.stringify(payload, "\t"))
    file.flush()
    last_error = file.get_error()
    file.close()
    if last_error != OK and last_error != ERR_FILE_EOF:
        push_error("AZAEL: falha ao gravar o salvamento: %s" % error_string(last_error))
        return false

    save_completed.emit()
    return true


func load_game() -> Dictionary:
    if not has_save():
        last_error = ERR_FILE_NOT_FOUND
        return {}

    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        last_error = FileAccess.get_open_error()
        push_error("AZAEL: não foi possível ler o salvamento: %s" % error_string(last_error))
        return {}

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if not is_valid_payload(parsed):
        last_error = ERR_FILE_CORRUPT
        push_error("AZAEL: arquivo de salvamento inválido ou de versão incompatível.")
        return {}

    var game_state := get_tree().root.get_node_or_null("GameState")
    if game_state == null or not game_state.has_method("import_state"):
        last_error = ERR_DOES_NOT_EXIST
        push_error("AZAEL: o autoload GameState não está disponível para carregar.")
        return {}
    game_state.call("import_state", parsed.get("game_state", {}))

    var root := get_tree().root
    var quest_manager := root.get_node_or_null("QuestManager")
    if quest_manager != null and quest_manager.has_method("import_state") and parsed.get("quest_state") is Dictionary:
        quest_manager.call("import_state", parsed["quest_state"])

    var progression := root.get_node_or_null("CharacterProgression")
    if progression != null and progression.has_method("import_state") and parsed.get("progression_state") is Dictionary:
        progression.call("import_state", parsed["progression_state"])

    last_error = OK
    load_completed.emit()
    var extra: Variant = parsed.get("extra_state", {})
    return extra.duplicate(true) if extra is Dictionary else {}
