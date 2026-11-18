extends Node
class_name DialogueController

signal dialogue_started(dialogue_id: String)
signal dialogue_finished(dialogue_id: String)
signal options_available(options: Array)

var current_dialogue: Dictionary = {}
var active: bool = false

func start_dialogue(dialogue_data: Dictionary) -> void:
    current_dialogue = dialogue_data
    active = true
    var dialogue_id := str(current_dialogue.get("id", "unknown"))
    dialogue_started.emit(dialogue_id)
    options_available.emit(current_dialogue.get("options", []))

func choose_option(option_id: String) -> void:
    if not active:
        return
    for option in current_dialogue.get("options", []):
        if str(option.get("id", "")) == option_id:
            GameState.apply_choice_effects(str(current_dialogue.get("id", "unknown")), option)
            active = false
            dialogue_finished.emit(str(current_dialogue.get("id", "unknown")))
            return
