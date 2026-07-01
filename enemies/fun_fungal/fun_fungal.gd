extends Enemy
class_name Fun_Fungal
##The office layer.
@export var office_layer: CanvasLayer
##The office background.
@export var office: AnimatedSprite2D
##The Fun Fungal sprite.
@export var sprite: AnimatedSprite2D
## The amount of time Fun Fungal needs to go unflashed for in order to kill.
@export var progress_timer: float
## Idle time
@export var idle_timer: float

var office_animation_direction: String
var current_idle_timer: float
var current_progress_timer: float
var current_progress_normalized: float
var position: String = "idle"
var front_position: String = ""
var info_key: String = ""
var position_info: Dictionary = {
	"idle":Vector2(-600,-600),
	"l": {
		"out":Vector2(960,35),
		"in":Vector2(760,235),
		"angle": 255
	},
	"r": {
		"out":Vector2(290,50),
		"in":Vector2(490,250),
		"angle": 135
	},
	"fl": {
		"out": Vector2(460,760),
		"in": Vector2(460,510),
		"angle": 0
	},
	"fr": {
		"out":Vector2(760,760),
		"in":Vector2(760,510),
		"angle": 0
	},
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await super()
	if enabled == false:
		deactivate()
		return
	
	current_idle_timer = idle_timer
	
func _process(delta: float) -> void:
	office_animation_direction = office.animation.right(1)
	sprite.visible = _visibility_checks()
	if position == "idle":
		current_idle_timer -= 1 * delta
		if current_idle_timer <= 0:
			_spawn_fungal()
		return

	if _flash_checks() == false:
		current_progress_timer += 1 * delta
	else:
		current_progress_timer -= 20 * delta
		
	current_progress_normalized = current_progress_timer/progress_timer
	sprite.position.x = lerpf(position_info[info_key]["out"].x,position_info[info_key]["in"].x,current_progress_normalized)
	sprite.position.y = lerpf(position_info[info_key]["out"].y,position_info[info_key]["in"].y,current_progress_normalized)
	
	if current_progress_normalized >= 1:
		jumpscare()
	
	if current_progress_normalized < 0:
		_leave_fungal()
		
func deactivate():
	self.queue_free()
	sprite.queue_free()
	
func _spawn_fungal():
	position = ["l","f","r"].pick_random()
	position = "f"
	if position == "f":
		front_position = ["l","r"].pick_random()
	info_key = position + front_position
	office_layer.update_window_occupants(enemy_id,position,true)
	sprite.rotation_degrees = position_info[info_key]["angle"]
	current_progress_timer = 0

func _leave_fungal() -> void:
	SignalBus.enemy_defended.emit(self)
	office_layer.update_window_occupants(enemy_id,position,false)
	current_idle_timer = idle_timer
	position = "idle"
	front_position = ""
	info_key = ""
	sprite.position = position_info[position]

func _visibility_checks() -> bool:
	if office_animation_direction != position:
		return false
	return true
	
func _flash_checks() -> bool:
	if office_animation_direction != position:
		return false
	if "open_" not in office.animation:
		return false
	if position != "f" and office.frame != 1:
		return false
	if position == "f" and office.frame != {"l":1,"r":2}[front_position]:
		return false
	return true
