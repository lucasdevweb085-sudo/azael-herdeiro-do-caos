extends CanvasLayer

@onready var status_label: Label = $StatusLabel

func _ready() -> void:
    status_label.text = "AZAEL — PROTÓTIPO\nWASD: mover | Mouse: câmera | ESC: liberar mouse"
