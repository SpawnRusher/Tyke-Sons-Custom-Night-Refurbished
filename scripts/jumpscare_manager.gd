extends CanvasLayer

@export var jumpscare_sprite: AnimatedSprite2D

func _ready() -> void:
	SignalBus.jumpscare.connect(jumpscare_start)
	jumpscare_sprite.animation_finished.connect(_jumpscare_end)

func jumpscare_start(enemy: Enemy, area: Enemy.JUMPSCARE_AREAS) -> void:
	if not jumpscare_sprite.is_playing():
		get_tree().paused = true
		SceneManager.load_scene("res://scenes/game_over.tscn")
		SpecialFunctions.audio(enemy.jumpscare_sound,1)

		if enemy.jumpscare_middle_uid == null and enemy.jumpscare_bedroom_uid == null:
			push_error("No Jumpscare UIDs have been set for ",enemy,"!")

		if area == Enemy.JUMPSCARE_AREAS.MIDDLE and enemy.jumpscare_middle_uid == null:
			push_error("Enemy ",enemy," does not have a Jumpscare UID set for middle!")

		if area == Enemy.JUMPSCARE_AREAS.BEDROOM and enemy.jumpscare_bedroom_uid == null:
			push_error("Enemy ",enemy," does not have a Jumpscare UID set for bedroom!")

		if area == Enemy.JUMPSCARE_AREAS.MIDDLE:
			jumpscare_sprite.sprite_frames = load(enemy.jumpscare_middle_uid)
		if area == Enemy.JUMPSCARE_AREAS.BEDROOM:
			jumpscare_sprite.sprite_frames = load(enemy.jumpscare_bedroom_uid)

		jumpscare_sprite.play()
		show()
		Global.died_to_id = enemy.enemy_id

func _jumpscare_end() -> void:
	if not SaveData.settings_data["quality_of_life"]["auto_restart_on_death"]:
		SceneManager.change_to_scene("res://scenes/game_over.tscn",SceneManager.CHANGE_SCENE_BEHAVIOR.AWAIT)
	else:
		get_tree().paused = false
		get_tree().reload_current_scene()
