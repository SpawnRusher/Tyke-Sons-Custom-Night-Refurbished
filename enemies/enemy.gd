extends Node
class_name Enemy

enum ENEMY_IDS {NONE, CHIPOMAT_1, CHIPOMAT_2, CHIPOMAT_3, FUN_FUNGAL, SPRINGCRAB, NIGHTMARE_CHIPPER, SEABILL,
				FREDBEAR, BIDY, BUSTER, BRUCE, CHIPPER, TOY, PHANTOM_CHIPOMAT, HAPPYSHROOM}
	
enum JUMPSCARE_AREAS {MIDDLE, BEDROOM}

@export_group("Enemy Details")
@export var enemy_id: ENEMY_IDS
@export var enabled: bool = false
@export_group("Jumpscares")
@export var jumpscare_sound: AudioStream
@export var jumpscare_middle_uid: String
@export var jumpscare_bedroom_uid: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(enemy_id > ENEMY_IDS.NONE, "An Enemy ID has not been set for one of the enemies!")
	if jumpscare_sound == null:
		push_error("Jumpscare Sound has not yet been set for enemy ",enemy_id,"!")
	if jumpscare_middle_uid == "" and jumpscare_bedroom_uid == "":
		push_error("No Jumpscare UIDs have been set for ",enemy_id,"!")
	
	enabled = Global.ENABLED_IDS[enemy_id]
	
func jumpscare(area:= JUMPSCARE_AREAS.MIDDLE) -> void:
	SignalBus.jumpscare.emit(self, area)
