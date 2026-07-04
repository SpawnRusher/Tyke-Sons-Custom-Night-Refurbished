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

enum SIDES {LEFT=-1,NONE=0,RIGHT=1}
var side: SIDES
var side_string: String
var sides: Dictionary[int,String] = {SIDES.LEFT: "l", SIDES.RIGHT: "r"}
var current_random_variance: float
var current_spawn_timer: float
var current_kill_timer: float
var current_leave_timer: float
var spawned: bool
var jumpscare_ready: bool
var office_animation_direction: String
var flashlight_state: bool

func _ready() -> void:
	super()

	SignalBus.update_flashlight_state.connect(_update_flashlight_state)
	current_random_variance = 1 + randf_range(-random_variance,random_variance)
	current_spawn_timer = spawn_timer
	current_kill_timer = kill_timer
	current_leave_timer = leave_timer

func _process(delta: float) -> void:
	office_animation_direction = office.animation.right(1)
	sprite.visible = visibility_checks()
	if jumpscare_ready:
		if office.animation == "return" or office.animation == "office":
			_jumpscare()
		return

	if not spawned:
		current_spawn_timer -= 1 * delta * current_random_variance
		if current_spawn_timer <= 0:
			spawn_chipomat()

	if spawned:
		current_kill_timer -= 1 * delta
		
		if office_animation_direction == sprite.animation:
			if "clos" in office.animation:
				current_kill_timer = max(current_kill_timer,kill_timer_pause_threshold)
				
				current_leave_timer -= 1 * delta 
	
		if current_leave_timer <= 0:
			if not jumpscare_ready:
				leave_chipomat()
			
		if current_kill_timer <= 0:
			prepare_jumpscare()
			
func _deactivate() -> void:
	super()
	sprite.queue_free()
			
func _update_flashlight_state(state: bool) -> void:
	flashlight_state = state

func visibility_checks() -> bool:
	if jumpscare_ready:
		if sprite.visible:
			if "open_" in office.animation and flashlight_state:
				return true
		return false
		
	if not spawned:
		return false
	if office_animation_direction != side_string:
		return false
	if "open_" not in office.animation:
		return false
	if not flashlight_state:
		return false
		
	return true
	
func pick_side() -> SIDES:
	side = [-1,1].pick_random()
	
	if office_layer.get_window_occupants(side).size() >= 2:
		side = side * -1 as SIDES

	return side

func spawn_chipomat() -> void:
	side = pick_side()
	side_string = sides[side]
	sprite.play(side_string)
	SpecialFunctions.audio(knock_sound,0,1,1,side)
	spawned = true
	current_spawn_timer = spawn_timer
	current_kill_timer = kill_timer
	current_leave_timer = leave_timer
	current_random_variance = 1 + randf_range(-random_variance,random_variance)
	office_layer.update_window_occupants(enemy_id,side,true)
	
func leave_chipomat() -> void:
	SignalBus.enemy_defended.emit(self)
	spawned = false
	sprite.visible = false
	office_layer.update_window_occupants(enemy_id,side,false)
	
func prepare_jumpscare() -> void:
	_jumpscare() #TEMPORARY FOR TESTING PURPOSES
	jumpscare_ready = true
	
