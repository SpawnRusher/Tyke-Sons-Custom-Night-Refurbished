extends Node
class_name Enemy

enum ENEMY_IDS {NOT_SET=-1, CHIPOMAT_1, CHIPOMAT_2, CHIPOMAT_3, FUN_FUNGAL, SPRINGCRAB, NIGHTMARE_CHIPPER, SEABILL, FREDBEAR, BIDY, BUSTER, BRUCE, CHIPPER, TOY, PHANTOM_CHIPOMAT, HAPPYSHROOM}
	
enum JUMPSCARE_AREAS {MIDDLE, BEDROOM}


@export_group("Enemy Details")
@export var enemy_id: ENEMY_IDS = ENEMY_IDS.NOT_SET
@export var sleep_assurance_score: float = -1
@export_group("Jumpscare Details")
@export var jumpscare_sound: AudioStream
@export var jumpscares: Array[SpriteFrames]

var enabled: bool

func _ready() -> void:
	if enemy_id == ENEMY_IDS.NOT_SET:
		print_debug("An Enemy ID has not been set for one of the enemies! Running _deactivate()")
		_deactivate()
		return
	if sleep_assurance_score == -1:
		push_error("Sleep assurance score has not been set for ",ENEMY_IDS.keys()[enemy_id],"!")
	if jumpscare_sound == null:
		push_error("Jumpscare Sound has not yet been set for enemy ",ENEMY_IDS.keys()[enemy_id],"!")
	if jumpscares.is_empty():
		push_error("No jumpscares have been set for ",ENEMY_IDS.keys()[enemy_id],"!")
	# This whole chunk is so that I can detect if all 14 characters are active and enable happyshroom, otherwise disable happyshroom, without affecting Global.ENABLED_IDS.
	var enabled_ids: Array[bool] = Global.ENABLED_IDS.duplicate()
	if false not in enabled_ids:
		enabled_ids.append(true)
	else:
		enabled_ids.append(false)
	enabled = enabled_ids[enemy_id]
	if not enabled:
		_deactivate()

func _deactivate() -> void: 
	self.queue_free()
	
func _jumpscare(area:= JUMPSCARE_AREAS.MIDDLE) -> void:
	SignalBus.jumpscare.emit(self, area)
