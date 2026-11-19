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

    print("OK: joystick mapping")
    quit()
