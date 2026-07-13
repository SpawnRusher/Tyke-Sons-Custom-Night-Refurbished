extends CanvasLayer

const SLEEPING: AudioStream = preload("uid://u3gc7rokd4kn")
const SLEEPING_FAKEOUT: AudioStream = preload("uid://b76771chtr3et")

@export var fade: ColorRect
@export var happyshroom: Happyshroom

func _ready() -> void:
	SignalBus.activate_happyshroom.connect(_activate_happyshroom)
	SignalBus.start_happyshroom_fight.connect(_start_happyshroom_fight)
	SignalBus.go_to_sleep.connect(_go_to_sleep)
		
func _go_to_sleep() -> void:
	if happyshroom != null and happyshroom.enabled == true and happyshroom.state == happyshroom.STATES.IDLE:
		add_child(SpecialFunctions.create_audio(SLEEPING_FAKEOUT))
	else:
		get_tree().add_child(SpecialFunctions.create_audio(SLEEPING,0,1,1,0,true,true))
	show()
	var tween = get_tree().create_tween()
	tween.set_pause_mode(tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade,"self_modulate:a",1,1)
	await get_tree().create_timer(4).timeout
	if happyshroom != null and happyshroom.enabled == true and happyshroom.state == happyshroom.STATES.IDLE:
		SignalBus.activate_happyshroom.emit()
	else:
		get_tree().change_scene_to_file("res://scenes/win_screen.tscn")

func _activate_happyshroom() -> void:
	happyshroom.state = happyshroom.STATES.INTRO
	hide()
	fade.self_modulate.a = 0

func _start_happyshroom_fight() -> void:
	happyshroom.state = happyshroom.STATES.ACTIVE
