extends Node
class_name Preset

@export_group("Enemy Toggles")
@export var chipomat_1: bool
@export var chipomat_2: bool
@export var chipomat_3: bool
@export var fun_fungal: bool
@export var springcrab: bool
@export var nightmare_chipper: bool
@export var seabill: bool
@export var fredbear: bool
@export var bidy: bool
@export var buster: bool
@export var bruce: bool
@export var chipper: bool
@export var toy: bool
@export var phantom_chipomat: bool
@export_group("Sleep Assurance")
@export var points: int


var enabled_ids: Array[bool]

func _ready() -> void:
	enabled_ids.resize(14)
	enabled_ids[0] = chipomat_1
	enabled_ids[1] = chipomat_2
	enabled_ids[2] = chipomat_3
	enabled_ids[3] = fun_fungal
	enabled_ids[4] = springcrab
	enabled_ids[5] = nightmare_chipper
	enabled_ids[6] = seabill
	enabled_ids[7] = fredbear
	enabled_ids[8] = bidy
	enabled_ids[9] = buster
	enabled_ids[10] = bruce
	enabled_ids[11] = chipper
	enabled_ids[12] = toy
	enabled_ids[13] = phantom_chipomat
	
			
	
