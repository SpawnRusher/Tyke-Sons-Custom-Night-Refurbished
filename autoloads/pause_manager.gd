extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	
func unpause() -> void:
	if get_tree().paused:
		get_tree().paused = false
		print_debug("Tree Unpaused")
	
func pause() -> void:
	if not get_tree().paused:
		get_tree().paused = true
		print_debug("Tree Paused")
