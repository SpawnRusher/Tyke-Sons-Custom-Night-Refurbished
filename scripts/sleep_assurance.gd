extends RichTextLabel

const SLEEP_ASSURANCE_POINT_BORDER = preload("uid://ck5it5jq4buy4")
const SLEEP_ASSURANCE_POINT_PROGRESS = preload("uid://irutswq3wufd")

@export var grid: GridContainer

var sleep_assurance_points_amount: float = 8
var sleep_assurance_score_per_point: float = 100
var sleep_assurance_current_score: float = 0
var sleep_assurance_multiplier: float = 1.0
var sleep_assurance_normal: float = 0.0

var sleep_assurance_points_array: Array[TextureProgressBar]

func _ready() -> void:
	SignalBus.enemy_defended.connect(_add_score)
	SignalBus.remove_sleep_assurance.connect(_remove_score)
	SignalBus.activate_happyshroom.connect(_activate_happyshroom)
	for i in sleep_assurance_points_amount:
		var temp_point: TextureProgressBar = TextureProgressBar.new()
		temp_point.texture_under = SLEEP_ASSURANCE_POINT_BORDER
		temp_point.texture_progress = SLEEP_ASSURANCE_POINT_PROGRESS
		temp_point.min_value = 0.0
		temp_point.max_value = sleep_assurance_score_per_point
		temp_point.texture_progress_offset = Vector2(6,6)
		grid.add_child(temp_point)
		sleep_assurance_points_array.append(temp_point)
	
	_update_points()

func _input(event: InputEvent) -> void:
	if OS.is_debug_build():
		if event is InputEventKey and event.is_pressed():
			if event.keycode == KEY_I:
				sleep_assurance_current_score -= sleep_assurance_score_per_point
				_update_points()
			if event.keycode == KEY_O:
				sleep_assurance_current_score += sleep_assurance_score_per_point
				_update_points()

func _update_points() -> void:
	sleep_assurance_normal = sleep_assurance_current_score/sleep_assurance_score_per_point/sleep_assurance_points_amount
	for point in sleep_assurance_points_array:
		var point_index: int = sleep_assurance_points_array.find(point)
		point.value = sleep_assurance_current_score - (point_index*sleep_assurance_score_per_point)

func _add_score(enemy: Enemy) -> void:
	enemy.sleep_assurance_score = max(0,enemy.sleep_assurance_score) # so I can put a warning in the Enemy class for when sleep_assurance_score is not set
	sleep_assurance_current_score = sleep_assurance_current_score + enemy.sleep_assurance_score * sleep_assurance_multiplier
	_update_points()

func _remove_score(delta: float, enemy: Enemy) -> void:
	if enemy is Seabill:
		sleep_assurance_current_score = max(0,sleep_assurance_current_score - 10 * delta)
	_update_points()
	
func _activate_happyshroom() -> void:
	sleep_assurance_current_score = 0
	_update_points()
