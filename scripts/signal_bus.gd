extends Node

# warnings-disable

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

signal pastebin_version_check(version_type: String, pastebin_version: String)

signal jumpscare(enemy: Enemy, area: String)
signal phantom_jumpscare()
signal happyshroom_jumpscare(area: String)

signal save_data_loaded()

signal flashlight_off()
signal flashlight_on()
signal update_flashlight_state(flashlight_state: bool)

signal pickup_lumber()
signal lumber_despawned()

signal enemy_defended(enemy: Enemy)
signal broadcast_sleep_assurance_score(score: float)
signal remove_sleep_assurance(delta: float, enemy: Enemy)
signal activate_happyshroom()
signal start_happyshroom_fight()

signal go_to_sleep()
