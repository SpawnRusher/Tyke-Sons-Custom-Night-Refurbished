extends Node2D

@export var game_over_background: Sprite2D
@export var game_over_text: Sprite2D
@export var white_fade: ColorRect

@onready var default_text_position: Vector2 = game_over_text.position

const GAMEOVER: AudioStream = preload("uid://yg3504dqept7")

var DEATH_VOICELINES: Dictionary[int,Array] = {
	Enemy.ENEMY_IDS.SPRINGCRAB: [preload("uid://b5id48dqwf0m4"), preload("uid://ckgneeohdoe85"), preload("uid://cimbwjjv8yekq")],
	Enemy.ENEMY_IDS.NIGHTMARE_CHIPPER: [preload("uid://f253c7ggekbv"), preload("uid://cdy8jvlnt2uel"), preload("uid://exn4yf15x3em")],
	Enemy.ENEMY_IDS.SEABILL: [preload("uid://brmixgfcobol8"), preload("uid://smfc84cdnkb5"), preload("uid://ccgiqqc6k6nd")],
	Enemy.ENEMY_IDS.HAPPYSHROOM: [preload("uid://dc4svouk7k6ls")]
	}

func _ready() -> void:
	get_tree().paused = false
	SceneManager.load_scene("res://scenes/menu.tscn")
	SceneManager.load_scene("res://scenes/night.tscn")
	SpecialFunctions.audio(GAMEOVER,0,1,1,0,0,0,false,true)
	SpecialFunctions.timer(move_game_over_text,0.04,0,-1,0,0,false,false,true)
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(white_fade,"modulate:a",0,1)
	if Global.died_to_id in DEATH_VOICELINES:
		SpecialFunctions.audio(DEATH_VOICELINES[Global.died_to_id].pick_random())
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			SceneManager.change_to_scene("res://scenes/menu.tscn",SceneManager.CHANGE_SCENE_BEHAVIOR.AWAIT)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			SceneManager.change_to_scene("res://scenes/night.tscn",SceneManager.CHANGE_SCENE_BEHAVIOR.AWAIT)

func move_game_over_text() -> void:
	game_over_text.position.x = default_text_position.x + randi_range(-3,3)
	game_over_text.position.y = default_text_position.y + randi_range(-3,3)
