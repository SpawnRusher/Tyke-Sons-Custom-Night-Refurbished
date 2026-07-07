extends Enemy
class_name Seabill

@export_group("Nodes")
@export var office: AnimatedSprite2D
@export var dark_office: AnimatedSprite2D
@export var dark_flicker: ColorRect
@export var sprite: AnimatedSprite2D
@export_group("Variables")
@export var ready_timer: Vector2 # Vector2 is used due to lack of official Tuples. x = lower bound, y = higher bound.
@export var spawn_timer: Vector2 # Vector2 is used due to lack of official Tuples. x = lower bound, y = higher bound.
@export var kill_timer: float
@export var kill_timer_pause_threshold: float
@export var walk_timer: float
@export var flash_timer: float
@export var sleep_assurance_grace_period: float
@export var start_position: float
@export var end_position: float
@export var stare_times: int

const SPAWN_VOICELINES: Array[AudioStream] = [preload("uid://dttftglmbprym"), preload("uid://dlvfr07ppj45c"), preload("uid://c6c0yurye6vqp")]

var current_timer: float
var current_kill_timer: float
var current_walk_timer: float
var current_walk_progress: float
var current_flash_timer: float
var current_sleep_assurance_grace_period: float
var stare_times_array: Array
var last_animation_played: String

enum STATES {IDLE,READY,SPAWNED,JUMPSCARE}
var state: STATES
enum MOVING_STATES {IDLE,WALKING,TURNING,STARING}
var moving_state: MOVING_STATES

func _ready() -> void:
	super()
	if not enabled: return
	_reset_values()
	sprite.animation_changed.connect(_update_last_animation_played)
	sprite.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	visibility_checks()
	if state == STATES.JUMPSCARE:
		if office.animation == "return" or office.animation == "office":
			_jumpscare()
		return
	elif state == STATES.SPAWNED and office.animation == "open_f":
		_jumpscare()
		return
		
	if state == STATES.IDLE:
		current_timer -= 1 * delta
		if current_timer <= 0:
			ready_seabill()
			
	if state == STATES.READY:
		current_timer -= 1 * delta
		if current_timer <= 0:
			spawn_seabill()

	if state == STATES.SPAWNED:
		dark_flicker.self_modulate.a8 -= randi_range(-60,60)
		if moving_state == MOVING_STATES.WALKING:
			current_walk_timer -= 1 * delta
			current_walk_progress = min((walk_timer-current_walk_timer)/walk_timer,1)
			sprite.position.x = lerpf(start_position,end_position,current_walk_progress)
			for i in stare_times_array:
				if snappedf(current_walk_progress,0.001) == i:
					stare_times_array.remove_at(i)
					stare_seabill()

		if moving_state == MOVING_STATES.STARING:
			current_kill_timer -= 1 * delta
			
			if not dark_office.visible:
				current_sleep_assurance_grace_period -= 1 * delta
				if current_sleep_assurance_grace_period <= 0:
					SignalBus.remove_sleep_assurance.emit(delta, self)
			elif office.animation == "office":
				current_kill_timer = max(current_kill_timer,kill_timer_pause_threshold)
				current_flash_timer -= 1 * delta

			if current_flash_timer <= 0:
				walk_seabill()
					
			if current_kill_timer <= 0:
				prepare_jumpscare()
							
		if current_walk_progress >= 1.0:
			leave_seabill()
			
func _deactivate() -> void:
	super()
	sprite.queue_free()
	dark_flicker.queue_free()
			
func _reset_values() -> void:
	state = STATES.IDLE
	moving_state = MOVING_STATES.IDLE
	dark_flicker.self_modulate.a8 = 0
	current_timer = randf_range(ready_timer.x,ready_timer.y)
	current_kill_timer = kill_timer
	current_walk_timer = walk_timer
	current_walk_progress = 0
	current_flash_timer = flash_timer
	current_sleep_assurance_grace_period = sleep_assurance_grace_period
			
func ready_seabill() -> void:
	SpecialFunctions.audio(SPAWN_VOICELINES.pick_random())
	state = STATES.READY
	current_timer = randf_range(spawn_timer.x,spawn_timer.y)
	current_kill_timer = kill_timer
	
	stare_times_array.clear()
	for i in stare_times:
		stare_times_array.append(snappedf((1.0/(stare_times+1)) * (i+1),0.001))
	
func spawn_seabill() -> void:
	state = STATES.SPAWNED
	sprite.play("walking")
	moving_state = MOVING_STATES.WALKING
			
func stare_seabill() -> void:
	sprite.play("turning_stare")
	current_flash_timer = flash_timer
	moving_state = MOVING_STATES.TURNING

func walk_seabill() -> void:
	sprite.play("turning_walk")
	current_kill_timer = kill_timer
	current_sleep_assurance_grace_period = sleep_assurance_grace_period
	moving_state = MOVING_STATES.TURNING
	
func leave_seabill() -> void:
	SignalBus.enemy_defended.emit(self)
	_reset_values()
	
func prepare_jumpscare() -> void:
	_jumpscare() #TEMPORARY FOR TESTING PURPOSES
	state = STATES.JUMPSCARE
	
func _update_last_animation_played() -> void:
	last_animation_played = sprite.animation
	
func _on_animation_finished() -> void:
	if last_animation_played == "turning_stare":
		sprite.play("staring")
		moving_state = MOVING_STATES.STARING
		
	if last_animation_played == "turning_walk":
		sprite.play("walking")
		moving_state = MOVING_STATES.WALKING

func visibility_checks() -> void:
	if office.animation == "office":
		sprite.visible = true
	else:
		sprite.visible = false
