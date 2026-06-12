extends Camera2D

var pos: float = 200
var goto: float = 200
var lockpos: float = -1

@onready var office = $"../Office_BG"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	goto = 200 +((office.get_local_mouse_position().x - 840) / 4.1)
	goto = clampf(goto,0,400)
	if lockpos != -1:
		goto = lockpos
	position.x = goto
