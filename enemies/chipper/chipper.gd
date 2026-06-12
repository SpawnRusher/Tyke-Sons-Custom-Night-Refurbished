extends Enemy
class_name Chipper

const lumber_scene = preload("res://enemies/chipper/lumber.tscn")

@onready var camera = get_viewport().get_camera_2d()

func _ready() -> void:
	await super()
	if enabled == false:
		self.queue_free()
		#sprite.queue_free()
		return
	
	SignalBus.pickup_lumber.connect(_pickup_lumber)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_L and event.is_pressed():
			_create_lumber()

func _create_lumber() -> void:
	var lumber = lumber_scene.instantiate()
	camera.add_child(lumber)

func _pickup_lumber() -> void:
	pass
