extends Node2D

const FOREST_DAWN: AudioStream = preload("uid://hnoau12gy4nu")
const FLASHLIGHT: AudioStream = preload("uid://b1ly4og0c82sg")

@export var go_to_sleep: CanvasLayer

func _ready() -> void:
	get_tree().paused = false
	SignalBus.go_to_sleep.connect(_go_to_sleep)
	SpecialFunctions.audio(FOREST_DAWN,0,0.2,1,0,0,-1,false,false)
	SpecialFunctions.audio(FLASHLIGHT)
	SpecialFunctions.audio(FLASHLIGHT)
	
func _go_to_sleep() -> void:
	get_tree().paused = true
	var nodes = get_children()
	for i in nodes:
		if i is AudioStreamPlayer or i is AudioStreamPlayer2D:
			i.queue_free()
