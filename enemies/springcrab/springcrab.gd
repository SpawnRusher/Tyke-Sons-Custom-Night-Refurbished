extends Enemy
class_name Springcrab

##The office background.
@export var office: AnimatedSprite2D
##The Springcrab sprite.
@export var sprite: AnimatedSprite2D
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

var current_random_variance: float
var current_spawn_timer: float
var current_kill_timer: float
var current_leave_flashes: float
var spawned: bool
var last_side_flashed: String
var jumpscare_ready: bool

func _ready() -> void:
	await super()
	if enabled == false:
		self.queue_free()
		return
	
	SignalBus.update_flashlight_state.connect(flash_springcrab)
	
	current_random_variance = 1 + randf_range(-random_variance,random_variance)
	current_spawn_timer = spawn_timer
	current_kill_timer = kill_timer
	current_leave_flashes = leave_flashes

func _process(delta: float) -> void:
	visibility_checks()
	if jumpscare_ready == true:
		if office.animation == "return" or office.animation == "office":
			jumpscare()
		return

	if spawned == false:
		current_spawn_timer -= 1 * delta * current_random_variance
		if current_spawn_timer <= 0:
			spawn_springcrab()
			
	if spawned == true:
		current_kill_timer -= 1 * delta
			
		if office.animation == "open_f" and office.frame >= 1:
			current_kill_timer = max(current_kill_timer,kill_timer_pause_threshold)
				
		if current_kill_timer <= 0:
			prepare_jumpscare()

func spawn_springcrab() -> void:
	spawned = true
	SpecialFunctions.audio(walking_sound,1,1,0,0,0,false)
	current_random_variance = 1 + randf_range(-random_variance,random_variance)
	current_spawn_timer = spawn_timer
	current_kill_timer = kill_timer
	current_leave_flashes = leave_flashes
	
func leave_springcrab() -> void:
	SignalBus.enemy_defended.emit(self)
	spawned = false
	last_side_flashed = ""
	
func visibility_checks() -> void:
	if office.animation == "open_f":
		if office.frame == 2:
			if jumpscare_ready == false:
				sprite.frame = spawned
			else:
				sprite.frame = 0
					
func flash_springcrab(using_flashlight) -> void:
	if spawned == false and jumpscare_ready == false:
		return
	if using_flashlight == false or office.animation != "open_f":
		return
	if sprite.animation == last_side_flashed:
		current_leave_flashes = leave_flashes
		print(last_side_flashed,"|",current_leave_flashes)
		return
	
	last_side_flashed = sprite.animation
	current_leave_flashes -= 1
		
	if current_leave_flashes <= 0:
		leave_springcrab()
		
func prepare_jumpscare() -> void:
	jumpscare_ready = true

	
