extends CanvasLayer

@export var office: AnimatedSprite2D
@export var lamp_button: Button
@export var nose: Button
@export var window_background: AnimatedSprite2D
@export var front_window: AnimatedSprite2D
@export var front_window_overlay: AnimatedSprite2D
@export var front_window_button: Button
@export var dark_overlay: AnimatedSprite2D
@export var sleep_assurance: RichTextLabel
@export var popup: RichTextLabel

@onready var camera: Camera2D = get_viewport().get_camera_2d()

var last_animation_played: String
var office_direction: String
var lock_movement: bool
var flashlight_state: Global.FLASHLIGHT_STATES:
	set(new_value):
		flashlight_state = new_value
		if flashlight_state != Global.FLASHLIGHT_STATES.ON:
			dead_flashlight_sound_check = false
		if flashlight_state == Global.FLASHLIGHT_STATES.DEAD:
			_use_flashlight(Global.FLASHLIGHT_STATES.OFF)
var dead_flashlight_sound_check: bool

const popup_labels: Dictionary = {
	"go_to_sleep":"Press B to go to sleep!",
	"something_got_inside":"Something got inside.\r\nDon't stay in the same room with it for too long!"}

#region AudioStreams
const RUNNING: AudioStream = preload("uid://dn18i7vrgqil8")
const STAIRS_DOWN: AudioStream = preload("uid://douddgjtsblw3")
const STAIRS_UP: AudioStream = preload("uid://c12xjq2e7f4ix")
const CURTAIN_CLOSING: AudioStream = preload("uid://dyiyvq3cj3wg1")
const CURTAIN_OPENING: AudioStream = preload("uid://bh2qhxmm805wf")
const NOSE_HONK: AudioStream = preload("uid://dp2sm6go3v2r4")
const LAMPTOGGLE: AudioStream = preload("uid://bf8j1xugtu8dh")
#endregion

#region WindowArrays
var window_occupants_l: Array[Enemy.ENEMY_IDS]
var window_occupants_f: Array[Enemy.ENEMY_IDS]
var window_occupants_r: Array[Enemy.ENEMY_IDS]
#endregion

func _ready() -> void:
	SignalBus.update_flashlight_state.connect(_update_flashlight_state)

