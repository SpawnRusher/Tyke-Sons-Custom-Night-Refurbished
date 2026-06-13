extends Node2D

const ALARM_CLOCK = preload("uid://bgjqo7poflqnr")

const STAR = preload("uid://gut8g6qau2e3")

@onready var wake_up = $Wake_Up
@onready var early_bird = $Early_Bird
@onready var fade: ColorRect = $Fade


var can_leave: bool


func _ready() -> void:
	get_tree().paused = false
	go_to_sleep()
	wake_up.animation_finished.connect(_wake_up_loop)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		if can_leave == true:
			_leave()

func go_to_sleep():
	SpecialFunctions.audio(ALARM_CLOCK)
	wake_up.visible = true
	wake_up.play("wake_up")
	await get_tree().create_timer(5.8).timeout
	early_bird.visible = true
	SpecialFunctions.timer(_create_star,0.02,0,19,0,0,false,false,false)
	SpecialFunctions.timer(_create_star,0.02,0,19,0,0,false,false,false)
	SpecialFunctions.timer(_create_star,0.02,0,19,0,0,false,false,false)
	can_leave = true
	
func _create_star():
	var star = STAR.instantiate()
	early_bird.add_child(star)

func _leave():
	fade.visible = true
	var tween = get_tree().create_tween()
	tween.tween_property(fade,"self_modulate:a",1,1)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
func _wake_up_loop():
	wake_up.play("loop")
