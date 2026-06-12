extends Node
class_name Enemy

enum IDS {
	NONE,
	CHIPOMAT_1,
	CHIPOMAT_2,
	CHIPOMAT_3,
	FUN_FUNGAL,
	SPRINGCRAB,
	NIGHTMARE_CHIPPER,
	HAPPYSHROOM,
	FREDBEAR,
	BUSTER,
	BIDY,
	CHIPPER,
	BRUCE,
	TOY,
	SEABILL,
	PHANTOM_CHIPOMAT }

@export var enemy_id: IDS
@export var enabled: bool = false
@export var jumpscare_sound: AudioStream
@export var jumpscare_middle_uid: String
@export var jumpscare_bedroom_uid: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(enemy_id != 0, "An Enemy ID has not been set for one of the enemies!")
	if jumpscare_sound == null:
		push_error("Jumpscare Sound has not yet been set for enemy ",enemy_id,"!")
	if jumpscare_middle_uid == "" and jumpscare_bedroom_uid == "":
		push_error("No Jumpscare UIDs have been set for ",enemy_id,"!")
		
	var temp_id: int = enemy_id
	if temp_id >= 1 and temp_id <= 3: # chipomats 1-3 = the_chipomats
		temp_id = 1
	elif temp_id >= 4 and temp_id <= 7: # fun_fungal through happyshroom
		temp_id -= 2
	elif temp_id >= 8 and temp_id <= 10:
		temp_id = 6
	elif temp_id >= 11 and temp_id <= 12:
		temp_id = 7
	elif temp_id >= 13 and temp_id <= 15:
		temp_id -= 5
	if temp_id in Global.ENABLED_IDS:
		enabled = Global.ENABLED_IDS[temp_id]
	


func jumpscare(area:= "middle") -> void:
	SignalBus.jumpscare.emit(self, area)
