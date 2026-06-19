extends CanvasLayer

@onready var jumpscare_sprite = $Jumpscare_Animations

const JUMPSCARE_WTF = preload("uid://dvfy70t3fg5oc")

func _ready() -> void:
	SignalBus.jumpscare.connect(_jumpscare_start)
	SignalBus.happyshroom_jumpscare.connect(_happyshroom_jumpscare)
	jumpscare_sprite.animation_finished.connect(_jumpscare_end)

func _jumpscare_start(enemy: Enemy, area: String) -> void:
	if not jumpscare_sprite.is_playing():
		get_tree().paused = true
		SceneManager.load_scene("res://scenes/game_over.tscn")
		SpecialFunctions.audio(enemy.jumpscare_sound,1)

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

func _happyshroom_jumpscare(area: String):
	if not jumpscare_sprite.is_playing():
		SceneManager.load_scene("res://scenes/game_over.tscn")
		get_tree().paused = true
		SpecialFunctions.audio(JUMPSCARE_WTF,1)
		if area == "middle":
			jumpscare_sprite.sprite_frames = load("uid://def4na0hddbtv")
		if area == "bedroom":
			jumpscare_sprite.sprite_frames = load("uid://ceyirmcu15e87")
			
		jumpscare_sprite.play()
		show()
		Global.died_to_id = 15

func _jumpscare_end():
		SceneManager.change_to_scene("res://scenes/game_over.tscn",SceneManager.CHANGE_SCENE_BEHAVIOR.AWAIT)