func _process(delta: float) -> void:
	office_direction = office.animation.right(1)
	nose.disabled = (office.animation != "office")
	lamp_button.disabled = (office.animation != "office")
	lamp_button.visible = !lamp_button.disabled
	front_window_button.disabled = (office.animation != "office")
	front_window_button.visible = !front_window_button.disabled
	_camera_lock()
	popup.visible = _popup_visibility()
	
	if office.animation == "office":
		if SaveData.settings_data["game"]["use_old_camera_scrolling"] and int(SaveData.settings_data["game"]["movement_mode"]) % 3 == 0:
			if camera.position.x < 1:
				_move_player("l")
			elif camera.position.x > 399:
				_move_player("r")
	
	if SpecialFunctions.in_range(office.get_local_mouse_position().y,0,SaveData.settings_data["game"]["top_screen_margin"]) and int(SaveData.settings_data["game"]["movement_mode"]) % 3 == 0:
		_move_player("f")
	if SpecialFunctions.in_range(office.get_local_mouse_position().y,720 - SaveData.settings_data["game"]["bottom_screen_margin"],720) and int(SaveData.settings_data["game"]["movement_mode"]) % 3 == 0:
		_move_player("b")
	if SpecialFunctions.in_range(office.get_local_mouse_position().x,0,SaveData.settings_data["game"]["left_screen_margin"]) and int(SaveData.settings_data["game"]["movement_mode"]) % 3 == 0:
		_move_player("l")
	if SpecialFunctions.in_range(office.get_local_mouse_position().x,1680 - SaveData.settings_data["game"]["right_screen_margin"],1680) and int(SaveData.settings_data["game"]["movement_mode"]) % 3 == 0:
		_move_player("r")

	if Input.is_action_pressed("close_curtain"):
		if "open_" in office.animation:
			_use_curtain(true)
	if not Input.is_action_pressed("close_curtain"):
		if "closed_" in office.animation:
			_use_curtain(false)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_action_pressed("move_forward", true) and SaveData.settings_data["game"]["movement_mode"] >= 2:
			_move_player("f")
		if event.is_action_pressed("move_backward", true) and SaveData.settings_data["game"]["movement_mode"] >= 2:
			_move_player("b")
		if event.is_action_pressed("move_left", true) and SaveData.settings_data["game"]["movement_mode"] >= 2:
			_move_player("l")
		if event.is_action_pressed("move_right", true) and SaveData.settings_data["game"]["movement_mode"] >= 2:
			_move_player("r")
			
		if event.is_action_pressed("toggle_lamp"):
			if not lamp_button.disabled:
				lamp_button.button_pressed = !lamp_button.button_pressed
				lamp_button.pressed.emit()
		
		if event.is_action_pressed("go_to_sleep"):
			if office.animation == "open_b" and flashlight_state == Global.FLASHLIGHT_STATES.ON and sleep_assurance.sleep_assurance_normal >= 1:
				SignalBus.go_to_sleep.emit()

		if Input.is_action_pressed("click_front_window"):
			if SpecialFunctions.in_range(office.get_local_mouse_position().x,front_window_button.global_position.x,front_window_button.global_position.x+front_window_button.size.x) and SpecialFunctions.in_range(office.get_local_mouse_position().y,front_window_button.global_position.y,front_window_button.global_position.y+front_window_button.size.y):
				if SaveData.settings_data["game"]["use_old_front_window_hitbox"]:
					_move_player("f")

		if Input.is_action_pressed("click_move"):				
			if SpecialFunctions.in_range(office.get_local_mouse_position().y,0,SaveData.settings_data["game"]["top_screen_margin"]) and int(SaveData.settings_data["game"]["movement_mode"]) % 3 == 1:
				_move_player("f")
			if SpecialFunctions.in_range(office.get_local_mouse_position().y,720 - SaveData.settings_data["game"]["bottom_screen_margin"],720) and int(SaveData.settings_data["game"]["movement_mode"]) % 3 == 1:
				_move_player("b")
			if SpecialFunctions.in_range(office.get_local_mouse_position().x,0,SaveData.settings_data["game"]["left_screen_margin"]) and int(SaveData.settings_data["game"]["movement_mode"]) % 3 == 1:
				_move_player("l")
			if SpecialFunctions.in_range(office.get_local_mouse_position().x,1680 - SaveData.settings_data["game"]["right_screen_margin"],1680) and int(SaveData.settings_data["game"]["movement_mode"]) % 3 == 1:
				_move_player("r")
	
		if Input.is_action_pressed("use_flashlight"):
			_use_flashlight(Global.FLASHLIGHT_STATES.ON, office.get_local_mouse_position())
		if not Input.is_action_pressed("use_flashlight"):
			_use_flashlight(Global.FLASHLIGHT_STATES.OFF, office.get_local_mouse_position())


func _move_player(go_direction: String) -> void:
	if not _can_move():
		return

	if go_direction == "b":
		if office.animation == "office":
			office.play("go_b")
			SpecialFunctions.audio(STAIRS_UP)
		elif office.animation == "open_f":
			office.play("leave_f")
			SpecialFunctions.audio(RUNNING)
		elif office.animation == "open_b":
			office.play("leave_b")
			SpecialFunctions.audio(STAIRS_DOWN)
		elif office.animation == "open_l":
			office.play("leave_l")
			SpecialFunctions.audio(RUNNING)
		elif office.animation == "open_r":
			office.play("leave_r")
			SpecialFunctions.audio(RUNNING)
		
	elif office.animation == "office":
		office.play("go_"+go_direction)
		SpecialFunctions.audio(RUNNING)

	last_animation_played = office.animation

func _update_flashlight_state(new_state: Global.FLASHLIGHT_STATES) -> void:
	flashlight_state = new_state

func _use_flashlight(to_state: Global.FLASHLIGHT_STATES, mouse_pos:= Vector2(0,0)) -> void:
	var dir = office.animation.right(1)
	
	if "open_" not in office.animation:
		return
		
	if to_state == Global.FLASHLIGHT_STATES.OFF:
		SignalBus.flashlight_off.emit()
		if flashlight_state != Global.FLASHLIGHT_STATES.ON:
			office.frame = 0
			front_window_overlay.frame = 0

	elif dead_flashlight_sound_check == false:
		dead_flashlight_sound_check = true
		if dir == "l" or dir == "r":
			SignalBus.flashlight_on.emit()
			if flashlight_state == Global.FLASHLIGHT_STATES.ON:
				office.frame = 1
			
		if dir == "b":
			SignalBus.flashlight_on.emit()
			if flashlight_state == Global.FLASHLIGHT_STATES.ON:
				office.frame = 1
		
		if dir == "f":
			if SpecialFunctions.in_range(mouse_pos.x,60,610) and SpecialFunctions.in_range(mouse_pos.y,150,650):
				SignalBus.flashlight_on.emit()
				if flashlight_state == Global.FLASHLIGHT_STATES.ON:
					office.frame = 1
					front_window.play("l")
					front_window_overlay.play("l")
					front_window_overlay.frame = 1
			elif SpecialFunctions.in_range(mouse_pos.x,611,1680) and SpecialFunctions.in_range(mouse_pos.y,150,650):
				SignalBus.flashlight_on.emit()
				if flashlight_state == Global.FLASHLIGHT_STATES.ON:
					office.frame = 2
					front_window.play("r")
					front_window_overlay.play("r")
					front_window_overlay.frame = 1		
		
	else:
		dead_flashlight_sound_check = false
		
	if _can_go_to_sleep():
		popup.text = popup_labels["go_to_sleep"]
		
