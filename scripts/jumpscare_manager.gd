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

		if enemy.jumpscare_uids.size() == 0:
			push_error("No Jumpscare UIDs have been set for ",Enemy.ENEMY_IDS.keys()[enemy],"! Jumpscare will not start.")
			return
			
		if area > enemy.jumpscare_uids.size():
			push_error("Enemy ",Enemy.ENEMY_IDS.keys()[enemy.enemy_id]," does not have a Jumpscare UID set for ",Enemy.JUMPSCARE_AREAS.keys()[area], "! Falling back to another UID.")
			area = enemy.jumpscare_uids.find(enemy.jumpscare_uids.pick_random()) as Enemy.JUMPSCARE_AREAS
		
		jumpscare_sprite.sprite_frames = load(enemy.jumpscare_uids[area])

		jumpscare_sprite.play()
		show()
		Global.died_to_id = enemy.enemy_id

func _jumpscare_end() -> void:
	if not SaveData.settings_data["game"]["auto_restart_on_death"]:
		SceneManager.change_to_scene("res://scenes/game_over.tscn",SceneManager.CHANGE_SCENE_BEHAVIOR.AWAIT)
	else:
		get_tree().paused = false
		get_tree().reload_current_scene()
