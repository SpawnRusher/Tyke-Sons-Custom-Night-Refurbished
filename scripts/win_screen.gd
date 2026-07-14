extends Node2D

const ALARM_CLOCK = preload("uid://bgjqo7poflqnr")

const STAR = preload("uid://gut8g6qau2e3")

@export var wake_up: AnimatedSprite2D
@export var early_bird: Sprite2D
@export var fade: ColorRect
@export var night_timer: RichTextLabel

var can_leave: bool

func _ready() -> void:
	PauseManager.unpause()
	_go_to_sleep()
	wake_up.animation_finished.connect(_wake_up_loop)
	_add_gamejolt_scores()
	_achieve_gamejolt_trophies()
	
	@warning_ignore_start("integer_division")
	var time_milliseconds = (Global.win_time % 1000) / 10
	var time_seconds = (Global.win_time / 1000) % 60
	var time_minutes = ((Global.win_time / 1000) / 60) % 60
	night_timer.text = "Time taken: " + "%02d:%02d.%02d" % [time_minutes, time_seconds, time_milliseconds]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		if can_leave == true:
			_leave()

func _go_to_sleep() -> void:
	add_child(SpecialFunctions.create_audio(ALARM_CLOCK))
	wake_up.visible = true
	wake_up.play("wake_up")
	await get_tree().create_timer(5.8).timeout
	early_bird.visible = true
	add_child(SpecialFunctions.create_timer(_create_star,0.02,19))
	add_child(SpecialFunctions.create_timer(_create_star,0.02,19))
	add_child(SpecialFunctions.create_timer(_create_star,0.02,19))
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

func _add_gamejolt_scores() -> void:
	if Global.current_preset_name == "Sleep Insomnia":
		GameJolt.api_request("scores","add",{"username":GameJolt.authorized_username,"user_token":GameJolt.authorized_user_token,"score":night_timer.text,"sort":Global.win_time,"table_id":"1091328",})
	
func _achieve_gamejolt_trophies() -> void:
	if Global.current_preset_name == "Sleep Insomnia":
		GameJolt.api_request("trophies","add_achieved",{"username":GameJolt.authorized_username,"user_token":GameJolt.authorized_user_token,"trophy_id":"0"})
	
	
	
	
