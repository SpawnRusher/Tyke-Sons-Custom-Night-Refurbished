extends AnimatedSprite2D

@onready var early_bird = $"../"

func _ready() -> void:
	position.x = randf_range(early_bird.position.x-(early_bird.texture.get_width()/2),early_bird.position.x+(early_bird.texture.get_width()/2))
	position.y = randf_range(early_bird.position.y-(early_bird.texture.get_height()/2),early_bird.position.y+(early_bird.texture.get_height()/2))
	play("star")
	#animation_finished.connect(queue_free)
