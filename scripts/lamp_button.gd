extends Button

const LAMPTOGGLE = preload("uid://bf8j1xugtu8dh")

@onready var office = $"../Office_BG"
@onready var window_bg = $"../Office_BG/Window_BG"
@onready var seabill = $"../../Enemies/Seabill"
@onready var dark_overlay = $"../Office_BG/Dark_Office_Overlay"
func _ready() -> void:
	self.pressed.connect(togglelights)

func _process(_delta: float) -> void:
	disabled = false
	if office.animation != "office":
		disabled = true
	visible = !disabled

func togglelights():
	SpecialFunctions.audio(LAMPTOGGLE,1,1,1,0,0,false)
	dark_overlay.visible = button_pressed
	
