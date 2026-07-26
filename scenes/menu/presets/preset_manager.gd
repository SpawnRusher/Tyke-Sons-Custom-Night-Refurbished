extends Panel

const BUTTON_PRESS_LOUD: AudioStream = preload("uid://dljncvmipnl1d")

@export_group("Nodes")
@export var enemy_portrait_grid: GridContainer
@export var sleep_assurance_grid: GridContainer
@export var text: RichTextLabel
@export var left_button: TextureButton
@export var right_button: TextureButton
@export_group("Presets")
@export var presets: Array[Preset]

@onready var enemy_portrait_list: Array[Node] = enemy_portrait_grid.get_children()
@onready var sleep_assurance_list: Array[Node] = sleep_assurance_grid.get_children()

var current_preset: int = -1
var preset_match: bool

var hovering_sleep_assurance: bool

func _ready() -> void:
	_update_enemy_portraits(Global.ENABLED_IDS)
	_update_sleep_assurance_points(Global.sleep_assurance_points)
	SignalBus.enemy_portrait_toggled.connect(_enemy_portrait_toggled)
	
func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and hovering_sleep_assurance:
		var mouse_pos = sleep_assurance_grid.get_local_mouse_position()
		Global.sleep_assurance_points = max(1,1 + (mouse_pos.x/32 as int)) + (16 * ((mouse_pos.y > (sleep_assurance_grid.size.y/2)) as int))
		_update_sleep_assurance_points(Global.sleep_assurance_points)

func _on_preset_button_left_pressed() -> void:
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD)
	_set_preset(current_preset - 1)
		
func _on_preset_button_right_pressed() -> void:
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD)
	_set_preset(current_preset + 1)

func _set_preset(index: int) -> void:
	if index >= presets.size():
		index = 0
	if index < 0:
		index = presets.size() - 1
	current_preset = index
	Global.sleep_assurance_points = presets[current_preset].sleep_assurance_points
	_update_enemy_portraits(presets[current_preset].enabled_ids)
	_update_sleep_assurance_points(presets[current_preset].sleep_assurance_points)

func _update_enemy_portraits(id_array: Dictionary[Enemy.ENEMY_IDS,bool]) -> void:
	for i in id_array.size():
		enemy_portrait_list[i].toggle(id_array[i],true)
	_preset_match()
		
func _update_sleep_assurance_points(points: int) -> void:
	for i in sleep_assurance_list.size():
		if i < points:
			sleep_assurance_list[i].value = 1
		if i >= points:
			sleep_assurance_list[i].value = 0
	_preset_match()
		
func _enemy_portrait_toggled(enemy_portrait: Enemy_Portrait) -> void:
	Global.ENABLED_IDS[enemy_portrait.enemy_id] = enemy_portrait.enabled
	_preset_match()

func _preset_match() -> void:
	preset_match = false
	if presets[current_preset].enabled_ids == Global.ENABLED_IDS and presets[current_preset].sleep_assurance_points == Global.sleep_assurance_points:
		preset_match = true
		
	else:
		for i in presets.size():
			if presets[i].enabled_ids == Global.ENABLED_IDS:
				current_preset = i
	
	text.text = "Custom Night" if preset_match == false else presets[current_preset].preset_name
	Global.current_preset_name = text.text

func _on_sleep_assurance_grid_mouse_entered() -> void:
	hovering_sleep_assurance = true

func _on_sleep_assurance_grid_mouse_exited() -> void:
	hovering_sleep_assurance = false
