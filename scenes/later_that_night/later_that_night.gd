extends Node2D

const RUNNING_UPSTAIRS: AudioStream = preload("uid://c12xjq2e7f4ix")

@export var background: Sprite2D
@export var text: Sprite2D
@export var fade: ColorRect


var enter_night: bool

func _ready() -> void:
	SceneManager.load_scene("res://scenes/night.tscn",false,false,"",false,ResourceLoader.CACHE_MODE_REUSE)
	if SaveData.get_data(SaveData.FILE_TYPE.SETTINGS,["game","skip_loading_night"]):
		print("skip load")
		enter_night = true
		return
	
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(fade,"self_modulate:a",0,0.5)
	
	var background_tween = get_tree().create_tween()
	background_tween.tween_property(background,"position:y",520,3).set_ease(Tween.EASE_IN)
	await get_tree().create_timer(2.3).timeout
	
	var fade_tween_2 = get_tree().create_tween()
	fade_tween_2.tween_property(fade,"self_modulate:a",1,0.5)
	
	var background_tween_2 = get_tree().create_tween()
	background_tween_2.tween_property(background,"scale",Vector2(10,10),0.5)
	
	await fade_tween_2.finished
	SpecialFunctions.create_audio(RUNNING_UPSTAIRS)
	await get_tree().create_timer(2).timeout
	
	enter_night = true

func _process(delta: float) -> void:
	if enter_night:
		if SceneManager.get_progress("res://scenes/night.tscn") >= 1:
			SceneManager.change_to_scene("res://scenes/night.tscn",SceneManager.CHANGE_SCENE_BEHAVIOR.AWAIT)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		fade.self_modulate.a = 1
		enter_night = true
