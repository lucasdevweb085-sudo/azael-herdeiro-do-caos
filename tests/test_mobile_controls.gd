extends SceneTree

const MobileControlsScript := preload("res://scripts/ui/mobile_controls.gd")


func _initialize() -> void:
    var up := MobileControlsScript.vector_to_strengths(Vector2(0.0, -1.0))
    if not _check(is_equal_approx(up["move_forward"], 1.0) and is_equal_approx(up["move_back"], 0.0), "Joystick não mapeou para cima"):
        quit(1)
        return

    var right := MobileControlsScript.vector_to_strengths(Vector2(1.0, 0.0))
    if not _check(is_equal_approx(right["move_right"], 1.0) and is_equal_approx(right["move_left"], 0.0), "Joystick não mapeou para a direita"):
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

    call_deferred("_test_action_buttons")


func _test_action_buttons() -> void:
    var controls := MobileControlsScript.new()
    root.add_child(controls)
    await process_frame

    var action_row := controls.get_node_or_null("ActionButtons") as HBoxContainer
    if not _check(action_row != null and action_row.get_child_count() == 4, "Os quatro botões de ação precisam ser criados"):
        controls.queue_free()
        quit(1)
        return

    var defend_button := action_row.get_child(3) as Button
    defend_button.button_down.emit()
    if not _check(Input.is_action_pressed("block"), "Botão DEFENDER deve ativar a ação ao ser pressionado"):
        controls.queue_free()
        quit(1)
        return

    controls.call("_release_joystick")
    if not _check(Input.is_action_pressed("block"), "Soltar o joystick não pode cancelar a defesa mantida por outro dedo"):
        controls.queue_free()
        quit(1)
        return

    defend_button.button_up.emit()
    if not _check(not Input.is_action_pressed("block"), "Soltar DEFENDER deve liberar a ação de defesa"):
        controls.queue_free()
        quit(1)
        return

    defend_button.button_down.emit()
    controls.set_controls_enabled(false)
    if not _check(not Input.is_action_pressed("block"), "Desativar controles deve liberar a defesa"):
        controls.queue_free()
        quit(1)
        return

    controls.queue_free()
    print("OK: joystick mapping and real hold-button signals")
    quit()


func _check(condition: bool, message: String) -> bool:
    if not condition:
        push_error(message)
        return false
    return true
