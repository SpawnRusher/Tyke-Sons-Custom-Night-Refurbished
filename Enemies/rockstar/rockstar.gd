extends Enemy
class_name Rockstar

@export_group("Nodes")
@export var player: TextureRect
@export var player_area_2d: Area2D
@export var sprite: TextureRect
@export var sprite_area_2d: Area2D
@export_group("Variables")
@export_enum("x","y") var move_axis: String
@export var move_timer: Vector2 # Vector2 is used due to lack of official Tuples. x = lower bound, y = higher bound.
@export var idle_time: float = 1
@export var min_position: float
@export var max_position: float
@export var blink_time: float = 0.15

enum MOVE_DIRECTION {UP_LEFT=-1,DOWN_RIGHT=1}
var move_direction: MOVE_DIRECTION = [MOVE_DIRECTION.UP_LEFT, MOVE_DIRECTION.DOWN_RIGHT].pick_random()

func _ready() -> void:
	super()
	if not enabled: return

	sprite_area_2d.area_entered.connect(_area_entered)

	if move_direction == MOVE_DIRECTION.UP_LEFT:
		set("icon.position."+move_axis,min_position)
	if move_direction == MOVE_DIRECTION.DOWN_RIGHT:
		set("icon.position."+move_axis,max_position)
		
	SpecialFunctions.timer(blinking,blink_time,0,-1,0,0,false,false,true)
	SpecialFunctions.timer(start_moving,idle_time,0,0,0,0,false,false,true)

func _deactivate() -> void:
	super()
	sprite.queue_free()
	
func _area_entered(body: Node2D) -> void:
	if body == player_area_2d:
		_jumpscare()
	
func blinking() -> void:
	sprite.visible = !sprite.visible
	
func start_moving() -> void:
	move_direction = move_direction * -1 as MOVE_DIRECTION
	var move_to: float = min_position
	if move_direction == MOVE_DIRECTION.DOWN_RIGHT:
		move_to = max_position
	var tween: Tween = get_tree().create_tween()
	var current_move_time: float = randf_range(move_timer.x,move_timer.y)
	tween.tween_property(sprite,"position:"+move_axis,move_to,current_move_time).set_trans(Tween.TRANS_LINEAR)
	# this 'await' is required, without it, im technically calling start_moving() from inside of itself
	await tween.finished
	SpecialFunctions.timer(start_moving,idle_time,0,0,0,0,false)
