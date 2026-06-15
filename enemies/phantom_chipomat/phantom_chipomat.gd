extends Enemy
class_name Phantom_Chipomat

##The office background.
@export var office: AnimatedSprite2D
## The dark office overlay.
@export var dark_office: AnimatedSprite2D
## The Enemy sprite.
@export var sprite: AnimatedSprite2D
## The attack timer.
@export var attack_timer: float


var current_attack_timer: float

func _ready() -> void:
	await super()
	if enabled == false:
		_queue_free()
		return
		
	current_attack_timer = attack_timer
	sprite.sprite_frames = load(jumpscare_middle_uid)

func _process(delta: float) -> void:
	if office.animation == "office":
		if dark_office.visible == true:
			if sprite.visible == false:
				current_attack_timer -= 1 * delta
				if current_attack_timer <= 0:
					phantom_attack()
	else:
		current_attack_timer = attack_timer
		
func _queue_free():
	self.queue_free()
	sprite.queue_free()
			
func phantom_attack():
	sprite.self_modulate.a = 1
	sprite.visible = true
	sprite.play()
	SpecialFunctions.audio(jumpscare_sound)
	await sprite.animation_finished
	SignalBus.phantom_jumpscare.emit()
	var tween = get_tree().create_tween()
	tween.tween_property(sprite,"self_modulate:a",0,0.8)
	await tween.finished
	sprite.visible = false
	current_attack_timer = attack_timer
