class_name Nightmare_Chipper extends Enemy

@export_group("Nodes")
@export var office_layer: CanvasLayer
@export var office: AnimatedSprite2D
@export var sprite: AnimatedSprite2D
@export var sleep_assurance: RichTextLabel
@export_group("Variables")
@export var flash_timer: float
@export var kill_timer: float

enum STATES {IDLE=-1,ACTIVE,JUMPSCARE}
enum ATTACK_STATES {CLOSED, OPEN}
var state: STATES = STATES.IDLE
var attack_state: ATTACK_STATES
var current_timer: float
var flashlight_state: Global.FLASHLIGHT_STATES

func _ready() -> void:
	super()
	if not enabled: return

	office.animation_finished.connect(_spawn_nightmare_chipper)
	office.animation_changed.connect(_office_animation_changed)
	SignalBus.update_flashlight_state.connect(_update_flashlight_state)

func _process(delta: float) -> void:
	sprite.frame = _frame_checks()
	if state == STATES.IDLE:
		return
	
	if state == STATES.JUMPSCARE:
		if office.animation == "return" or office.animation == "office":
			_jumpscare()
		return
		
	if office.animation == "open_b" and flashlight_state == Global.FLASHLIGHT_STATES.ON:
		current_timer -= 1 * delta
	
	if current_timer <= 0:
		match attack_state:
			ATTACK_STATES.CLOSED:
				_jumpscare(JUMPSCARE_AREAS.BEDROOM)
			ATTACK_STATES.OPEN:
				_leave_nightmare_chipper()

func _deactivate() -> void:
	super()
	sprite.queue_free()

func _office_animation_changed() -> void:
	if office.animation == "leave_b":
		if attack_state == ATTACK_STATES.OPEN:
			_prepare_jumpscare()

func _spawn_nightmare_chipper() -> void:
	if office.animation == "open_b":
		state = STATES.ACTIVE
		attack_state = ATTACK_STATES.values().pick_random()
		current_timer = [kill_timer,flash_timer][attack_state]
		if sleep_assurance.sleep_assurance_normal >= 1:
			attack_state = ATTACK_STATES.OPEN
		
func _leave_nightmare_chipper() -> void:
	state = STATES.IDLE
	SignalBus.flashlight_off.emit()
	
func _update_flashlight_state(new_state: Global.FLASHLIGHT_STATES) -> void:
	flashlight_state = new_state

func _frame_checks() -> int:
	if sprite.frame > 0:
		if flashlight_state == Global.FLASHLIGHT_STATES.ON:
			return sprite.frame
		return 0
	if office.animation != "open_b":
		return 0
	if flashlight_state != Global.FLASHLIGHT_STATES.ON:
		return 0
	return attack_state+1

func _prepare_jumpscare() -> void:
	state = STATES.JUMPSCARE
