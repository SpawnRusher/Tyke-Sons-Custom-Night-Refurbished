extends Camera2D

var lockpos: float = -1

@export var office: AnimatedSprite2D

func _ready() -> void:
	SignalBus.change_camera_position.connect(_change_camera_position)
	position.x = 200

func _process(_delta: float) -> void:
	_move_camera()

func _change_camera_position(to_pos:=-1) -> void:
	to_pos = max(-1,to_pos)
	if to_pos == -1:
		if lockpos != -1:
			lockpos = -1
			if SaveData.get_data(SaveData.FILE_TYPE.SETTINGS,["game","use_old_camera_scrolling"]):
				position.x = 200
		return
	lockpos = to_pos

func _move_camera() -> void:
	if lockpos != -1:
		position.x = lockpos
		return
	
	if not SaveData.get_data(SaveData.FILE_TYPE.SETTINGS,["game","use_old_camera_scrolling"]):
		position.x = clampf(200 + ((office.get_local_mouse_position().x - 840) / 4.1), 0, 400)
		return
	
	if office.animation == "office":
		var mouse_pos = get_viewport().get_mouse_position()
		if mouse_pos.x < 320:
			var scroll_tween = get_tree().create_tween()
			scroll_tween.tween_property(self,"position:x",max(0,position.x-18),0.02)
			await scroll_tween.finished
		if mouse_pos.x > 960:
			var scroll_tween = get_tree().create_tween()
			scroll_tween.tween_property(self,"position:x",min(position.x+18,400),0.02)
			await scroll_tween.finished
