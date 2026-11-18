extends CanvasLayer

@onready var status_label: Label = $StatusLabel

func _ready() -> void:
    status_label.text = "AZAEL — VILA DE TESTE\nWASD: mover | Mouse: câmera | E: conversar | F: atacar | ESC: soltar mouse"
