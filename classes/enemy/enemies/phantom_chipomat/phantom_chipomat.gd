class_name Phantom_Chipomat extends Enemy

@export_group("Nodes")
@export var office: AnimatedSprite2D
@export var dark_office: AnimatedSprite2D
@export var sprite: AnimatedSprite2D
@export_group("Variables")
@export var attack_timer: float

var current_attack_timer: float

func _ready() -> void:
	super()
	if not enabled: return
	current_attack_timer = attack_timer
	sprite.sprite_frames = jumpscares[JUMPSCARE_AREAS.MIDDLE]

func _process(delta: float) -> void:
	if _attack_checks():
		current_attack_timer -= 1 * delta
		if current_attack_timer <= 0:
			phantom_attack()
		
func _deactivate() -> void:
	super()
	sprite.queue_free()

func _attack_checks() -> bool:
	if office.animation != "office":
		current_attack_timer = attack_timer
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
	SpecialFunctions.create_audio(jumpscare_sound,1)
	SaveData.set_data(SaveData.FILE_TYPE.SAVE,["statistics","jumpscares",ENEMY_IDS.keys()[enemy_id]],1,SaveData.SET_DATA_SPECIAL.ADD)
	await sprite.animation_finished
	SignalBus.phantom_jumpscare.emit()
	var tween = get_tree().create_tween()
	tween.tween_property(sprite,"self_modulate:a",0,0.8)
	await tween.finished
	sprite.visible = false
	current_attack_timer = attack_timer
