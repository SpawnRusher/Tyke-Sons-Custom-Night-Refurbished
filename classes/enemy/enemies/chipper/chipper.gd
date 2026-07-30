class_name Chipper extends Enemy

const LUMBER = preload("uid://i1kgthfoxabk") # I HAVE TO USE THE LUMBER SCENE. I CANNOT USE LUMBER.NEW().

@onready var camera: Camera2D = get_viewport().get_camera_2d()
@export var gui_layer: CanvasLayer
@export_group("Variables")
@export var spawn_timer: float 
@export var lumber_timer: float

var current_spawn_timer: float
var current_lumber: Lumber

func _ready() -> void:
	super()
	if not enabled: return
	current_spawn_timer = spawn_timer
			
func _process(delta: float) -> void:
	current_spawn_timer -= 1 * delta
	if current_spawn_timer <= 0:
		_create_lumber()
		current_spawn_timer = spawn_timer

func _create_lumber() -> void:
	current_lumber = LUMBER.instantiate()
	gui_layer.add_child(current_lumber)
	current_lumber.lumber_timer = lumber_timer
	current_lumber.lumber_picked_up.connect(_on_lumber_picked_up)
	current_lumber.lumber_despawned.connect(_on_lumber_despawned)

func _on_lumber_picked_up() -> void:
	pass

func _on_lumber_despawned() -> void:
	_jumpscare()
