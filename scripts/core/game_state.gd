extends Node
## Estado global de história, persistido localmente pelo SaveSystem.

var story_flags: Dictionary = {}
var relationships: Dictionary = {}
var decisions: Array[Dictionary] = []

signal story_flag_changed(flag_name: String, value: Variant)
signal relationship_changed(character_id: String, value: int)

func set_flag(flag_name: String, value: Variant = true) -> void:
    story_flags[flag_name] = value
    story_flag_changed.emit(flag_name, value)

func get_flag(flag_name: String, default_value: Variant = false) -> Variant:
    return story_flags.get(flag_name, default_value)

func change_relationship(character_id: String, amount: int) -> void:
    relationships[character_id] = int(relationships.get(character_id, 0)) + amount
    relationship_changed.emit(character_id, relationships[character_id])

func record_decision(dialogue_id: String, option_id: String) -> void:
    decisions.append({
        "dialogue_id": dialogue_id,
        "option_id": option_id,
        "sequence": decisions.size() + 1
    })

func apply_choice_effects(dialogue_id: String, option: Dictionary) -> void:
    record_decision(dialogue_id, str(option.get("id", "unknown")))
    for flag in option.get("set_flags", []):
        set_flag(str(flag), true)
    for change in option.get("relationship_changes", []):
        change_relationship(str(change.get("character", "unknown")), int(change.get("amount", 0)))


func export_state() -> Dictionary:
    return {
        "story_flags": story_flags.duplicate(true),
        "relationships": relationships.duplicate(true),
        "decisions": decisions.duplicate(true)
    }


func import_state(data: Dictionary) -> void:
    var flags: Variant = data.get("story_flags", {})
    var relation_data: Variant = data.get("relationships", {})
    var decision_data: Variant = data.get("decisions", [])

    story_flags = flags.duplicate(true) if flags is Dictionary else {}
    relationships = relation_data.duplicate(true) if relation_data is Dictionary else {}

    decisions.clear()
    if decision_data is Array:
        for decision in decision_data:
            if decision is Dictionary:
                decisions.append(decision.duplicate(true))
