@tool
class_name Preset extends Resource

@export_group("Preset Details")
@export var preset_name: String:
	set(value):
		preset_name = value
		resource_name = value
@export_range(1,32,1,"prefer_slider") var sleep_assurance_points: int
@export var enabled_ids: Dictionary[Enemy.ENEMY_IDS,bool] = {
	Enemy.ENEMY_IDS.CHIPOMAT_1:false,
	Enemy.ENEMY_IDS.CHIPOMAT_2:false,
	Enemy.ENEMY_IDS.CHIPOMAT_3:false,
	Enemy.ENEMY_IDS.FUN_FUNGAL:false,
	Enemy.ENEMY_IDS.SPRINGCRAB:false,
	Enemy.ENEMY_IDS.NIGHTMARE_CHIPPER:false,
	Enemy.ENEMY_IDS.SEABILL:false,
	Enemy.ENEMY_IDS.FREDBEAR:false,
	Enemy.ENEMY_IDS.BIDY:false,
	Enemy.ENEMY_IDS.BUSTER:false,
	Enemy.ENEMY_IDS.BRUCE:false,
	Enemy.ENEMY_IDS.CHIPPER:false,
	Enemy.ENEMY_IDS.TOY:false,
	Enemy.ENEMY_IDS.PHANTOM_CHIPOMAT:false}
