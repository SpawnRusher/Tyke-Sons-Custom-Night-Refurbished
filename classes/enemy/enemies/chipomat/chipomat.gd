class_name Chipomat extends Enemy

@export_group("Nodes")
@export var office_layer: CanvasLayer
@export var office: AnimatedSprite2D
@export var sprite: AnimatedSprite2D
@export_group("Variables")
@export var spawn_timer: Vector2 # Vector2 is used due to lack of official Tuples. x = lower bound, y = higher bound.
@export var kill_timer: float
@export var leave_timer: float
@export var kill_timer_pause_threshold: float = 1.0
@export var knock_sound: AudioStream

@onready var camera = get_viewport().get_camera_2d()

enum STATES {IDLE,SPAWNED,JUMPSCARE}
var state: STATES
enum SIDES {LEFT=-1,RIGHT}
var side: SIDES
const side_strings: Array[String] = ["l","r"]

var current_random_variance: float
var current_spawn_timer: float
var current_kill_timer: float
var current_leave_timer: float
var office_animation_direction: String
var flashlight_state: Global.FLASHLIGHT_STATES

func _ready() -> void:
	super()
	if not enabled: return
	SignalBus.update_flashlight_state.connect(_update_flashlight_state)
	_reset_values()

func _process(delta: float) -> void:
	office_animation_direction = office.animation.right(1)
	sprite.visible = _visibility_checks()
	match state:
		STATES.IDLE:
			current_spawn_timer -= 1 * delta
			if current_spawn_timer <= 0:
				_spawn_chipomat()
		STATES.SPAWNED:
			current_kill_timer -= 1 * delta
			if office_animation_direction == sprite.animation and "clos" in office.animation:
				current_kill_timer = max(current_kill_timer,kill_timer_pause_threshold)
				current_leave_timer -= 1 * delta 
			if current_leave_timer <= 0 and state != STATES.JUMPSCARE:
				_leave_chipomat()
			if current_kill_timer <= 0:
				_prepare_jumpscare()
		STATES.JUMPSCARE:
			if office.animation == "return" or office.animation == "office":
				_jumpscare()

func _deactivate() -> void:
	super()
	sprite.queue_free()
			
func _update_flashlight_state(new_state: Global.FLASHLIGHT_STATES) -> void:
	flashlight_state = new_state

func _reset_values() -> void:
	current_spawn_timer = randf_range(spawn_timer.x,spawn_timer.y)
	current_kill_timer = kill_timer
	current_leave_timer = leave_timer

func _visibility_checks() -> bool:
	if state == STATES.JUMPSCARE:
		if sprite.visible:
			if "open_" in office.animation and flashlight_state == Global.FLASHLIGHT_STATES.ON:
				return true
		return false
		
	if state != STATES.SPAWNED:
		return false
	if office_animation_direction != side_strings[side+1]:
		return false
	if "open_" not in office.animation:
		return false
	if flashlight_state == Global.FLASHLIGHT_STATES.OFF:
		return false
		
	return true
	
func _pick_side() -> SIDES:
	side = SIDES.values().pick_random()
	if office_layer.get_window_occupants(side).size() >= 2:
		side = side * -1 as SIDES
	return side

func _spawn_chipomat() -> void:
	side = _pick_side()
	sprite.play(side_strings[side+1])
	var knocking_audio:= SpecialFunctions.create_audio_2d(knock_sound)
	knocking_audio.position.x = (camera.position.x+1280)+(1280*side)
	print_debug(knocking_audio.position, " | ", knocking_audio.position - camera.position)
	state = STATES.SPAWNED
	office_layer.update_window_occupants(enemy_id,side,true)
	
func _leave_chipomat() -> void:
	SignalBus.enemy_defended.emit(self)
	state = STATES.IDLE
	_reset_values()
	office_layer.update_window_occupants(enemy_id,side,false)
	
func _prepare_jumpscare() -> void:
	_jumpscare() #TEMPORARY FOR TESTING PURPOSES
	state = STATES.JUMPSCARE
	
