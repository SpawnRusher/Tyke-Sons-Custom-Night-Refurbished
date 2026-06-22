extends Enemy
class_name Chipomat

##The office background.
@export var office: AnimatedSprite2D
##The Chipomat sprite.
@export var sprite: AnimatedSprite2D
## The time it takes for the Chipomat to appear at a window.
@export var spawn_timer: float
## The time it takes for the Chipomat to kill when sitting in a window.
@export var kill_timer: float
## The time it takes with the curtain closed to make the Chipomat leave.
@export var leave_timer: float
## Adds a random variance to the spawn timer. 0.05 = 5%, 0.1 = 10%, etc. Value is applied with a random range from (-random_variance,random_variance)
@export var random_variance: float
## The timer amount to prevent the kill timer from going below when the curtain is closed on the Chipomat.
@export var kill_timer_pause_threshold: float = 1.0
## The sound to play when knocking at a window.
@export var knock_sound: AudioStream


var side: int
var side_string: String
var sides: Dictionary[int,String] = {-1: "l", 1: "r"}
var current_random_variance: float
var current_spawn_timer: float
var current_kill_timer: float
var current_leave_timer: float
var spawned: bool
var jumpscare_ready: bool
var office_animation_direction: String



func _ready() -> void:
	await super()
	if enabled == false:
		deactivate()
		return
	
	current_random_variance = 1 + randf_range(-random_variance,random_variance)
	current_spawn_timer = spawn_timer
	current_kill_timer = kill_timer
	current_leave_timer = leave_timer

func _process(delta: float) -> void:
	office_animation_direction = office.animation.right(1)
	visibility_checks()
	if jumpscare_ready == true:
		if office.animation == "return" or office.animation == "office":
			jumpscare()
		return

	if spawned == false:
		current_spawn_timer -= 1 * delta * current_random_variance
		if current_spawn_timer <= 0:
			spawn_chipomat()

	if spawned == true:
		current_kill_timer -= 1 * delta
		
		if office_animation_direction == sprite.animation:
			if "closed" in office.animation:
				current_kill_timer = max(current_kill_timer,kill_timer_pause_threshold)
				
				current_leave_timer -= 1 * delta 
	
		if current_leave_timer <= 0:
			if jumpscare_ready == false:
				leave_chipomat()
			
		if current_kill_timer <= 0:
			prepare_jumpscare()
			
func deactivate() -> void:
	self.queue_free()
	sprite.queue_free()
			
func visibility_checks() -> void:
	if spawned != true:
		sprite.visible = false
	elif office_animation_direction != sprite.animation:
		sprite.visible = false
	elif jumpscare_ready == true:
		if sprite.visible == true:
			if "closed" in office.animation:
				sprite.visible = false
	elif jumpscare_ready == false:
		sprite.visible = true
	
func pick_side() -> int:
	side = [-1,1].pick_random()
	if sides[side] == office_animation_direction:
		if "open" in office.animation or "clos" in office.animation: # "clos" to detect "close_" and "closing_"
			return (side*-1)
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
	
func leave_chipomat() -> void:
	SignalBus.enemy_defended.emit(self)
	spawned = false
	sprite.visible = false
	
func prepare_jumpscare() -> void:
	jumpscare_ready = true
	
	
