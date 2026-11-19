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

    var controls := MobileControlsScript.new()
    root.add_child(controls)
    controls.call("_set_held_action", "block", true)
    if not _check(Input.is_action_pressed("block"), "Botão de defesa deve ativar a ação enquanto pressionado"):
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
