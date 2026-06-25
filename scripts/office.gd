extends CanvasLayer

@export var office: AnimatedSprite2D
@export var lamp_button: Button
@export var window_background: AnimatedSprite2D
@export var front_window: AnimatedSprite2D
@export var dark_overlay: AnimatedSprite2D

@onready var camera: Camera2D = get_viewport().get_camera_2d()

var last_animation_played: String
var animation_direction: String
var lock_movement: bool
var using_flashlight: bool

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

#region WindowArrays
var front_window_occupants: Array[Enemy]
var left_window_occupants: Array[Enemy]
var right_window_occupants: Array[Enemy]
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	office.animation_changed.connect(_update_last_animation_played)
	office.animation_finished.connect(_animation_finished)
	SignalBus.update_flashlight_state.connect(update_flashlight_state)
	SignalBus.broadcast_sleep_assurance_score.connect(_update_sleep_assurance_score)
	SignalBus.start_happyshroom_fight.connect(_start_happyshroom_fight)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	lamp_button.disabled = false
	if office.animation != "office":
		lamp_button.disabled = true
	lamp_button.visible = !lamp_button.disabled
	
	front_window.visible = false
			
	if "closed" in office.animation:
		if not Input.is_action_pressed("close_curtain"):
			office.play("opening_"+animation_direction)
			SpecialFunctions.audio(CURTAIN_OPENING)
			
	if "open_" in office.animation: # underscore in name is necessary here to distinct "open_dir" from "opening_dir"
		
		if animation_direction == "r" or animation_direction == "l":
			if Input.is_action_pressed("use_flashlight"):
				SignalBus.flashlight_on.emit()
				if using_flashlight == true:
					office.frame = 1
			if not Input.is_action_pressed("use_flashlight"):
				SignalBus.flashlight_off.emit()
				if using_flashlight == false:
					office.frame = 0

			if Input.is_action_pressed("close_curtain"):
				office.play("closing_"+animation_direction)
				SpecialFunctions.audio(CURTAIN_CLOSING)
				if using_flashlight == true:
					SignalBus.flashlight_off.emit()
				
		if animation_direction == "f":
			if Input.is_action_pressed("use_flashlight"):
				if using_flashlight == false:
					if SpecialFunctions.in_range(office.get_local_mouse_position().x,60,610):
						if SpecialFunctions.in_range(office.get_local_mouse_position().y,150,650):
							SignalBus.flashlight_on.emit()
							if using_flashlight == true:
								office.frame = 1
					if SpecialFunctions.in_range(office.get_local_mouse_position().x,611,1680):
						if SpecialFunctions.in_range(office.get_local_mouse_position().y,150,650):
							SignalBus.flashlight_on.emit()
							if using_flashlight == true:
								office.frame = 2
			if not Input.is_action_pressed("use_flashlight"):
				if using_flashlight == true:
					SignalBus.flashlight_off.emit()
					if using_flashlight == false:
						office.frame = 0
					
			if office.frame == 1:
				front_window.play("l")
				front_window.visible = true
			if office.frame == 2:
				front_window.play("r")
				front_window.visible = true
								
		if animation_direction == "b":
			if Input.is_action_pressed("use_flashlight"):
				SignalBus.flashlight_on.emit()
				if using_flashlight == true:
					office.frame = 1
			if not Input.is_action_pressed("use_flashlight"):
				SignalBus.flashlight_off.emit()
				if using_flashlight == false:
					office.frame = 0
	
func _input(event: InputEvent) -> void:
	turn_checks(event)
	if office.animation == "open_b" and office.frame == 1:
		if event is InputEventKey and event.keycode == KEY_B:
			if sleep_assurance_current_score >= 1:
				SignalBus.go_to_sleep.emit()
				
func can_move() -> bool:
	if lock_movement == true:
		return false
	if lamp_button.button_pressed == true:
		return false
	if "turn" in office.animation:
		return false
	if "go" in office.animation:
		return false
	if "opening" in office.animation:
		return false
	if "closing" in office.animation:
		return false
	if "closed" in office.animation:
		return false
	if "leaving" in office.animation:
		return false
	if "return" in office.animation:
		return false
		
	return true

func _animation_finished() -> void:
	if last_animation_played == "return":
		office.play("office")
		window_background.play("f")
		window_background.visible = true
		
	elif "turn" in last_animation_played:
		camera.lockpos = 0
		office.play("go_"+animation_direction)
		
	elif "go" in last_animation_played:
		office.play("open_"+animation_direction)
		window_background.visible = true
		if animation_direction == "l" or animation_direction == "r":
			window_background.play(animation_direction)
		
	elif "leave" in last_animation_played:
		camera.lockpos = -1
		office.play("return")
		
	elif "opening" in last_animation_played:
		office.play("open_"+animation_direction)

	
	elif "closing" in last_animation_played:
		office.play("closed_"+animation_direction)
		
func turn_checks(event: InputEvent) -> void:
	if can_move() == true:
		if office.animation == "office":
			if SpecialFunctions.in_range(office.get_local_mouse_position().x,0,100) or (event.is_action_pressed("move_left", true) and SaveData.settings_data["quality_of_life"]["enable_moving_with_keyboard"] == true):
				office.play("turn_l")
				SpecialFunctions.audio(RUNNING)

			if SpecialFunctions.in_range(office.get_local_mouse_position().x,1580,1680) or (event.is_action_pressed("move_right", true) and SaveData.settings_data["quality_of_life"]["enable_moving_with_keyboard"] == true):
				office.play("turn_r")
				SpecialFunctions.audio(RUNNING)

			if SpecialFunctions.in_range(office.get_local_mouse_position().y,0,100) or (event.is_action_pressed("move_forward", true) and SaveData.settings_data["quality_of_life"]["enable_moving_with_keyboard"] == true):
				office.play("turn_f")
				SpecialFunctions.audio(RUNNING)

			if SpecialFunctions.in_range(office.get_local_mouse_position().y,620,720) or (event.is_action_pressed("move_backward", true) and SaveData.settings_data["quality_of_life"]["enable_moving_with_keyboard"] == true):
				office.play("turn_b")
				SpecialFunctions.audio(STAIRS_UP)
			
		if "open_" in office.animation:
			if SpecialFunctions.in_range(office.get_local_mouse_position().y,620,720) or (event.is_action_pressed("move_backward", true) and SaveData.settings_data["quality_of_life"]["enable_moving_with_keyboard"] == true):
				office.play("leave_"+animation_direction)
				window_background.visible = false
				if animation_direction == "b": 
					SpecialFunctions.audio(STAIRS_DOWN)
				else: 
					SpecialFunctions.audio(RUNNING)
				return
			
		if office.animation != "office" and office.animation != "return": # sets animation_direction only if there is a direction
			animation_direction = office.animation.right(1)
			
	
func _update_last_animation_played() -> void:
	last_animation_played = office.animation
	
func update_flashlight_state(flashlight_state: bool) -> void:
	using_flashlight = flashlight_state
	
func _update_sleep_assurance_score(score) -> void:
	sleep_assurance_current_score = score
	
func _start_happyshroom_fight() -> void:
	happyshroom_fight_active = true

func _on_nose_pressed() -> void:
	SpecialFunctions.audio(NOSE_HONK)

func _on_lamp_button_pressed(source: BaseButton) -> void:
	SpecialFunctions.audio(LAMPTOGGLE)
	dark_overlay.visible = source.button_pressed
