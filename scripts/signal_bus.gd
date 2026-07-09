extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

@warning_ignore_start("unused_signal")
signal pastebin_version_check(version_type: PastebinChecks.VERSION_TYPE, pastebin_version: String)

signal jumpscare(enemy: Enemy, area: Enemy.JUMPSCARE_AREAS)
signal phantom_jumpscare()

signal save_data_loaded()

signal change_camera_position(pos: int)

signal flashlight_off()
signal flashlight_on()
signal update_flashlight_state(state: Global.FLASHLIGHT_STATES)

signal pickup_lumber()
signal lumber_despawned()

signal enemy_defended(enemy: Enemy)
signal remove_sleep_assurance(delta: float, enemy: Enemy)
signal activate_happyshroom()
signal start_happyshroom_fight()

signal go_to_sleep()
