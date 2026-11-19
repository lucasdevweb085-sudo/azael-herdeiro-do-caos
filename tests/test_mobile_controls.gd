extends SceneTree

const MobileControlsScript := preload("res://scripts/ui/mobile_controls.gd")


func _initialize() -> void:
    var up := MobileControlsScript.vector_to_strengths(Vector2(0.0, -1.0))
    if not _check(is_equal_approx(up["move_forward"], 1.0) and is_equal_approx(up["move_back"], 0.0), "Joystick não mapeou a direção para cima"):
        quit(1)
        return

    var right := MobileControlsScript.vector_to_strengths(Vector2(1.0, 0.0))
    if not _check(is_equal_approx(right["move_right"], 1.0) and is_equal_approx(right["move_left"], 0.0), "Joystick não mapeou a direção para a direita"):
        quit(1)
        return

    var diagonal := MobileControlsScript.vector_to_strengths(Vector2(1.0, -1.0))
    if not _check(is_equal_approx(diagonal["move_right"], 0.70710678) and is_equal_approx(diagonal["move_forward"], 0.70710678), "Diagonal do joystick não foi normalizada"):
        quit(1)
        return

    var overextended := MobileControlsScript.vector_to_strengths(Vector2(0.0, -2.0))
    if not _check(is_equal_approx(overextended["move_forward"], 1.0), "Joystick ultrapassou a força máxima"):
        quit(1)
        return

    var controls := MobileControlsScript.new()
    root.add_child(controls)

    var emitted_actions: Array[String] = []
    var on_action := func(action_name: String) -> void:
        emitted_actions.append(action_name)
    controls.action_triggered.connect(on_action)

    var action_row := controls.get_node("ActionButtons") as HBoxContainer
    var defend_button := action_row.get_child(3) as Button
    defend_button.pressed.emit()
    if not _check(emitted_actions.is_empty(), "DEFENDER não deve emitir uma ação de toque único"):
        controls.queue_free()
        quit(1)
        return

    defend_button.button_down.emit()
    if not _check(Input.is_action_pressed("block"), "DEFENDER deve ativar a defesa enquanto pressionado"):
        controls.queue_free()
        quit(1)
        return

    controls.call("_release_joystick")
    if not _check(Input.is_action_pressed("block"), "Soltar o joystick não pode cancelar a defesa mantida por outro dedo"):
        controls.queue_free()
        quit(1)
        return

    controls.set_controls_enabled(false)
    if not _check(not Input.is_action_pressed("block"), "Desativar controles deve liberar a defesa"):
        controls.queue_free()
        quit(1)
        return

    controls.queue_free()
    print("OK: joystick mapping and independent hold-button state")
    quit()


func _check(condition: bool, message: String) -> bool:
    if not condition:
        push_error(message)
        return false
    return true
