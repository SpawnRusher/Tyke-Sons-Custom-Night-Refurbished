extends TextureButton

const LOUD_BUTTON_PRESS = preload("uid://dljncvmipnl1d")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(play)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play():
	SpecialFunctions.audio(LOUD_BUTTON_PRESS,1,1,0,0,0,true)
	get_tree().change_scene_to_file("res://scenes/night.tscn")
