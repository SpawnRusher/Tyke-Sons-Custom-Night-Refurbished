extends Enemy
class_name Springcrab

##The office layer.
@export var office_layer: CanvasLayer
##The office background.
@export var office: AnimatedSprite2D
##The Springcrab sprite.
@export var sprite: AnimatedSprite2D
## Seabill
@export var seabill: Enemy
## The time it takes to appear at the window.
@export var spawn_timer: float
## The time it takes to kill when sitting at the window.
@export var kill_timer: float
## The number of flashes it takes to make Springcrab leave.
@export var leave_flashes: int
## Adds a random variance to the spawn timer. 0.05 = 5%, 0.1 = 10%, etc. Value is applied with a random range from (-random_variance,random_variance)
@export var random_variance: float
## The timer amount to prevent the kill timer from going below when the flashlight is on (and on Springcrab's side)
@export var kill_timer_pause_threshold: float
## The sound for Springcrab walking up to the window.
@export var walking_sound: AudioStream

enum STAGES {IDLE,SPAWNED,JUMPSCARE}
var stage: STAGES
var current_random_variance: float
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
		current_spawn_timer -= 1 * delta * current_random_variance
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
	current_random_variance = 1 + randf_range(-random_variance,random_variance)
	current_spawn_timer = spawn_timer
	current_kill_timer = kill_timer
	current_leave_flashes = leave_flashes
	last_side_flashed = ""

func spawn_springcrab() -> void:
	stage = STAGES.SPAWNED
	SpecialFunctions.audio(walking_sound)
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

	
