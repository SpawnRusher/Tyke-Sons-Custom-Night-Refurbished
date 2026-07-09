extends Enemy
class_name Nightmare_Chipper

@export_group("Nodes")
@export var office_layer: CanvasLayer
@export var office: AnimatedSprite2D
@export var sprite: AnimatedSprite2D
@export_group("Variables")
@export var flash_timer: float
@export var kill_timer: float

enum STATES {IDLE,CLOSED,OPEN}
var state: STATES
var current_timer: float
var using_flashlight: bool

func _ready() -> void:
	super()
	if not enabled: return

	office.animation_finished.connect(_spawn_nightmare_chipper)
	SignalBus.update_flashlight_state.connect(_update_flashlight_state)

func _process(delta: float) -> void:
	if office.animation == "open_b" and using_flashlight:
		current_timer -= 1 * delta
	
	if current_timer <= 0:
		match state:
			STATES.CLOSED:
				_jumpscare(JUMPSCARE_AREAS.BEDROOM)
			STATES.OPEN:
				_leave_nightmare_chipper()

func _deactivate() -> void:
	super()

func _spawn_nightmare_chipper() -> void:
	if office.animation == "open_b":
		state = randi_range(1,2) as STATES
		current_timer = [kill_timer,flash_timer][state]
		
func _leave_nightmare_chipper() -> void:
	pass
		
func _update_flashlight_state(flashlight_state) -> void:
	using_flashlight = flashlight_state
