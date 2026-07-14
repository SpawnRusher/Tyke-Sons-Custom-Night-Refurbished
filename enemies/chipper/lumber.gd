class_name Lumber extends TextureRect

const LUMBER_PICKUP: AudioStream = preload("uid://dbw4rno7ypmsk")

const LUMBER_COLOR_SPRITE_UIDS: Dictionary[LUMBER_COLORS,String] = {
	LUMBER_COLORS.BROWN: "uid://wkwoyiyrresu",
	LUMBER_COLORS.BLACK: "uid://7koqfbasjup3",
	LUMBER_COLORS.RED: "uid://dpi8k1s553fm0" }	
enum LUMBER_COLORS {BROWN,BLACK,RED}
var lumber_color: LUMBER_COLORS
var posx: float
var posy: float
var lumber_timer: float
var active: bool = true

@onready var camera: Camera2D = get_viewport().get_camera_2d()

func _ready() -> void:
	_create_lumber(self)
	
func _process(delta: float) -> void:
	lumber_timer -= (active as int) * delta
	if lumber_timer <= 0:
		_despawn_lumber()

func _create_lumber(lumber: Lumber) -> void:
	lumber_color = LUMBER_COLORS.values().pick_random()
	lumber.texture = load(LUMBER_COLOR_SPRITE_UIDS[lumber_color])
	posx = randi_range(150,1130-texture.get_width())
	posy = randi_range(150,570-texture.get_height())
	lumber.position = Vector2(posx,posy)
	
func _on_mouse_entered() -> void:
	_pickup_lumber()
	
func _pickup_lumber() -> void:
	active = false
	SpecialFunctions.create_audio(LUMBER_PICKUP)
	SignalBus.pickup_lumber.emit()
	var fade_tween = get_tree().create_tween()
	var move_tween = get_tree().create_tween()
	fade_tween.tween_property(self,"self_modulate:a", 0.0, 0.22)
	move_tween.tween_property(self,"position:y", posy-200, 0.22)
	fade_tween.finished.connect(queue_free)
	
func _despawn_lumber() -> void:
	SignalBus.lumber_despawned.emit()
	queue_free()
