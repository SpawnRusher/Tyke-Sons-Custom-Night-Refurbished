extends CanvasLayer

const SLEEPING = preload("uid://u3gc7rokd4kn")

@onready var fade = $Fade

func _notification(what: int) -> void:
	if what == NOTIFICATION_UNPAUSED:
		go_to_sleep()
		
func go_to_sleep():
	
	SpecialFunctions.audio(SLEEPING,1,1,0,0,0,true,true)
	fade.visible = true
	var tween = get_tree().create_tween()
	tween.set_pause_mode(tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(fade,"self_modulate:a",1,1)
	await get_tree().create_timer(4).timeout
	get_tree().change_scene_to_file("res://scenes/win_screen.tscn")
