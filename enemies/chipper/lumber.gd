extends TextureRect
class_name Lumber

var LUMBER_COLORS: Array = ["brown","black","red"]

var LUMBER_IMAGE_PATHS: Dictionary = {
	"brown": "uid://wkwoyiyrresu",
	"black": "uid://7koqfbasjup3",
	"red": "uid://dpi8k1s553fm0" }
	
const LUMBER_PICKUP = preload("uid://dbw4rno7ypmsk")

var lumber_color: String
var posx: float
var posy: float
var lumber_timer: float

@onready var camera = get_viewport().get_camera_2d()

func _ready() -> void:
	create_lumber(self)
	
func _process(delta: float) -> void:
	lumber_timer -= 1 * delta
	if lumber_timer <= 0:
		despawn_lumber()

func create_lumber(lumber: Lumber) -> void:
	lumber_color = LUMBER_COLORS.pick_random()
	lumber.texture = load(LUMBER_IMAGE_PATHS[lumber_color])
	posx = randi_range(150,1130-texture.get_width())
	posy = randi_range(150,570-texture.get_height())
	lumber.position = Vector2(posx,posy)
	
func _on_mouse_entered() -> void:
	pickup_lumber()
	
func pickup_lumber() -> void:
	SpecialFunctions.audio(LUMBER_PICKUP)
	SignalBus.pickup_lumber.emit()
	var fade_tween = get_tree().create_tween()
	var move_tween = get_tree().create_tween()
	fade_tween.tween_property(self,"self_modulate:a", 0.0, 0.22)
	move_tween.tween_property(self,"position:y", posy-200, 0.22)
	fade_tween.finished.connect(queue_free)
	
func despawn_lumber() -> void:
	SignalBus.lumber_despawned.emit()
	queue_free()
