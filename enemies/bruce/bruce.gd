extends Enemy
class_name Bruce

func _ready() -> void:
	await super()
	if enabled == false:
		self.queue_free()
		#sprite.queue_free()
		return
