extends Enemy
class_name Fun_Fungal

@export_group("Nodes")
@export var office_layer: CanvasLayer
@export var office: AnimatedSprite2D
@export var sprite: AnimatedSprite2D
@export_group("Variables")
@export var progress_timer: float
@export var idle_timer: float


var office_animation_direction: String
var current_idle_timer: float
var current_progress_timer: float
var current_progress_normalized: float
var flashlight_state: Global.FLASHLIGHT_STATES
enum STATES {IDLE,ACTIVE}
enum POSITIONS {LEFT,FRONT_LEFT,FRONT_RIGHT,RIGHT}
var state: STATES
var position: POSITIONS
const position_strings: Dictionary[POSITIONS,String] = {POSITIONS.LEFT:"l",POSITIONS.FRONT_LEFT:"f",POSITIONS.FRONT_RIGHT:"f",POSITIONS.RIGHT:"r"}
const position_info: Dictionary[POSITIONS,Dictionary] = {
	POSITIONS.LEFT: {
		"out":Vector2(960,35),
		"in":Vector2(760,235),
		"angle": 255
	},
	POSITIONS.FRONT_LEFT: {
		"out": Vector2(460,745),
		"in": Vector2(460,495),
		"angle": 0
	},
	POSITIONS.FRONT_RIGHT: {
		"out":Vector2(760,745),
		"in":Vector2(760,495),
		"angle": 0
	},
	POSITIONS.RIGHT: {
		"out":Vector2(290,50),
		"in":Vector2(490,250),
		"angle": 135
	}}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	if not enabled: return
	SignalBus.update_flashlight_state.connect(_update_flashlight_state)
	current_idle_timer = idle_timer
	
func _process(delta: float) -> void:
	office_animation_direction = office.animation.right(1)
	sprite.visible = _visibility_checks()
	if state == STATES.IDLE:
		current_idle_timer -= 1 * delta
		if current_idle_timer <= 0:
			_spawn_fungal()
		return

	if not _flash_checks():
		current_progress_timer += 1 * delta
	else:
		current_progress_timer -= 20 * delta
		
	current_progress_normalized = current_progress_timer/progress_timer
	sprite.position.x = lerpf(position_info[position]["out"].x,position_info[position]["in"].x,current_progress_normalized)
	sprite.position.y = lerpf(position_info[position]["out"].y,position_info[position]["in"].y,current_progress_normalized)
	
	if current_progress_normalized >= 1:
		_jumpscare()
	
	if current_progress_normalized < 0:
		_leave_fungal()
		
func _deactivate():
	super()
	sprite.queue_free()
	
func _update_flashlight_state(new_state: Global.FLASHLIGHT_STATES) -> void:
	flashlight_state = new_state

func _spawn_fungal():
	state = STATES.ACTIVE
	position = POSITIONS.values().pick_random()
	office_layer.update_window_occupants(enemy_id,position,true)
	sprite.rotation_degrees = position_info[position]["angle"]
	current_progress_timer = 0

func _leave_fungal() -> void:
	state = STATES.IDLE
	SignalBus.enemy_defended.emit(self)
	office_layer.update_window_occupants(enemy_id,position,false)
	current_idle_timer = idle_timer

func _visibility_checks() -> bool:
	if state != STATES.ACTIVE:
		return false
	if office_animation_direction != position_strings[position]:
		return false
	return true
	
func _flash_checks() -> bool:
	if office_animation_direction != position_strings[position]:
		return false
	if "open_" not in office.animation:
		return false
	if position != POSITIONS.FRONT_LEFT and position != POSITIONS.FRONT_RIGHT and flashlight_state == Global.FLASHLIGHT_STATES.OFF:
		return false
	if position != POSITIONS.LEFT and position != POSITIONS.RIGHT and office.frame != position:
		return false
	return true
