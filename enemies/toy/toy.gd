extends Enemy
class_name Toy

const TOY_RUNNING = preload("uid://dmxbc6sdfjf11")

@export var office: AnimatedSprite2D
@export var dark_overlay: AnimatedSprite2D
@export var sprite: AnimatedSprite2D
@export var spawn_timer: float
@export var kill_timer: float
@export var leave_timer: float
@export var random_variance: float
@export var kill_timer_pause_threshold: float
@export var leaving_sound: AudioStream

var current_random_variance: float
var current_spawn_timer: float
var current_kill_timer: float
var current_leave_timer: float
enum STAGES {IDLE,SITTING,STANDING,SPAWN,JUMPSCARE}
var stage: STAGES

func _ready() -> void:
	super()
	if not enabled: return
	_reset_values()

func _process(delta: float) -> void:
	sprite.visible = visibility_checks()
	if stage == STAGES.JUMPSCARE:
		if office.animation == "return" or office.animation == "office":
			_jumpscare()
		return

	if stage <= STAGES.STANDING:
		current_spawn_timer -= 1 * delta
		stage = lerp(0,3,min((spawn_timer - current_spawn_timer)/spawn_timer,1))
		sprite.frame = stage
			
	if stage == STAGES.SPAWN:
		current_kill_timer -= 1 * delta
		
		if dark_overlay.visible:
			current_kill_timer = max(current_kill_timer,kill_timer_pause_threshold)
			current_leave_timer -= 1 * delta
			
		if current_kill_timer <= 0:
			prepare_jumpscare()
			
		if current_leave_timer <= 0:
			leave_toy()
			
func _deactivate() -> void:
	super()
	sprite.queue_free()

func _reset_values() -> void:
	current_random_variance = 1 + randf_range(-random_variance,random_variance)
	current_spawn_timer = spawn_timer
	current_kill_timer = kill_timer
	current_leave_timer = leave_timer

func visibility_checks() -> bool:
	if office.animation != "open_b":
		return false
	if office.frame != 1:
		return false
	return true
	
func leave_toy() -> void:
	SignalBus.enemy_defended.emit(self)
	SpecialFunctions.audio(TOY_RUNNING)
	stage = STAGES.IDLE
	_reset_values()
	
func prepare_jumpscare() -> void:
	_jumpscare() #TEMPORARY FOR TESTING PURPOSES
	stage = STAGES.JUMPSCARE
