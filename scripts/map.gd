extends TextureRect

@export var office: AnimatedSprite2D
@export var player: TextureRect

var default_player_position: Vector2 = Vector2(68,54)

var window_positions: Dictionary = {
	"l": {
		"go":Vector2(11,default_player_position.y),
		"leave":default_player_position
		},
	"r": {
		"go":Vector2(121,default_player_position.y),
		"leave":default_player_position
		},
	"f": {
		"go":Vector2(default_player_position.x,11),
		"leave":default_player_position
		},
	"b": {
		"go":Vector2(default_player_position.x,192),
		"leave":default_player_position
		}
	}
	
var timer_durations: Dictionary = {
	"l": { 
		"go":0.14, 
		"leave":0.25 
		},
	"r": {
		"go":0.14,
		"leave":0.25
		},
	"f": {
		"go":0.18,
		"leave":0.12
		},
	"b": {
		"go":0.18,
		"leave":0.7
		}
	}

var tween_durations: Dictionary = {
	"l": { 
		"go":0.85,
		"leave":0.85
		},
	"r": {
		"go":0.85,
		"leave":0.85
		},
	"f": {
		"go":0.85,
		"leave":0.85
		},
	"b": {
		"go":1.6,
		"leave":1.4
		}
	}

var window_direction: String
var go_or_leave: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.activate_happyshroom.connect(_activate_happyshroom)
	office.animation_changed.connect(_player_icon_tween)
	player.position = default_player_position

func _player_icon_tween() -> void:
	window_direction = office.animation.right(1)
	go_or_leave = office.animation.left(office.animation.length()-2)
	if "go" in go_or_leave or "leave" in go_or_leave:
		#await get_tree().create_timer(timer_durations[window_direction][go_or_leave]).timeout
		var player_tween = get_tree().current_scene.create_tween()
		player_tween.tween_property(player,"position",window_positions[window_direction][go_or_leave],tween_durations[window_direction][go_or_leave]+timer_durations[window_direction][go_or_leave]).set_trans(Tween.TRANS_LINEAR)

func _activate_happyshroom() -> void:
	player.position = default_player_position
