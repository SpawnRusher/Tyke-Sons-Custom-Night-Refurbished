extends Enemy
class_name Chipper

const lumber_scene: PackedScene = preload("uid://i1kgthfoxabk")

@onready var camera: Camera2D = get_viewport().get_camera_2d()

@export var spawn_timer: float 
@export var lumber_timer: float

var current_spawn_timer: float

func _ready() -> void:
	super()

	SignalBus.pickup_lumber.connect(_pickup_lumber)
	SignalBus.lumber_despawned.connect(_lumber_despawned)
	
	current_spawn_timer = spawn_timer

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_L and event.is_pressed():
			_create_lumber()
			
func _process(delta: float) -> void:
	current_spawn_timer -= 1 * delta
	if current_spawn_timer <= 0:
		_create_lumber()
		current_spawn_timer = spawn_timer

func _create_lumber() -> void:
	var lumber: TextureRect = lumber_scene.instantiate()
	camera.add_child(lumber)
	lumber.lumber_timer = lumber_timer

func _pickup_lumber() -> void:
	pass

func _lumber_despawned() -> void:
	_jumpscare()
