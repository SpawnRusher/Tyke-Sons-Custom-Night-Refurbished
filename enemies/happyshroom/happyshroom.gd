extends CanvasLayer

@onready var office_layer = $"../Office"
@onready var office = $"../Office/Office_BG"
@onready var office_modulate = $"../Office/CanvasModulate"
@onready var camera = $"../Office/Camera"
@onready var gui = $"../GUI"
@onready var gui_modulate = $"../GUI/CanvasModulate"
@onready var fade = $Fade
@onready var text = $Text

var dialogue: Array = ["You thought it was over.","You thought you could finally go to sleep and escape this hell.","You can't go to sleep just yet.","Something got inside."]

func _ready() -> void:
	SignalBus.activate_happyshroom.connect(_activate_happyshroom)
	SignalBus.start_happyshroom_fight.connect(start_fight)

func _activate_happyshroom() -> void:
	get_tree().paused = false
	deactivate_enemies()
	office_layer.lock_movement = true
	office_layer.last_animation_played = "return"
	office_layer._animation_finished()
	camera.lockpos = -1
	gui_modulate.color = Color(1,0,0)
	office_modulate.color = Color(4.416, 0.0, 0.0)
	show()
	intro_dialogue()
	
func intro_dialogue():
	for i in 4:
		text.self_modulate = Color(255,255-((255/4.0)*(i+1)),255-((255/4.0)*(i+1)))
		text.text = dialogue[i]
		await get_tree().create_timer(3).timeout
		if i == 3:
			await get_tree().create_timer(2).timeout
		var tween = get_tree().create_tween()
		tween.tween_property(text,"self_modulate:a",0,3)
		await tween.finished
		await get_tree().create_timer(3).timeout
		if i == 3:
			await get_tree().create_timer(2).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(fade,"self_modulate:a",0,2)
	await tween.finished
	SignalBus.start_happyshroom_fight.emit()
	fade.visible = false

func start_fight():
	office_layer.lock_movement = false
	
func deactivate_enemies():
	var enemies = $"../Enemies".get_children()
	for i in enemies:
		i._queue_free()
