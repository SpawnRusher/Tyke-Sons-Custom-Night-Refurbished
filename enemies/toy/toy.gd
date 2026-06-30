extends Enemy
class_name Toy

const TOY_RUNNING = preload("uid://dmxbc6sdfjf11")


##The office background.
@export var office: AnimatedSprite2D
##The dark office overlay.
@export var dark_overlay: AnimatedSprite2D
##The Enemy sprite.
@export var sprite: AnimatedSprite2D
## The time it takes to reach attack stage.
@export var spawn_timer: float
## The time it takes to kill after reaching attack stage.
@export var kill_timer: float
## The time it takes with the lights off to make Toy leave.
@export var leave_timer: float
## Adds a random variance to the spawn timer. 0.05 = 5%, 0.1 = 10%, etc. Value is applied with a random range from (-random_variance,random_variance)
@export var random_variance: float
## The timer amount to prevent the kill timer from going below when the lights are off in the office.
@export var kill_timer_pause_threshold: float
## The sound for Toy leaving.
@export var leaving_sound: AudioStream

var total_spawn_timer: float
var current_random_variance: float
var current_spawn_timer: float
var current_kill_timer: float
var current_leave_timer: float
var stage: int
var spawned: bool
var jumpscare_ready: bool




func _ready() -> void:
	await super()
	if enabled == false:
		deactivate()
		return
	
	total_spawn_timer = spawn_timer
	current_random_variance = 1 + randf_range(-random_variance,random_variance)
	current_spawn_timer = spawn_timer
	current_kill_timer = kill_timer
	current_leave_timer = leave_timer

func _process(delta: float) -> void:
	visibility_checks()
	if jumpscare_ready == true:
		if office.animation == "return" or office.animation == "office":
			jumpscare()
		return

	if spawned == false:
		current_spawn_timer -= 1 * delta
		stage = lerp(0,3,min((total_spawn_timer - current_spawn_timer)/total_spawn_timer,1))
		if stage == 3:
			spawn_toy()
			
	if spawned == true:
		current_kill_timer -= 1 * delta
		
		if dark_overlay.visible == true:
			current_kill_timer = max(current_kill_timer,kill_timer_pause_threshold)
			current_leave_timer -= 1 * delta
			
		if current_kill_timer <= 0:
			prepare_jumpscare()
			
		if current_leave_timer <= 0:
			leave_toy()
			
func deactivate() -> void:
	self.queue_free()
	sprite.queue_free()

func visibility_checks() -> void:
	if office.animation != "open_b":
		sprite.visible = false
		sprite.frame = stage
	elif office.frame != 1:
		sprite.visible = false
		sprite.frame = stage
	else:
		sprite.visible = true
	
func spawn_toy() -> void:
	spawned = true
	current_random_variance = 1 + randf_range(-random_variance,random_variance)
	current_spawn_timer = spawn_timer
	current_kill_timer = kill_timer
	current_leave_timer = leave_timer
	
func leave_toy() -> void:
	SignalBus.enemy_defended.emit(self)
	SpecialFunctions.audio(TOY_RUNNING)
	spawned = false
	
func prepare_jumpscare() -> void:
	jumpscare() #TEMPORARY FOR TESTING PURPOSES
	jumpscare_ready = true
