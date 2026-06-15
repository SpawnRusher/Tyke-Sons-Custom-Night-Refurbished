extends TextureButton

const LOUD_BUTTON_PRESS = preload("uid://dljncvmipnl1d")

@onready var fade = $"../Fade"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(play)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play():
	SpecialFunctions.audio(LOUD_BUTTON_PRESS,1,1,0,0,0,true)
	var tween = get_tree().create_tween()
	tween.tween_property(fade,"self_modulate:a",1,0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/later_that_night.tscn")
