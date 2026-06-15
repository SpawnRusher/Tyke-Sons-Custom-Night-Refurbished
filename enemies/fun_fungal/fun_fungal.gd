extends Enemy
class_name Fun_Fungal

##The office background.
@export var office: AnimatedSprite2D
##The Fun Fungal sprite.
@export var sprite: AnimatedSprite2D
## The amount of time Fun Fungal needs to go unflashed for in order to kill.
@export var progress_timer: float
## Idle time
@export var idle_timer: float

var side: int
var sides: Array = ["l","maybeusefront","r"]
var office_animation_direction: String
var current_progress: float
var lerp_progress: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await super()
	if enabled == false:
		_queue_free()
		return

	reset()

func _process(delta: float) -> void:
	office_animation_direction = office.animation.right(1)
	sprite.visible = false
	if office_animation_direction == sides[side+1]:
		sprite.visible = true
		
	if current_progress >= 0: # this is so that when it goes below 0, i can set an await timer without any more values needed before resetting
		if not flash_check():
			current_progress += 1.5 * delta
		else:
			current_progress -= 10 * delta
		
	lerp_progress = current_progress/progress_timer
		
	if side == -1:
		sprite.position.x = lerpf(960,760,lerp_progress)
		sprite.position.y = lerpf(35,235,lerp_progress)
	if side == 1:
		sprite.position.x = lerpf(290,490,lerp_progress)
		sprite.position.y = lerpf(50,250,lerp_progress)
	
	if current_progress < 0:
		reset()
			
	if current_progress >= progress_timer:
		jumpscare()

func _queue_free():
	self.queue_free()
	sprite.queue_free()

func reset() -> void:
	SignalBus.enemy_defended.emit(self)
	await get_tree().create_timer(idle_timer)
	side = wrapi(randi_range(1,2),-1,2)
	sprite.rotation_degrees = 180 - (45 * side) # 1 == 135, -1 == 255
	current_progress = 0

func flash_check():
	if not office_animation_direction == sides[side+1]:
		return false
	if not "open_" in office.animation:
		return false
	if office.frame == 0:
		return false
	return true
	
