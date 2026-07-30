extends Node

#region NIGHT INFO
var enabled_ids: Dictionary[Enemy.ENEMY_IDS,bool] = {
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
var current_preset: int
var current_preset_name: String
var sleep_assurance_points: int
#endregion
var survival_mode_enabled: bool
var win_sleep_assurance: float
var win_time: int
var dead_enemy_id: Enemy.ENEMY_IDS = -1
var dead_sleep_assurance: float
var dead_time: int
enum FLASHLIGHT_STATES {DEAD=-1, OFF, ON}


var happyshroom_test_mode: bool
var show_debug_info: bool
