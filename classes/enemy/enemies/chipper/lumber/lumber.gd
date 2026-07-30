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

signal lumber_picked_up()
signal lumber_despawned()

func _ready() -> void:
	_create_lumber()
	
func _process(delta: float) -> void:
	lumber_timer -= (active as int) * delta
	if lumber_timer <= 0:
		_despawn_lumber()
		
func _has_point(point: Vector2) -> bool:
	if point.x < 0 or point.y < 0:
		return false
	if point.x >= texture.get_width() or point.y >= texture.get_height():
		return false
	if texture.get_image().get_pixelv(point).a <= 0.3:
		return false
	return true
		
func _create_lumber() -> void:
	lumber_color = LUMBER_COLORS.values().pick_random()
	texture = load(LUMBER_COLOR_SPRITE_UIDS[lumber_color])
	position = Vector2(randi_range(100,1180-texture.get_width()),randi_range(100,620-texture.get_height()))

func _on_mouse_entered() -> void:
	_pickup_lumber()
	
func _pickup_lumber() -> void:
	active = false
	SpecialFunctions.create_audio(LUMBER_PICKUP)
	lumber_picked_up.emit()
	var fade_tween = get_tree().create_tween()
	var move_tween = get_tree().create_tween()
	fade_tween.tween_property(self,"self_modulate:a", 0.0, 0.22)
	move_tween.tween_property(self,"position:y", posy-200, 0.22)
	fade_tween.finished.connect(queue_free)
	
func _despawn_lumber() -> void:
	lumber_despawned.emit()
	queue_free()
