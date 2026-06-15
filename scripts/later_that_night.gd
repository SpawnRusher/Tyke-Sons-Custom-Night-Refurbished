extends Node2D

const STAIRSUP = preload("uid://c12xjq2e7f4ix")

@onready var background = $Background
@onready var text = $Text
@onready var fade = $Fade


func _ready() -> void:
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(fade,"self_modulate:a",0,2)
	
	var background_tween = get_tree().create_tween()
	background_tween.tween_property(background,"position:y",520,7)
	await get_tree().create_timer(6).timeout
	
	
	var fade_tween_2 = get_tree().create_tween()
	fade_tween_2.tween_property(fade,"self_modulate:a",1,0.7)
	
	var background_tween_2 = get_tree().create_tween()
	background_tween_2.tween_property(background,"scale",Vector2(10,10),1)
	
	await fade_tween_2.finished
	SpecialFunctions.audio(STAIRSUP)
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://scenes/night.tscn")
