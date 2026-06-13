extends Node2D

@onready var go_to_sleep: CanvasLayer = $Go_To_Sleep

func _ready() -> void:
	SignalBus.go_to_sleep.connect(_go_to_sleep)
	
func _go_to_sleep() -> void:
	go_to_sleep.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	get_tree().paused = true
	
	
