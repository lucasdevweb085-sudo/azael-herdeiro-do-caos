# Controles Android Implementation Plan

> **For agentic workers:** Execute the single task in order, with a focused check after each change.

**Goal:** Add a touch joystick, touch camera drag, and on-screen interaction/attack buttons while preserving keyboard and mouse controls.

**Architecture:** A small Control script is added to the existing HUD only on Android/iOS. The joystick feeds the existing Input Map movement actions; action buttons call the same world interaction/attack methods used by keyboard actions. Camera drag is handled by the player controller only in the right-side gameplay area.

**Tech Stack:** Godot 4.x, GDScript, native Control/Input APIs.

**Spec:** Existing project requirements in `docs/VISAO_DO_PROJETO.md` and `docs/ARQUITETURA_INICIAL.md`.

## Global Constraints

- Android is the priority platform; do not add third-party dependencies.
- Existing WASD and mouse controls must continue working on desktop.
- The touch UI must not appear on desktop.
- Dialogue must disable the movement joystick and action buttons while it is open.
- Dodge and skill behavior remain out of scope until the combat improvement.
- No claims of runtime success without a Godot run.

## Review Focus

- Touch cancellation/release must reset every movement action.
- Simultaneous fingers must not steal joystick ownership.
- Touch camera drag must not rotate the camera when starting on UI controls.
- Dialogue opening must disable touch controls and release movement.
- Small screens must keep joystick and buttons anchored inside the viewport.

## Task 1: Add the first Android touch-control slice

**Files:**
- Create: `scripts/ui/mobile_controls.gd` — touch joystick, action buttons, and action mapping helper.
- Modify: `project.godot` — add keyboard Input Map actions for interact and attack.
- Modify: `scripts/player/player_controller.gd` — support right-side touch camera drag.
- Modify: `scripts/world/demo_village.gd` — poll Input actions and connect mobile button actions.
- Create: `tests/test_mobile_controls.gd` — assert joystick-vector-to-action mapping.
- Modify: `docs/TESTE_DEMO_VILA.md` — desktop and Android test instructions.

**Interfaces:**
- `MobileControls.vector_to_strengths(value: Vector2) -> Dictionary` returns normalized strengths for `move_left`, `move_right`, `move_forward`, and `move_back`.
- `MobileControls.action_triggered(action_name: String)` emits `interact` or `attack` from on-screen buttons.
- `MobileControls.set_controls_enabled(enabled: bool)` gates touch input while dialogue is open.

- [ ] Write and run the joystick mapping test first; verify it fails before the helper exists.
- [ ] Implement the pure vector mapping helper and virtual joystick.
- [ ] Add the two touch action buttons and wire their signals into the existing village interactions.
- [ ] Add touch camera drag without changing desktop mouse behavior.
- [ ] Run the GDScript test and open the scene in the Godot editor; then follow the manual checklist on desktop and Android.
- [ ] Update documentation with any version/device limitations and commit the completed step.

**Acceptance:** Desktop keyboard/mouse behavior remains; on Android the joystick moves Azael, right-side swipes rotate the camera, and touch buttons trigger interaction/attack. The GDScript check passes, the project opens without parser errors, and touch behavior is confirmed on an Android device.
