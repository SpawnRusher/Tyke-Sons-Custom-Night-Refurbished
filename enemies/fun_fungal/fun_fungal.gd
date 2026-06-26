extends Enemy
class_name Fun_Fungal
##The office layer.
@export var office_layer: CanvasLayer
##The office background.
@export var office: AnimatedSprite2D
##The Fun Fungal sprite.
@export var sprite: AnimatedSprite2D
## The amount of time Fun Fungal needs to go unflashed for in order to kill.
@export var progress_timer: float
## Idle time
@export var idle_timer: float

var side: int
var sides: Array = ["l","idle","r"]
var office_animation_direction: String
var current_progress: float
var lerp_progress: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await super()
	if enabled == false:
		deactivate()
		return
	
	_spawn_fungal()
	
func _process(delta: float) -> void:
	office_animation_direction = office.animation.right(1)
	sprite.visible = false
	if office_animation_direction == sides[side+1]:
		sprite.visible = true
		
	if current_progress >= 0: # this is so that when it goes below 0, i can set an await timer without any more values needed before resetting
		if not flash_check():
			current_progress += 1 * delta
		else:
			current_progress -= 10 * delta
		
	lerp_progress = current_progress/progress_timer
		
	if side == -1:
		sprite.position.x = lerpf(960,760,lerp_progress)
		sprite.position.y = lerpf(35,235,lerp_progress)
	if side == 1:
		sprite.position.x = lerpf(290,490,lerp_progress)
		sprite.position.y = lerpf(50,250,lerp_progress)
	
	if current_progress < 0 and side != 0:
		_leave_fungal()
			
	if current_progress >= progress_timer:
		jumpscare()

func deactivate():
	self.queue_free()
	sprite.queue_free()
	
func _spawn_fungal():
	await get_tree().create_timer(idle_timer).timeout
	side = [-1,1].pick_random()
	office_layer.update_window_occupants(enemy_id,side,true)
	sprite.rotation_degrees = 180 - (45 * side) # 1 == 135, -1 == 255
	current_progress = 0

func _leave_fungal() -> void:
	SignalBus.enemy_defended.emit(self)
	office_layer.update_window_occupants(enemy_id,side,false)
	side = 0
	_spawn_fungal()

func flash_check():
	if office_animation_direction != sides[side+1]:
		return false
	if "open_" not in office.animation:
		return false
	if office.frame != 1:
		return false
	return true
