extends Enemy
class_name Chipomat

@export var office_layer: CanvasLayer
@export var office: AnimatedSprite2D
@export var sprite: AnimatedSprite2D

@export var spawn_timer: float
@export var kill_timer: float
@export var leave_timer: float
@export var random_variance: float
@export var kill_timer_pause_threshold: float = 1.0
@export var knock_sound: AudioStream

enum SIDES {LEFT=-1,IDLE,RIGHT}
var side: SIDES
const side_strings: Dictionary[SIDES,String] = {
	SIDES.LEFT: "l",
	SIDES.IDLE: "idle",
	SIDES.RIGHT: "r"}
enum STATES {IDLE,SPAWNED,JUMPSCARE}
var state: STATES

var current_random_variance: float
var current_spawn_timer: float
var current_kill_timer: float
var current_leave_timer: float
var office_animation_direction: String
var using_flashlight: bool

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
			current_spawn_timer -= 1 * delta * current_random_variance
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
			
func _update_flashlight_state(flashlight_state: bool) -> void:
	using_flashlight = flashlight_state

func _reset_values() -> void:
	current_random_variance = 1 + randf_range(-random_variance,random_variance)
	current_spawn_timer = spawn_timer
	current_kill_timer = kill_timer
	current_leave_timer = leave_timer

func _visibility_checks() -> bool:
	if state == STATES.JUMPSCARE:
		if sprite.visible:
			if "open_" in office.animation and using_flashlight:
				return true
		return false
		
	if state != STATES.SPAWNED:
		return false
	if office_animation_direction != side_strings[side]:
		return false
	if "open_" not in office.animation:
		return false
	if not using_flashlight:
		return false
		
	return true
	
func _pick_side() -> SIDES:
	side = [SIDES.LEFT,SIDES.RIGHT].pick_random()
	if office_layer.get_window_occupants(side).size() >= 2:
		side = side * -1 as SIDES
	return side

func _spawn_chipomat() -> void:
	side = _pick_side()
	sprite.play(side_strings[side])
	SpecialFunctions.audio(knock_sound,0,1,1,side)
	state = STATES.SPAWNED
	_reset_values()
	office_layer.update_window_occupants(enemy_id,side,true)
	
func _leave_chipomat() -> void:
	SignalBus.enemy_defended.emit(self)
	side = SIDES.IDLE
	state = STATES.IDLE
	office_layer.update_window_occupants(enemy_id,side,false)
	
func _prepare_jumpscare() -> void:
	_jumpscare() #TEMPORARY FOR TESTING PURPOSES
	state = STATES.JUMPSCARE
	
