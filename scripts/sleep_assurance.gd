extends TextureRect

const SLEEP_ASSURANCE_POINT_BORDER = preload("uid://ck5it5jq4buy4")
const SLEEP_ASSURANCE_POINT_PROGRESS = preload("uid://irutswq3wufd")


@onready var grid = $Sleep_Assurance_Grid

var sleep_assurance_points_goal: float = 8
var sleep_assurance_current_score: float = 400
var sleep_assurance_multiplier: float = 1.0

var sleep_assurance_points_array: Array[TextureProgressBar]

func _ready() -> void:
	SignalBus.enemy_defended.connect(_add_score)
	SignalBus.remove_sleep_assurance.connect(_remove_score)
	for i in sleep_assurance_points_goal:
		var temp_point = TextureProgressBar.new()
		temp_point.texture_under = SLEEP_ASSURANCE_POINT_BORDER
		temp_point.texture_progress = SLEEP_ASSURANCE_POINT_PROGRESS
		temp_point.min_value = 0.0
		temp_point.max_value = 100.0
		temp_point.texture_progress_offset = Vector2(6,6)
		grid.add_child(temp_point)
		sleep_assurance_points_array.append(temp_point)
	
	_update_points()


func _update_points():
	for points in sleep_assurance_points_array:
		var point_index = sleep_assurance_points_array.find(points)
		points.value = sleep_assurance_current_score - (point_index*100)

			
func _add_score(enemy):
	var add_score
	if enemy is Chipomat:
		add_score = 3
	if enemy is Fun_Fungal:
		add_score = 5
	if enemy is Springcrab:
		add_score = 10
	if enemy is Toy:
		add_score = 10
	if enemy is Seabill:
		add_score = 0
	
	if add_score == null: #failsafe if i forget to add score
		add_score = 0
		print("Forgot to add score for enemy ",enemy)
	sleep_assurance_current_score += add_score * sleep_assurance_multiplier
	_update_points()

func _remove_score(delta: float, enemy: Enemy):
	if enemy is Seabill:
		sleep_assurance_current_score -= 10 * delta
	_update_points()
