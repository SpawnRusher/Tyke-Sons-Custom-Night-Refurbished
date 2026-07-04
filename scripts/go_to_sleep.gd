extends CanvasLayer

const SLEEPING: AudioStream = preload("uid://u3gc7rokd4kn")
const SLEEPING_FAKEOUT: AudioStream = preload("uid://b76771chtr3et")


@export var fade: ColorRect

var happyshroom_active: bool

func _ready() -> void:
	SignalBus.activate_happyshroom.connect(_activate_happyshroom)
	SignalBus.go_to_sleep.connect(_go_to_sleep)
		
func _go_to_sleep() -> void:
	if Global.ENABLED_IDS[Enemy.ENEMY_IDS.HAPPYSHROOM] and not happyshroom_active:
		SpecialFunctions.audio(SLEEPING_FAKEOUT,0,1,1,0,0,0,true,true)
	else:
		SpecialFunctions.audio(SLEEPING,0,1,1,0,0,0,true,true)
	show()
	var tween = get_tree().create_tween()
	tween.set_pause_mode(tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade,"self_modulate:a",1,1)
	await get_tree().create_timer(4).timeout
	if Global.ENABLED_IDS[Enemy.ENEMY_IDS.HAPPYSHROOM] and not happyshroom_active:
		SignalBus.activate_happyshroom.emit()
	else:
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")

func _activate_happyshroom() -> void:
	happyshroom_active = true
	hide()
	fade.self_modulate.a = 0
