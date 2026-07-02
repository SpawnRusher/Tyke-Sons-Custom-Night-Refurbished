extends Camera2D

var goto: float = 200
var lockpos: float = -1

@export var office: AnimatedSprite2D

func _ready() -> void:
	position.x = goto

func _process(_delta: float) -> void:
	_move_camera()

func _move_camera() -> void:
	if lockpos != -1:
		position.x = lockpos
		return
		
	if SaveData.settings_data["game"]["use_old_camera_scrolling"] == false:
		goto = 200 +((office.get_local_mouse_position().x - 840) / 4.1)
		goto = clampf(goto,0,400)
		position.x = goto
		return
		
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.x < 200:
		var scroll_tween = get_tree().create_tween()
		scroll_tween.tween_property(self,"position:x",max(0,position.x-18),0.02)
		await scroll_tween.finished
	if mouse_pos.x > 1080:
		var scroll_tween = get_tree().create_tween()
		scroll_tween.tween_property(self,"position:x",min(position.x+18,400),0.02)
		await scroll_tween.finished
