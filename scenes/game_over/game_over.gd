extends Node2D

@export var game_over_background: Sprite2D
@export var game_over_text: Sprite2D
@export var white_fade: ColorRect
@export var night_timer: RichTextLabel
@export var sleep_assurance: RichTextLabel

@onready var default_text_position: Vector2 = game_over_text.position

const GAMEOVER: AudioStream = preload("uid://yg3504dqept7")

const DEATH_VOICELINES: Dictionary[Enemy.ENEMY_IDS,Array] = {
	Enemy.ENEMY_IDS.SPRINGCRAB: [preload("uid://b5id48dqwf0m4"), preload("uid://ckgneeohdoe85"), preload("uid://cimbwjjv8yekq")],
	Enemy.ENEMY_IDS.NIGHTMARE_CHIPPER: [preload("uid://f253c7ggekbv"), preload("uid://cdy8jvlnt2uel"), preload("uid://exn4yf15x3em")],
	Enemy.ENEMY_IDS.SEABILL: [preload("uid://brmixgfcobol8"), preload("uid://smfc84cdnkb5"), preload("uid://ccgiqqc6k6nd")],
	Enemy.ENEMY_IDS.HAPPYSHROOM: [preload("uid://dc4svouk7k6ls")] }

func _ready() -> void:
	PauseManager.unpause()
	SceneManager.load_scene("res://scenes/menu.tscn")
	SceneManager.load_scene("res://scenes/night.tscn")
	SpecialFunctions.create_audio(GAMEOVER)
	SpecialFunctions.create_timer(_move_game_over_text,0.04,-1)
	_gamejolt_add_scores()
	@warning_ignore_start("integer_division")
	var time_milliseconds = (Global.dead_time % 1000) / 10
	var time_seconds = (Global.dead_time / 1000) % 60
	var time_minutes = ((Global.dead_time / 1000) / 60) % 60
	night_timer.text = ("Time: " + "%02d:%02d.%02d" % [time_minutes, time_seconds, time_milliseconds])
	sleep_assurance.text = "Sleep Assurance: " + str(snappedf(Global.dead_sleep_assurance*100,0.01))+"%"
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(white_fade,"modulate:a",0,1)
	if Global.dead_enemy_id in DEATH_VOICELINES:
		SpecialFunctions.create_audio(DEATH_VOICELINES[Global.dead_enemy_id].pick_random())
	Global.dead_enemy_id = -1
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			SceneManager.change_to_scene("res://scenes/menu.tscn",SceneManager.CHANGE_SCENE_BEHAVIOR.AWAIT)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			SceneManager.change_to_scene("res://scenes/night.tscn",SceneManager.CHANGE_SCENE_BEHAVIOR.AWAIT)

func _move_game_over_text() -> void:
	game_over_text.position = default_text_position + Vector2(randi_range(-3,3),randi_range(-3,3))

func _gamejolt_add_scores() -> void:
	if Global.current_preset_name == "Sleep Insomnia" and Global.survival_mode:
		GameJolt.api_request("scores","add",{"username":GameJolt.authorized_username,"user_token":GameJolt.authorized_user_token,"table_id":"1097836","sort":str(Global.dead_time),"score":night_timer.text.right(night_timer.text.length()-6)},{})
		
		
		
		
