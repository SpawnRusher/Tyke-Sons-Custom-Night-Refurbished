extends Enemy
class_name Bruce

func _ready() -> void:
	await super()
	if enabled == false:
		deactivate()
		return

func deactivate() -> void:
	self.queue_free()
