extends Enemy
class_name Rockstar

@export_group("Nodes")
@export var player: TextureRect
@export var sprite: TextureRect
@export_group("Variables")
@export_enum("x","y") var move_axis: String
@export var move_time: float = 1.25
@export var idle_time: float = 1
@export var min_position: float
@export var max_position: float
@export var random_variance: float = 0.1
@export var blink_time: float = 0.15

enum MOVE_DIRECTION {UP_LEFT=-1,DOWN_RIGHT=1}
var move_direction: MOVE_DIRECTION = [MOVE_DIRECTION.UP_LEFT, MOVE_DIRECTION.DOWN_RIGHT].pick_random()

func _ready() -> void:
	super()
	if not enabled: return

	if move_direction == MOVE_DIRECTION.UP_LEFT:
		set("icon.position."+move_axis,min_position)
	if move_direction == MOVE_DIRECTION.DOWN_RIGHT:
		set("icon.position."+move_axis,max_position)
		
	SpecialFunctions.timer(blinking,blink_time,0,-1,0,0,false,false,true)
	SpecialFunctions.timer(start_moving,idle_time,0,0,0,0,false,false,true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player.get_global_rect().intersects(sprite.get_global_rect()):
		_jumpscare()
		
func _deactivate() -> void:
	super()
	sprite.queue_free()
	
func blinking() -> void:
	sprite.visible = !sprite.visible
	
func start_moving() -> void:
	move_direction = move_direction * -1 as MOVE_DIRECTION
	var move_to: float = min_position
	if move_direction == MOVE_DIRECTION.DOWN_RIGHT:
		move_to = max_position
	var tween: Tween = get_tree().create_tween()
	var current_move_time: float = move_time*(1+randf_range(-random_variance,random_variance))
	tween.tween_property(sprite,"position:"+move_axis,move_to,current_move_time).set_trans(Tween.TRANS_LINEAR)
	# this 'await' is required, without it, im technically calling start_moving() from inside of itself
	await get_tree().create_timer(current_move_time).timeout
	SpecialFunctions.timer(start_moving,idle_time,0,0,0,0,false)
