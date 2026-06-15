extends CanvasLayer

@onready var jumpscare_sprite = $Jumpscare_Animations

func _ready() -> void:
	SignalBus.jumpscare.connect(jumpscare_start)
	jumpscare_sprite.animation_finished.connect(jumpscare_end)

func jumpscare_start(enemy: Enemy, area: String) -> void:
	if not jumpscare_sprite.is_playing():
		get_tree().paused = true
		SpecialFunctions.audio(enemy.jumpscare_sound)
		
		if enemy.jumpscare_middle_uid == null and enemy.jumpscare_bedroom_uid == null:
			push_error("No Jumpscare UIDs have been set for ",enemy,"!")
			
		if area == "middle" and enemy.jumpscare_middle_uid == null:
			push_error("Enemy ",enemy," does not have a Jumpscare UID set for middle!")

		if area == "bedroom" and enemy.jumpscare_bedroom_uid == null:
			push_error("Enemy ",enemy," does not have a Jumpscare UID set for bedroom!")
			
		if area == "middle":
			jumpscare_sprite.sprite_frames = load(enemy.jumpscare_middle_uid)
		if area == "bedroom":
			jumpscare_sprite.sprite_frames = load(enemy.jumpscare_bedroom_uid)
			
		jumpscare_sprite.play()
		show()
		Global.died_to_id = enemy.enemy_id


func jumpscare_end():
		get_tree().change_scene_to_file("res://scenes/game_over.tscn")
