extends AnimatedSprite2D

@onready var office = $"../../Office/Office_BG"
@onready var player = $Map_Player_Icon


@onready var default_player_x: float = player.position.x
@onready var default_player_y: float = player.position.y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.activate_happyshroom.connect(_activate_happyshroom)
	office.animation_changed.connect(player_icon_tween)


func player_icon_tween():
	if office.animation == "go_l":
		await get_tree().create_timer(0.14).timeout
		var player_tween = get_tree().current_scene.create_tween()
		player_tween.tween_property(player,"position:x",-63.0,0.85).set_trans(Tween.TRANS_LINEAR)
	if office.animation == "leave_l":
		await get_tree().create_timer(0.25).timeout
		var player_tween = get_tree().current_scene.create_tween()
		player_tween.tween_property(player,"position:x",default_player_x,0.85).set_trans(Tween.TRANS_LINEAR)
	if office.animation == "go_r":
		await get_tree().create_timer(0.14).timeout
		var player_tween = get_tree().current_scene.create_tween()
		player_tween.tween_property(player,"position:x",45.0,0.85).set_trans(Tween.TRANS_LINEAR)
	if office.animation == "leave_r":
		await get_tree().create_timer(0.25).timeout
		var player_tween = get_tree().current_scene.create_tween()
		player_tween.tween_property(player,"position:x",default_player_x,0.85).set_trans(Tween.TRANS_LINEAR)
	if office.animation == "go_f":
		await get_tree().create_timer(0.18).timeout
		var player_tween = get_tree().current_scene.create_tween()
		player_tween.tween_property(player,"position:y",-137,0.85).set_trans(Tween.TRANS_LINEAR)
	if office.animation == "leave_f":
		await get_tree().create_timer(0.12).timeout
		var player_tween = get_tree().current_scene.create_tween()
		player_tween.tween_property(player,"position:y",default_player_y,0.85).set_trans(Tween.TRANS_LINEAR)
	if office.animation == "go_b":
		await get_tree().create_timer(0.18).timeout
		var player_tween = get_tree().current_scene.create_tween()
		player_tween.tween_property(player,"position:y",41,1.6).set_trans(Tween.TRANS_LINEAR)
	if office.animation == "leave_b":
		await get_tree().create_timer(0.7).timeout
		var player_tween = get_tree().current_scene.create_tween()
		player_tween.tween_property(player,"position:y",default_player_y,1.4).set_trans(Tween.TRANS_LINEAR)

func _activate_happyshroom():
	player.position.x = default_player_x
	player.position.y = default_player_y
