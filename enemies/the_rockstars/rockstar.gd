extends Enemy
class_name Rockstar

## The Player icon.
@export var player: TextureRect
## The Rockstar's icon, a TextureRect node.
@export var sprite: TextureRect
## The axis the enemy moves on.
@export_enum("x","y") var move_axis: String
## The time it takes for the enemy icon to move from min_position to max_position, or vice-versa.
@export var move_time: float = 1.5
## The time the enemy idles for before commencing movement again.
@export var idle_time: float = 1
## The minimum coordinate position relative to the map the icon can go to, which is closer to the top-left of the map.
@export var min_position: float
## The maximum coordinate position relative to the map the icon can go to, which is closer to the bottom-right of the map.
@export var max_position: float
## Adds a random variance to the movements. 0.05 = 5%, 0.1 = 10%, etc. Value is applied with a random range from (-random_variance,random_variance)
@export var random_variance: float = 0.1
## Time between map icons flashing
@export var flash_time: float = 0.08

var move_direction: int = [-1, 1].pick_random()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await super()
	if enabled == false:
		deactivate()
		return

	if move_direction == 1:
		set("icon.position."+move_axis,min_position)
	if move_direction == -1:
		set("icon.position."+move_axis,max_position)
		
	SpecialFunctions.timer(blinking,0.2,0,-1,0,0,false,false,true)
	SpecialFunctions.timer(start_moving,idle_time,0,0,0,0,false,false,true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player.get_global_rect().intersects(sprite.get_global_rect()):
		jumpscare()
		
func deactivate() -> void:
	self.queue_free()
	sprite.queue_free()
	
func blinking() -> void:
	sprite.visible = !sprite.visible
	
func start_moving() -> void:
	move_direction *= -1
	var move_to: float = min_position
	if move_direction == 1:
		move_to = max_position

	var tween: Tween = get_tree().create_tween()
	var current_move_time: float = move_time*(1+randf_range(-random_variance,random_variance))
	tween.tween_property(sprite,"position:"+move_axis,move_to,current_move_time).set_trans(Tween.TRANS_LINEAR)
	# this 'await' is required, without it, im technically calling start_moving() from inside of itself
	await get_tree().create_timer(current_move_time).timeout
	SpecialFunctions.timer(start_moving,idle_time,0,0,0,0,false)
