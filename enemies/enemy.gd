extends Node
class_name Enemy

enum ENEMY_IDS {
	NONE,
	CHIPOMAT_1,
	CHIPOMAT_2,
	CHIPOMAT_3,
	FUN_FUNGAL,
	SPRINGCRAB,
	NIGHTMARE_CHIPPER,
	FREDBEAR,
	BUSTER,
	BIDY,
	CHIPPER,
	BRUCE,
	TOY,
	SEABILL,
	PHANTOM_CHIPOMAT }
	
enum PORTRAIT_IDS {
	NONE,
	THE_CHIPOMATS,
	FUN_FUNGAL,
	SPRINGCRAB,
	NIGHTMARE_CHIPPER,
	THE_ROCKSTARS,
	THE_LUMBERERS,
	TOY,
	SEABILL,
	PHANTOM_CHIPOMAT }

@export var enemy_id: ENEMY_IDS
@export var portrait_id: PORTRAIT_IDS
@export var enabled: bool = false
@export var jumpscare_sound: AudioStream
@export var jumpscare_middle_uid: String
@export var jumpscare_bedroom_uid: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(enemy_id != 0, "An Enemy ID has not been set for one of the enemies!")
	assert(portrait_id != 0, "A Portrait ID has not been set for one of the enemies!")
	if jumpscare_sound == null:
		push_error("Jumpscare Sound has not yet been set for enemy ",enemy_id,"!")
	if jumpscare_middle_uid == "" and jumpscare_bedroom_uid == "":
		push_error("No Jumpscare UIDs have been set for ",enemy_id,"!")
	
	if portrait_id in Global.ENABLED_IDS:
		enabled = Global.ENABLED_IDS[portrait_id]
	


func jumpscare(area:= "middle") -> void:
	SignalBus.jumpscare.emit(self, area)
