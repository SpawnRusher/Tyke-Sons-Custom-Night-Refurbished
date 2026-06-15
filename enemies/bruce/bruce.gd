extends Enemy
class_name Bruce

func _ready() -> void:
	await super()
	if enabled == false:
		_queue_free()
		return

func _queue_free():
	self.queue_free()
