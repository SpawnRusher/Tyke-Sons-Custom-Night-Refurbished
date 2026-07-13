extends Enemy
class_name Rockstar

@export_group("Nodes")
@export var player: TextureRect
@export var player_area_2d: Area2D
@export var sprite: TextureRect
@export var sprite_area_2d: Area2D
@export_group("Variables")
@export var move_timer: Vector2 # Vector2 is used due to lack of official Tuples. x = lower bound, y = higher bound.
@export var idle_time: float = 1.1
@export var positions: Array[Vector2]
@export var blink_time: float = 0.15

enum MOVE_DIRECTION {UP_LEFT,DOWN_RIGHT}
var move_direction: MOVE_DIRECTION = MOVE_DIRECTION.values().pick_random()

func _ready() -> void:
	super()
	if not enabled: return
	sprite_area_2d.area_entered.connect(_area_entered)
	sprite.set("position",positions[move_direction])
	add_child(SpecialFunctions.start_timer(blinking,blink_time,-1,true))
	add_child(SpecialFunctions.start_timer(start_moving,idle_time,0,true))

func _deactivate() -> void:
	super()
	sprite.queue_free()
	
func _area_entered(body: Node2D) -> void:
	if body == player_area_2d:
		_jumpscare()
	
func blinking() -> void:
	sprite.visible = !sprite.visible
	
func start_moving() -> void:
	move_direction = wrapi(move_direction+1,0,2) as MOVE_DIRECTION
	var move_to: Vector2 = positions[move_direction]
	var tween: Tween = create_tween()
	var current_move_time: float = randf_range(move_timer.x,move_timer.y)
	tween.tween_property(sprite,"position",move_to,current_move_time).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	tween.kill()
	add_child(SpecialFunctions.start_timer(start_moving,idle_time,0,true))
