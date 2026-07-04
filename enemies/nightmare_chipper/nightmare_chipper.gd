extends Enemy
class_name Nightmare_Chipper

func _ready() -> void:
	super()
	if not enabled: return

func _deactivate() -> void:
	super()
