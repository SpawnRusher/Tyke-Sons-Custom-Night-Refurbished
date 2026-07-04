extends Node
class_name Enemy

enum ENEMY_IDS {NONE, CHIPOMAT_1, CHIPOMAT_2, CHIPOMAT_3, FUN_FUNGAL, SPRINGCRAB, NIGHTMARE_CHIPPER, SEABILL, FREDBEAR, BIDY, BUSTER, BRUCE, CHIPPER, TOY, PHANTOM_CHIPOMAT, HAPPYSHROOM}
	
enum JUMPSCARE_AREAS {DEFAULT, MIDDLE, BEDROOM}

@export_group("Enemy Details")
@export var enemy_id: ENEMY_IDS
@export var enabled: bool = false
@export var sleep_assurance_score: float = -1
@export_group("Jumpscares")
@export var jumpscare_sound: AudioStream # The enemy's jumpscare audio file.
@export var jumpscare_uids: Dictionary[JUMPSCARE_AREAS,String] # A dictionary of UIDs for the enemy's jumpscare SpriteFrames resources. An Enemy.JUMPSCARE_AREAS.DEFAULT UID can be specified as a safety fallback. If unspecified, Enemy.JUMPSCARE_AREAS.MIDDLE will be used.

func _ready() -> void:
	assert(enemy_id > ENEMY_IDS.NONE, "An Enemy ID has not been set for one of the enemies!")
	if sleep_assurance_score == -1:
		push_error("Sleep assurance score has not been set for ",ENEMY_IDS.keys()[enemy_id],"!")
	if jumpscare_sound == null:
		push_error("Jumpscare Sound has not yet been set for enemy ",ENEMY_IDS.keys()[enemy_id],"!")
	if jumpscare_uids.is_empty():
		push_error("No jumpscare UIDs have been set for ",ENEMY_IDS.keys()[enemy_id],"!")
	enabled = Global.ENABLED_IDS[enemy_id]
	if not enabled:
		_deactivate()


func _deactivate() -> void: 
	self.queue_free()
	
func _jumpscare(area:= JUMPSCARE_AREAS.DEFAULT) -> void:
	SignalBus.jumpscare.emit(self, area)
