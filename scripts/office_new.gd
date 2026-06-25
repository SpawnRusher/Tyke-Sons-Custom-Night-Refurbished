extends CanvasLayer

@export var office: AnimatedSprite2D
@export var lamp_button: Button
@export var nose: Button
@export var window_background: AnimatedSprite2D
@export var front_window: AnimatedSprite2D
@export var dark_overlay: AnimatedSprite2D
@export var sleep_assurance: RichTextLabel

@onready var camera: Camera2D = get_viewport().get_camera_2d()

var last_animation_played: String
var office_direction: String
var lock_movement: bool
var flashlight_state: bool

var sleep_assurance_current_score: float
var happyshroom_fight_active: bool

#region AudioStreams
const RUNNING: AudioStream = preload("uid://dn18i7vrgqil8")
const STAIRS_DOWN: AudioStream = preload("uid://douddgjtsblw3")
const STAIRS_UP: AudioStream = preload("uid://c12xjq2e7f4ix")
const CURTAIN_CLOSING: AudioStream = preload("uid://dyiyvq3cj3wg1")
const CURTAIN_OPENING: AudioStream = preload("uid://bh2qhxmm805wf")
const NOSE_HONK: AudioStream = preload("uid://dp2sm6go3v2r4")
const LAMPTOGGLE: AudioStream = preload("uid://bf8j1xugtu8dh")
#endregion

func _ready() -> void:
	SignalBus.update_flashlight_state.connect(_update_flashlight_state)

func _process(delta: float) -> void:
	nose.disabled = (office.animation != "office")
	lamp_button.disabled = (office.animation != "office")
	lamp_button.visible = !lamp_button.disabled
	_camera_lock()
	
	if SpecialFunctions.in_range(office.get_local_mouse_position().y,0,100) and SaveData.settings_data["game"]["movement_mode"] != 1:
		_move_player("f")
	if SpecialFunctions.in_range(office.get_local_mouse_position().y,620,720) and SaveData.settings_data["game"]["movement_mode"] != 1:
		_move_player("b")
	if SpecialFunctions.in_range(office.get_local_mouse_position().x,0,100) and SaveData.settings_data["game"]["movement_mode"] != 1:
		_move_player("l")
	if SpecialFunctions.in_range(office.get_local_mouse_position().x,1580,1680) and SaveData.settings_data["game"]["movement_mode"] != 1:
		_move_player("r")

	if Input.is_action_pressed("close_curtain"):
		if "open_" in office.animation:
			_use_curtain(true)
	if not Input.is_action_pressed("close_curtain"):
		if "closed_" in office.animation:
			_use_curtain(false)
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("move_forward", true) and SaveData.settings_data["game"]["movement_mode"] > 0:
		_move_player("f")
	if event.is_action_pressed("move_backward", true) and SaveData.settings_data["game"]["movement_mode"] > 0:
		_move_player("b")
	if event.is_action_pressed("move_left", true) and SaveData.settings_data["game"]["movement_mode"] > 0:
		_move_player("l")
	if event.is_action_pressed("move_right", true) and SaveData.settings_data["game"]["movement_mode"] > 0:
		_move_player("r")
	
	if event.is_action_pressed("use_flashlight"):
		_use_flashlight(true, office.get_local_mouse_position())
	if event.is_action_released("use_flashlight"):
		_use_flashlight(false, office.get_local_mouse_position())
		
	if event.is_action_pressed("toggle_lamp"):
		if not lamp_button.disabled:
			lamp_button.button_pressed = !lamp_button.button_pressed
			lamp_button.pressed.emit()
		
	if event.is_action_pressed("go_to_sleep"):
		if office.animation == "open_b" and office.frame == 1:
			if sleep_assurance.sleep_assurance_normal >= 1:
				SignalBus.go_to_sleep.emit()


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

func _update_flashlight_state(from_state) -> void:
	flashlight_state = from_state

func _use_flashlight(to_state: bool, mouse_pos: Vector2) -> void:
	var dir = office.animation.right(1)
	
	if "open_" not in office.animation:
		return
	
	if to_state == false:
		SignalBus.flashlight_off.emit()
		if flashlight_state == false:
			office.frame = 0
			return

	if dir == "l" or dir == "r" or dir == "b":
		SignalBus.flashlight_on.emit()
		if flashlight_state == true:
			office.frame = 1
	
	if dir == "f":
		if SpecialFunctions.in_range(mouse_pos.x,60,610) and SpecialFunctions.in_range(mouse_pos.y,150,650):
			SignalBus.flashlight_on.emit()
			if flashlight_state == true:
				office.frame = 1
				front_window.play("l")
		if SpecialFunctions.in_range(mouse_pos.x,611,1680) and SpecialFunctions.in_range(mouse_pos.y,150,650):
			SignalBus.flashlight_on.emit()
			if flashlight_state == true:
				office.frame = 2
				front_window.play("r")
		
func _use_curtain(to_state: bool) -> void:
	var dir = office.animation.right(1)
	if dir != "r" and dir != "l":
		return
	if "open_" not in office.animation and "closed_" not in office.animation:
		return
		
	if to_state == false:
		if "closed_" in office.animation:
			office.play("opening_"+dir)
			SpecialFunctions.audio(CURTAIN_OPENING)
			return
		
	if "open_" in office.animation:
		office.play("closing_"+dir)
		SpecialFunctions.audio(CURTAIN_CLOSING)
	

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
	last_animation_played = office.animation
	
	if "opening_" in last_animation_played:
		office.play("open_"+dir)
	if "closing_" in last_animation_played:
		office.play("closed_"+dir)
		

				
func _can_move() -> bool:
	if dark_overlay.visible == true:
		return false
	if "office" not in office.animation and "open_" not in office.animation:
		return false
	if lock_movement == true:
		return false
	if office.frame != 0:
		return false
		
	return true

func _camera_lock() -> void:
	if office.animation == "return" or office.animation == "office":
		camera.lockpos = -1
	if "go_" in office.animation:
		if office.animation.right(1) == "l" or office.animation.right(1) == "r":
			if office.frame >= 3:
				camera.lockpos = 0
		elif office.animation.right(1) == "f" or office.animation.right(1) == "b":
			if office.frame >= 4:
				camera.lockpos = 0

func _on_nose_pressed() -> void:
	SpecialFunctions.audio(NOSE_HONK)

func _on_lamp_button_pressed(source: BaseButton) -> void:
	dark_overlay.visible = source.button_pressed
	SpecialFunctions.audio(LAMPTOGGLE)
