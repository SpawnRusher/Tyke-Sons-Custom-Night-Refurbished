extends Node2D

const ALARM_CLOCK = preload("uid://bgjqo7poflqnr")

const STAR = preload("uid://gut8g6qau2e3")

@export var wake_up: AnimatedSprite2D
@export var early_bird: Sprite2D
@export var fade: ColorRect

var can_leave: bool


func _ready() -> void:
	get_tree().paused = false
	_go_to_sleep()
	wake_up.animation_finished.connect(_wake_up_loop)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		if can_leave == true:
			_leave()

func _go_to_sleep() -> void:
	SpecialFunctions.audio(ALARM_CLOCK)
	wake_up.visible = true
	wake_up.play("wake_up")
	await get_tree().create_timer(5.8).timeout
	early_bird.visible = true
	SpecialFunctions.timer(_create_star,0.02,0,19,0,0,false,false,false)
	SpecialFunctions.timer(_create_star,0.02,0,19,0,0,false,false,false)
	SpecialFunctions.timer(_create_star,0.02,0,19,0,0,false,false,false)
	can_leave = true
	
func _create_star() -> void:
	var star: Node = STAR.instantiate()
	early_bird.add_child(star)

func _leave() -> void:
	fade.visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(fade,"self_modulate:a",1,1)
	await tween.finished
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
func _wake_up_loop() -> void:
	wake_up.play("loop")
