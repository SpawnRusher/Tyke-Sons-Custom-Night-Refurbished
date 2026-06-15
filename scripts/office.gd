extends CanvasLayer

@onready var office = $Office_BG
@onready var lamp = $Lamp_Button
@onready var camera = $Camera
@onready var window_bg = $Office_BG/Window_BG
@onready var front_window = $Office_BG/Front_Window
@onready var dark_overlay = $Office_BG/Dark_Office_Overlay

var last_animation_played: String
var animation_direction: String
var lock_movement: bool
var using_flashlight: bool

var sleep_assurance_current_score: float
var happyshroom_fight_active: bool

const RUNNING = preload("uid://dn18i7vrgqil8")
const STAIRS_DOWN = preload("uid://douddgjtsblw3")
const STAIRS_UP = preload("uid://c12xjq2e7f4ix")
const CURTAIN_CLOSING = preload("uid://dyiyvq3cj3wg1")
const CURTAIN_OPENING = preload("uid://bh2qhxmm805wf")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	office.animation_changed.connect(_update_last_animation_played)
	office.animation_finished.connect(_animation_finished)
	SignalBus.update_flashlight_state.connect(update_flashlight_state)
	SignalBus.broadcast_sleep_assurance_score.connect(_update_sleep_assurance_score)
	SignalBus.start_happyshroom_fight.connect(_start_happyshroom_fight)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if office.animation == "office":
		turn_checks()
			
	if "closed" in office.animation:
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			office.play("opening_"+animation_direction)
			SpecialFunctions.audio(CURTAIN_OPENING)
			
	if "open_" in office.animation: # underscore in name is necessary here to distinct "open_dir" from "opening_dir"
		
		if animation_direction == "r" or animation_direction == "l":
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				SignalBus.flashlight_on.emit()
				if using_flashlight == true:
					office.frame = 1
			if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				SignalBus.flashlight_off.emit()
				if using_flashlight == false:
					office.frame = 0

			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				office.play("closing_"+animation_direction)
				SpecialFunctions.audio(CURTAIN_CLOSING)
				if using_flashlight == true:
					SignalBus.flashlight_off.emit()
				
		if animation_direction == "f":
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
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
			if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				if using_flashlight == true:
					SignalBus.flashlight_off.emit()
					if using_flashlight == false:
						office.frame = 0
					
			if office.frame == 0:
				front_window.visible = false
			if office.frame == 1:
				front_window.play("l")
				front_window.visible = true
			if office.frame == 2:
				front_window.play("r")
				front_window.visible = true
								
		if animation_direction == "b":
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				SignalBus.flashlight_on.emit()
				if using_flashlight == true:
					office.frame = 1
			if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				SignalBus.flashlight_off.emit()
				if using_flashlight == false:
					office.frame = 0
		

		if SpecialFunctions.in_range(office.get_local_mouse_position().y,620,720):
			if can_move() == true:
				office.play("leave_"+animation_direction)
				window_bg.visible = false
				if animation_direction == "b": 
					SpecialFunctions.audio(STAIRS_DOWN)
				else: 
					SpecialFunctions.audio(RUNNING)
	

func _input(event: InputEvent) -> void:
	if office.animation == "open_b" and office.frame == 1:
		if event is InputEventKey and event.keycode == KEY_B:
			if sleep_assurance_current_score >= 100.0:
				SignalBus.go_to_sleep.emit()
				
func can_move() -> bool:
	if lock_movement == true:
		return false
	if lamp.button_pressed == true:
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
		window_bg.play("f")
		window_bg.visible = true
		
	elif "turn" in last_animation_played:
		camera.lockpos = 0
		office.play("go_"+animation_direction)
		
	elif "go" in last_animation_played:
		office.play("open_"+animation_direction)
		window_bg.visible = true
		if animation_direction == "l" or animation_direction == "r":
			window_bg.play(animation_direction)
		
	elif "leave" in last_animation_played:
		camera.lockpos = -1
		office.play("return")
		
	elif "opening" in last_animation_played:
		office.play("open_"+animation_direction)

	
	elif "closing" in last_animation_played:
		office.play("closed_"+animation_direction)
		
func turn_checks():
	if can_move() == true:
		if SpecialFunctions.in_range(office.get_local_mouse_position().x,0,100):
			office.play("turn_l")
			SpecialFunctions.audio(RUNNING)
		if SpecialFunctions.in_range(office.get_local_mouse_position().x,1580,1680):
			office.play("turn_r")
			SpecialFunctions.audio(RUNNING)
		if SpecialFunctions.in_range(office.get_local_mouse_position().y,0,100):
			office.play("turn_f")
			SpecialFunctions.audio(RUNNING)
		if SpecialFunctions.in_range(office.get_local_mouse_position().y,620,720):
			office.play("turn_b")
			SpecialFunctions.audio(STAIRS_UP)
		if office.animation != "office" and office.animation != "return": # sets animation_direction only if there is a direction
			animation_direction = office.animation.right(1)
	
func _update_last_animation_played() -> void:
	last_animation_played = office.animation
	
func update_flashlight_state(flashlight_state) -> void:
	using_flashlight = flashlight_state
	
func _update_sleep_assurance_score(score):
	sleep_assurance_current_score = score
	
func _start_happyshroom_fight():
	happyshroom_fight_active = true
