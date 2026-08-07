extends Node2D

const FOREST_DAWN: AudioStream = preload("uid://hnoau12gy4nu")
const FLASHLIGHT: AudioStream = preload("uid://b1ly4og0c82sg")

@export var go_to_sleep: CanvasLayer
@export var debug_console: Window

var forest_dawn_audio: AudioStreamPlayer

func _ready() -> void:
	PauseManager.unpause()
	SignalBus.go_to_sleep.connect(_go_to_sleep)
	forest_dawn_audio = SpecialFunctions.create_audio(FOREST_DAWN,0,0.2,1,-1)
	SpecialFunctions.create_audio(FLASHLIGHT)
	SpecialFunctions.create_audio(FLASHLIGHT)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_console"):
		if debug_console.visible:
			debug_console.hide()
		else:
			debug_console.show()

func _go_to_sleep() -> void:
	PauseManager.pause()
	forest_dawn_audio.queue_free()
