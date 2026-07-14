extends Enemy
class_name Springcrab

@export_group("Nodes")
@export var office_layer: CanvasLayer
@export var office: AnimatedSprite2D
@export var sprite: AnimatedSprite2D
@export var seabill: Enemy
@export_group("Variables")
@export var spawn_timer: Vector2 # Vector2 is used due to lack of official Tuples. x = lower bound, y = higher bound.
@export var kill_timer: float
@export var leave_flashes: int
@export var kill_timer_pause_threshold: float
@export var walking_sound: AudioStream

enum STAGES {IDLE,SPAWNED,JUMPSCARE}
var stage: STAGES
var current_spawn_timer: float
var current_kill_timer: float
var current_leave_flashes: float
var last_side_flashed: String

func _ready() -> void:
	super()
	if not enabled: return
	SignalBus.update_flashlight_state.connect(_flash_springcrab)
	_reset_values()

func _process(delta: float) -> void:
	sprite.frame = _frame_checks()
	if stage == STAGES.JUMPSCARE:
		if office.animation == "return" or office.animation == "office":
			_jumpscare()
		return

	if stage == STAGES.IDLE:
		current_spawn_timer -= 1 * delta
		if current_spawn_timer <= 0:
			spawn_springcrab()
			
	if stage == STAGES.SPAWNED:
		if seabill == null or not seabill.spawned:
			current_kill_timer -= 1 * delta
			
		if office.animation == "open_f" and office.frame >= 1:
			current_kill_timer = max(current_kill_timer,kill_timer_pause_threshold)
				
		if current_kill_timer <= 0:
			prepare_jumpscare()
			
func _deactivate() -> void:
	super()
	# Springcrab doesn't free its sprite because its sprite is used even when its disabled, for flashing front window
	
func _reset_values() -> void:
	current_spawn_timer = randf_range(spawn_timer.x,spawn_timer.y)
	current_kill_timer = kill_timer
	current_leave_flashes = leave_flashes
	last_side_flashed = ""

func spawn_springcrab() -> void:
	stage = STAGES.SPAWNED
	SpecialFunctions.create_audio(walking_sound)
	office_layer.update_window_occupants(enemy_id,0,true)
	
func leave_springcrab() -> void:
	SignalBus.enemy_defended.emit(self)
	stage = STAGES.IDLE
	office_layer.update_window_occupants(enemy_id,0,false)
	_reset_values()
	
func _frame_checks() -> int:
	if stage == STAGES.JUMPSCARE:
		if sprite.frame == 1:
			if office.animation == "open_f" and office.frame == 2:
				return 1
		return 0
	
	if stage != STAGES.SPAWNED:
		return 0
	if office.animation != "open_f":
		return 0
	if office.frame != 2:
		return 0
		
	return 1
					
func _flash_springcrab(using_flashlight: bool) -> void:
	if stage != STAGES.SPAWNED:
		return
	if not using_flashlight:
		return
	if office.animation != "open_f":
		return

	if sprite.animation == last_side_flashed:
		current_leave_flashes = leave_flashes
		return
	
	current_leave_flashes -= 1
	last_side_flashed = sprite.animation
		
	if current_leave_flashes <= 0:
		leave_springcrab()
		
func prepare_jumpscare() -> void:
	_jumpscare() #TEMPORARY FOR TESTING PURPOSES
	stage = STAGES.JUMPSCARE

	
