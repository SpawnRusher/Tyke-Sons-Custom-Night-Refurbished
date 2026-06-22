extends Enemy
class_name Nightmare_Chipper

func _ready() -> void:
	await super()
	if enabled == false:
		deactivate()
		return

func deactivate() -> void:
	self.queue_free()
