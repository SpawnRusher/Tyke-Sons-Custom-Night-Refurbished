extends Node2D

@onready var text = $game_over
@onready var bg = $game_over_background
@onready var white_fade = $white_fade

@onready var default_x = text.position.x
@onready var default_y = text.position.y

const GAMEOVER = preload("uid://yg3504dqept7")

var DEATH_VOICELINES: Dictionary[int,Array] = {
	5: [preload("uid://b5id48dqwf0m4"), preload("uid://ckgneeohdoe85"), preload("uid://cimbwjjv8yekq")],
	6: [preload("uid://f253c7ggekbv"), preload("uid://cdy8jvlnt2uel"), preload("uid://exn4yf15x3em")],
	7: [preload("uid://dc4svouk7k6ls")],
	14: [preload("uid://brmixgfcobol8"), preload("uid://smfc84cdnkb5"), preload("uid://ccgiqqc6k6nd")]
	}

func _ready() -> void:
	SpecialFunctions.audio(GAMEOVER,1,1,0,0,0,false)
	SpecialFunctions.timer(move_game_over_text,0.04,0,-1,0,0,false)
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(white_fade,"modulate:a",0,1)
	if Global.died_to_id in DEATH_VOICELINES:
		SpecialFunctions.audio(DEATH_VOICELINES[Global.died_to_id].pick_random())
	
func _input(event) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/menu.tscn")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_tree().change_scene_to_file("res://scenes/night.tscn")

func move_game_over_text() -> void:
	text.position.x = default_x + randi_range(-3,3)
	text.position.y = default_y + randi_range(-3,3)
