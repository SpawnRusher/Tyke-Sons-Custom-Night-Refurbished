extends Panel

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

var hovering_sleep_assurance: bool
var current_preset: int:
	set(value):
		if value == -2: # has to be done this way to not make enemy selection and sleep assurance reset when preset_match fails
			GameInfo.current_preset_index = 0
			GameInfo.current_preset_name = "Custom Night"
			preset_label.text = "Custom Night"
			current_preset = 0
			return
		current_preset = wrapi(value,0,presets.size())
		GameInfo.current_preset_index = current_preset
		GameInfo.current_preset_name = presets[current_preset].preset_name
		GameInfo.ENABLED_IDS = presets[current_preset].enabled_ids
		preset_label.text = presets[GameInfo.current_preset_index].preset_name
		sleep_assurance_points = presets[current_preset].sleep_assurance_points
		_toggle_enemy_portraits()
		preset_match = true
var preset_match: bool:
	set(value):
		preset_match = value
		if preset_match == false:
			current_preset = -2 # has to be done this way to not make enemy selection and sleep assurance reset when preset_match fails
var sleep_assurance_points: int:
	set(value):
		sleep_assurance_points = value
		GameInfo.sleep_assurance_points = value
		_update_sleep_assurance_points_visual()

func _ready() -> void:
	for enemy_portrait in enemy_portrait_list:
		enemy_portrait.enemy_portrait_toggled.connect(_preset_match.unbind(1))
	_update_sleep_assurance_points_visual()
	
func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and hovering_sleep_assurance:
		var mouse_pos = sleep_assurance_grid.get_local_mouse_position()
		sleep_assurance_points = max(1,1 + (mouse_pos.x/32 as int)) + (16 * ((mouse_pos.y > (sleep_assurance_grid.size.y/2)) as int))
		_update_sleep_assurance_points_visual()

func _on_preset_button_left_pressed() -> void:
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD)
	current_preset -= 1

func _on_preset_button_right_pressed() -> void:
	SpecialFunctions.create_audio(BUTTON_PRESS_LOUD)
	current_preset += 1

func _preset_match() -> void:
	if sleep_assurance_points != presets[current_preset].sleep_assurance_points:
		preset_match = false
		return
	for enemy_portrait in enemy_portrait_list:
		if enemy_portrait.enabled != presets[current_preset].enabled_ids[enemy_portrait_list.find(enemy_portrait)]:
			preset_match = false
			return
	preset_match = true

func _update_sleep_assurance_points_visual() -> void:
	for sleep_assurance_point in sleep_assurance_list:
		sleep_assurance_point.value = 0
		if sleep_assurance_list.find(sleep_assurance_point) < GameInfo.sleep_assurance_points:
			sleep_assurance_point.value = 1

func _toggle_enemy_portraits() -> void:
	for enemy_portrait in enemy_portrait_list:
		enemy_portrait.toggle(GameInfo.ENABLED_IDS[enemy_portrait_list.find(enemy_portrait)],true)

func _on_sleep_assurance_grid_mouse_entered() -> void:
	hovering_sleep_assurance = true

func _on_sleep_assurance_grid_mouse_exited() -> void:
	hovering_sleep_assurance = false
