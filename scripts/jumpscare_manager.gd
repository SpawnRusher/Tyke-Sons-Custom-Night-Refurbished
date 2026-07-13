extends CanvasLayer

@export var jumpscare_sprite: AnimatedSprite2D
@export var sleep_assurance: RichTextLabel
@export var night_timer: RichTextLabel

func _ready() -> void:
	SignalBus.jumpscare.connect(jumpscare_start)
	jumpscare_sprite.animation_finished.connect(_jumpscare_end)

func jumpscare_start(enemy: Enemy, area: Enemy.JUMPSCARE_AREAS) -> void:
	if not jumpscare_sprite.is_playing():
		PauseManager.pause()
		Global.dead_enemy_id = enemy.enemy_id
		Global.dead_sleep_assurance = sleep_assurance.sleep_assurance_normal
		Global.dead_time = night_timer.time_elapsed
		SceneManager.load_scene("res://scenes/game_over.tscn")
		add_child(SpecialFunctions.create_audio(enemy.jumpscare_sound,1))

		if enemy.jumpscares.size() == 0:
			push_error("No Jumpscare UIDs have been set for ",Enemy.ENEMY_IDS.keys()[enemy],"! Jumpscare will not start.")
			return
			
		if area > enemy.jumpscares.size():
			push_error("Enemy ",Enemy.ENEMY_IDS.keys()[enemy.enemy_id]," does not have a Jumpscare UID set for ",Enemy.JUMPSCARE_AREAS.keys()[area], "! Falling back to another UID.")
			area = enemy.jumpscares.find(enemy.jumpscares.pick_random()) as Enemy.JUMPSCARE_AREAS
		
		jumpscare_sprite.sprite_frames = enemy.jumpscares[area]
		jumpscare_sprite.play()
		show()

func _jumpscare_end() -> void:
	if not SaveData.settings_data["game"]["auto_restart_on_death"]:
		SceneManager.change_to_scene("res://scenes/game_over.tscn",SceneManager.CHANGE_SCENE_BEHAVIOR.AWAIT)
	else:
		PauseManager.unpause()
		get_tree().reload_current_scene()
