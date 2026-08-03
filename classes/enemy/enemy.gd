class_name Enemy extends Node

enum ENEMY_IDS {CHIPOMAT_1, CHIPOMAT_2, CHIPOMAT_3, FUN_FUNGAL, SPRINGCRAB, NIGHTMARE_CHIPPER, SEABILL, FREDBEAR, BIDY, BUSTER, BRUCE, CHIPPER, TOY, PHANTOM_CHIPOMAT, HAPPYSHROOM}
	
enum JUMPSCARE_AREAS {MIDDLE, BEDROOM}


@export_group("Enemy Details")
@export var enemy_id: ENEMY_IDS = -1
@export var sleep_assurance_score: float = -1
@export_group("Jumpscare Details")
@export var jumpscare_sound: AudioStream
@export_file var jumpscares_files: Array[String]

var enabled: bool

func _ready() -> void:
	if enemy_id == -1:
		push_error("An Enemy ID has not been set for one of the enemies! Running _deactivate()")
		_deactivate()
		return
	if sleep_assurance_score == -1:
		push_error("Sleep assurance score has not been set for ",ENEMY_IDS.keys()[enemy_id],"!")
	if jumpscare_sound == null:
		push_error("Jumpscare Sound has not yet been set for enemy ",ENEMY_IDS.keys()[enemy_id],"!")
	if jumpscares_files.is_empty():
		push_error("No jumpscares have been set for ",ENEMY_IDS.keys()[enemy_id],"!")
	if enemy_id != ENEMY_IDS.HAPPYSHROOM:
		enabled = GameInfo.enabled_ids[enemy_id]
	else:
		enabled = false not in GameInfo.enabled_ids
		
	if GameInfo.happyshroom_test_mode:
		if enemy_id != ENEMY_IDS.HAPPYSHROOM:
			enabled = false
		else:
			enabled = true
		
	if not enabled:
		_deactivate()

func _deactivate() -> void: 
	self.queue_free()
		
func _jumpscare(area:= JUMPSCARE_AREAS.MIDDLE) -> void:
	SignalBus.jumpscare.emit(self, area)
