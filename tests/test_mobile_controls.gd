extends SceneTree

const MobileControlsScript := preload("res://scripts/ui/mobile_controls.gd")


func _initialize() -> void:
    var up := MobileControlsScript.vector_to_strengths(Vector2(0.0, -1.0))
    assert(is_equal_approx(up["move_forward"], 1.0))
    assert(is_equal_approx(up["move_back"], 0.0))

    var right := MobileControlsScript.vector_to_strengths(Vector2(1.0, 0.0))
    assert(is_equal_approx(right["move_right"], 1.0))
    assert(is_equal_approx(right["move_left"], 0.0))

    var diagonal := MobileControlsScript.vector_to_strengths(Vector2(1.0, -1.0))
    assert(is_equal_approx(diagonal["move_right"], 0.70710678))
    assert(is_equal_approx(diagonal["move_forward"], 0.70710678))

    var overextended := MobileControlsScript.vector_to_strengths(Vector2(0.0, -2.0))
    assert(is_equal_approx(overextended["move_forward"], 1.0))

    call_deferred("_test_hold_button")


func _test_hold_button() -> void:
    var controls := MobileControlsScript.new() as Control
    root.add_child(controls)
    await process_frame

    var emitted_actions: Array[String] = []
    var on_action := func(action_name: String) -> void:
        emitted_actions.append(action_name)
    controls.action_triggered.connect(on_action)

    var action_row := controls.get_node("ActionButtons") as HBoxContainer
    var defend_button := action_row.get_child(3) as Button
    defend_button.pressed.emit()
    assert(emitted_actions.is_empty(), "DEFENDER não deve emitir uma ação de toque único")

    defend_button.button_down.emit()
    assert(Input.is_action_pressed("block"), "DEFENDER deve ativar a defesa enquanto pressionado")
    controls.set_controls_enabled(false)
    assert(not Input.is_action_pressed("block"), "Desativar controles deve liberar a defesa")

    controls.queue_free()
    print("OK: joystick mapping and hold button")
    quit()
