extends Camera2D

var goto: float = 200
var lockpos: float = -1

@onready var office = $"../Office_BG"

func _ready() -> void:
	position.x = goto

func _process(_delta: float) -> void:
	goto = 200 +((office.get_local_mouse_position().x - 840) / 4.1)
	goto = clampf(goto,0,400)
	if lockpos != -1:
		goto = lockpos
	position.x = goto
