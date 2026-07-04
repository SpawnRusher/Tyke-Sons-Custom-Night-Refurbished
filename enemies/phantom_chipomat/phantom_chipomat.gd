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
	super()
	if not enabled: return
	current_attack_timer = attack_timer
	sprite.sprite_frames = load(jumpscare_middle_uid)

func _process(delta: float) -> void:
	if _attack_checks():
		current_attack_timer -= 1 * delta
		if current_attack_timer <= 0:
			phantom_attack()
		return
	current_attack_timer = attack_timer
		
func _deactivate() -> void:
	super()
	sprite.queue_free()

func _attack_checks() -> bool:
	if office.animation != "office":
		return false
	if not dark_office.visible:
		return false
	if sprite.visible:
		return false
	return true
	
func phantom_attack() -> void:
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
