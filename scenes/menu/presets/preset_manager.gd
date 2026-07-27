extends Panel

const BUTTON_PRESS_QUIET: AudioStream = preload("uid://dubq1cwtm73fs")
const BUTTON_PRESS_LOUD: AudioStream = preload("uid://dljncvmipnl1d")

@export_group("Nodes")
@export var enemy_portrait_grid: GridContainer
@export var sleep_assurance_grid: GridContainer
@export var preset_label: RichTextLabel
@export var left_button: TextureButton
@export var right_button: TextureButton
@export_group("Presets")
@export var presets: Array[Preset]


@onready var enemy_portrait_list: Array[Node] = enemy_portrait_grid.get_children()
@onready var sleep_assurance_list: Array[Node] = sleep_assurance_grid.get_children()

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
	Enemy.ENEMY_IDS.PHANTOM_CHIPOMAT:false}:
		set(value):
			enabled_ids = value
			GameInfo.enabled_ids = value.duplicate()
			_toggle_enemy_portraits()
var hovering_sleep_assurance: bool
var current_preset: int:
	set(value):
		if value == -2: # view preset_match's comment
			current_preset = 0
			preset_label.text = presets[current_preset].preset_name
			GameInfo.current_preset_index = current_preset
			GameInfo.current_preset_name = preset_label.text
			return
		current_preset = wrapi(value,0,presets.size())
		preset_label.text = presets[current_preset].preset_name
		GameInfo.current_preset_index = current_preset
		GameInfo.current_preset_name = preset_label.text
		enabled_ids = presets[current_preset].enabled_ids.duplicate()
		sleep_assurance_points = presets[current_preset].sleep_assurance_points
		preset_match = true
var preset_match: bool:
	set(value):
		preset_match = value
		if not preset_match:
			current_preset = -2 # this is needed to differentiate between using arrows to select Custom Night vs. preset_match making the preset Custom Night
var sleep_assurance_points: int = 1:
	set(value):
		sleep_assurance_points = max(1,value)
		GameInfo.sleep_assurance_points = sleep_assurance_points
		_update_sleep_assurance()
		
func _ready() -> void:
	for enemy_portrait in enemy_portrait_list:
		enemy_portrait.enemy_portrait_toggled.connect(_enemy_portrait_toggled)
	enabled_ids = GameInfo.enabled_ids.duplicate()
	current_preset = GameInfo.current_preset_index
	preset_label.text = GameInfo.current_preset_name
	
func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and hovering_sleep_assurance:
		var mouse_pos = sleep_assurance_grid.get_local_mouse_position()
		if sleep_assurance_points != max(1,1 + (mouse_pos.x/32 as int)) + (16 * ((mouse_pos.y > (sleep_assurance_grid.size.y/2)) as int)):
			sleep_assurance_points = max(1,1 + (mouse_pos.x/32 as int)) + (16 * ((mouse_pos.y > (sleep_assurance_grid.size.y/2)) as int))
			SpecialFunctions.create_audio(BUTTON_PRESS_QUIET)
			_check_preset_match()
	
func _update_sleep_assurance() -> void:
	for sleep_assurance_point in sleep_assurance_list:
		sleep_assurance_point.value = int(sleep_assurance_list.find(sleep_assurance_point) < sleep_assurance_points)
		
func _on_preset_button_left_pressed() -> void:
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD)
	current_preset -= 1

func _on_preset_button_right_pressed() -> void:
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD)
	current_preset += 1

func _check_preset_match() -> void:
	for preset in presets:
		if sleep_assurance_points == preset.sleep_assurance_points:
			if enabled_ids == preset.enabled_ids:
				if current_preset != presets.find(preset):
					current_preset = presets.find(preset)
	if sleep_assurance_points != presets[current_preset].sleep_assurance_points:
		preset_match = false
		return
	if enabled_ids != presets[current_preset].enabled_ids:
		preset_match = false
		return
	preset_match = true

func _enemy_portrait_toggled(enemy_portrait: Enemy_Portrait) -> void:
	enabled_ids[enemy_portrait.enemy_id] = enemy_portrait.enabled
	_check_preset_match()

func _toggle_enemy_portraits() -> void:
	for enemy_portrait in enemy_portrait_list:
		enemy_portrait.enabled = enabled_ids[enemy_portrait.enemy_id]

func _on_sleep_assurance_grid_mouse_entered() -> void:
	hovering_sleep_assurance = true

func _on_sleep_assurance_grid_mouse_exited() -> void:
	hovering_sleep_assurance = false
