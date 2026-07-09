extends Panel

const LOUD_BUTTON_PRESS: AudioStream = preload("uid://dljncvmipnl1d")

@export_group("Nodes")
@export var presets: Node
@export var enemy_portrait_grid: GridContainer
@export var text: RichTextLabel
@export var left_button: TextureButton
@export var right_button: TextureButton

@onready var preset_list: Array[Node] = presets.get_children()
@onready var enemy_portrait_list: Array[Node] = enemy_portrait_grid.get_children()

var current_preset: int = -1
var preset_match: bool

func _ready() -> void:
	_update_enemy_portraits(Global.ENABLED_IDS)
	SignalBus.enemy_portrait_toggled.connect(_enemy_portrait_toggled)

func _on_preset_button_left_pressed() -> void:
	SpecialFunctions.audio(LOUD_BUTTON_PRESS)
	_set_preset(current_preset - 1)
		
func _on_preset_button_right_pressed() -> void:
	SpecialFunctions.audio(LOUD_BUTTON_PRESS)
	_set_preset(current_preset + 1)

func _set_preset(index: int) -> void:
	if index >= preset_list.size():
		index = 0
	if index < 0:
		index = preset_list.size() - 1
	current_preset = index
	_update_enemy_portraits(preset_list[current_preset].enabled_ids)

func _update_enemy_portraits(id_array: Array[bool]) -> void:
	for i in id_array.size():
		enemy_portrait_list[i].toggle(id_array[i],true)
	_preset_match()
		
func _enemy_portrait_toggled(enemy_portrait: Enemy_Portrait) -> void:
	Global.ENABLED_IDS[enemy_portrait.enemy_id] = enemy_portrait.enabled
	_preset_match()

func _preset_match() -> void:
	preset_match = false
	if preset_list[current_preset].enabled_ids == Global.ENABLED_IDS:
		preset_match = true
		
	else:
		for i in preset_list.size():
			if preset_list[i].enabled_ids == Global.ENABLED_IDS:
				_set_preset(i)
	
	if preset_match == false:
		text.text = "Custom Night"
	else:
		text.text = preset_list[current_preset].name.capitalize()