func _use_curtain(to_state: bool) -> void:
	var dir = office.animation.right(1)
	if dir != "r" and dir != "l":
		return
	if "open_" not in office.animation and "closed_" not in office.animation:
		return
		
	if not to_state:
		if "closed_" in office.animation:
			office.play("opening_"+dir)
			SpecialFunctions.audio(CURTAIN_OPENING)
			return
		
	if "open_" in office.animation:
		office.play("closing_"+dir)
		SpecialFunctions.audio(CURTAIN_CLOSING)
		if flashlight_state == Global.FLASHLIGHT_STATES.ON:
			SignalBus.flashlight_off.emit()
	
func _on_office_animation_finished(source: AnimatedSprite2D) -> void:
	var dir = last_animation_played.right(1)
	if "leave_" in last_animation_played:
		office.play("return")
	elif last_animation_played == "return":
		office.play("office")
		window_background.play("f")
	elif "go_" in last_animation_played:
		office.play("open_"+dir)
		window_background.play(dir)
		
	front_window.visible = (office.animation == "open_f")
	front_window_overlay.visible = (office.animation == "open_f")
	last_animation_played = office.animation
	
	if "opening_" in last_animation_played:
		office.play("open_"+dir)
	if "closing_" in last_animation_played:
		office.play("closed_"+dir)
				
func _can_move() -> bool:
	if dark_overlay.visible:
		return false
	if "office" not in office.animation and "open_" not in office.animation:
		return false
	if lock_movement:
		return false
	if flashlight_state == Global.FLASHLIGHT_STATES.ON:
		return false
		
	return true

func _camera_lock() -> void:
	if office.animation == "return" or office.animation == "office":
		SignalBus.change_camera_position.emit(-1)
	if "go_" in office.animation:
		if office.animation.right(1) == "l" or office.animation.right(1) == "r":
			if office.frame >= 3:
				SignalBus.change_camera_position.emit(0)
		elif office.animation.right(1) == "f" or office.animation.right(1) == "b":
			if office.frame >= 4:
				SignalBus.change_camera_position.emit(0)

func _on_nose_pressed() -> void:
	SpecialFunctions.audio(NOSE_HONK)

func _on_lamp_button_pressed(source: BaseButton) -> void:
	dark_overlay.visible = source.button_pressed
	SpecialFunctions.audio(LAMPTOGGLE)

func update_window_occupants(id: Enemy.ENEMY_IDS, which_side: Variant, to_do: bool) -> void:
	if which_side is String:
		which_side = {"l":-1,"f":0,"r":1}[which_side]
	elif which_side is not int:
		push_error("Can only get window occupants with an int or String!")
	var occupants_arrays:= [window_occupants_l,window_occupants_f,window_occupants_r]
	match to_do:
		false:
			occupants_arrays[which_side+1].erase(id)
		true:
			occupants_arrays[which_side+1].append(id)

func get_window_occupants(which_side: Variant) -> Array:
	if which_side is String:
		which_side = {"l":-1,"f":0,"r":1}[which_side]
	elif which_side is not int:
		push_error("Can only get window occupants with an int or String!")
	return [window_occupants_l,window_occupants_f,window_occupants_r][which_side+1]

func _can_go_to_sleep() -> bool:
	if sleep_assurance.sleep_assurance_normal < 1:
		return false
	if office.animation != "open_b":
		return false
	if flashlight_state == Global.FLASHLIGHT_STATES.OFF:
		return false
	return true
		
func _popup_visibility() -> bool:
	if popup.text == popup_labels["go_to_sleep"]:
		return _can_go_to_sleep()

	return false
