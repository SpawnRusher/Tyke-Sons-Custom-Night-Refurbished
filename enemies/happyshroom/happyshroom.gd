extends Enemy
class_name Happyshroom

@export var enemies_list: Node

@export_group("Canvas Layers")
@export_subgroup("Office")
@export var office_layer: CanvasLayer
@export var office: AnimatedSprite2D
@export var office_modulate: CanvasModulate
@export_subgroup("GUI Layer")
@export var gui_layer: CanvasLayer
@export var gui_modulate: CanvasModulate
@export_subgroup("Happyshroom Layer")
@export var happyshroom_layer: CanvasLayer
@export var happyshroom_fade: ColorRect
@export var happyshroom_text: RichTextLabel

@export_group("Happyshroom AI")
@export var testvar: int

@onready var camera: Camera2D = get_viewport().get_camera_2d()

const HAPPYSHROOM_BOSS_MUSIC = preload("uid://cwjw1aqycksxv")


var dialogue: Array = ["You thought it was over.","You thought you could finally go to sleep and escape this hell.","You can't go to sleep just yet.","Something got inside."]

var happyshroom_laughs: Array = [preload("uid://cnq6vu6n6cs5w"), preload("uid://dpj4nc1887c81"), preload("uid://bm5aol3fvyr1b"), preload("uid://memlagcty5cs")]
var happyshroom_startles: Array = [preload("uid://c7r6p26y4cvj2"), preload("uid://cfh0sbfs55bjn"), preload("uid://bd06x5cpoxtt6")]

func _ready() -> void:
	if Global.ENABLED_IDS.find(false,1) != -1:
		deactivate()
		return
	Global.ENABLED_IDS[ENEMY_IDS.HAPPYSHROOM] = true
	SignalBus.activate_happyshroom.connect(_activate_happyshroom)
	SignalBus.start_happyshroom_fight.connect(start_fight)
	
func deactivate() -> void:
	happyshroom_layer.queue_free()

func _activate_happyshroom() -> void:
	get_tree().paused = false
	deactivate_enemies()
	office_layer.lock_movement = true
	office_layer.last_animation_played = "return"
	office_layer._animation_finished()
	camera.lockpos = -1
	gui_modulate.color = Color(1,0,0)
	office_modulate.color = Color(4.416, 0.0, 0.0)
	happyshroom_layer.show()
	intro_dialogue()
	
func intro_dialogue() -> void:
	for i in 4:
		if i == 3:
			SpecialFunctions.audio(happyshroom_laughs[3],0,0.1,0.5)
		happyshroom_text.self_modulate = Color(255,255-((255/4.0)*(i+1)),255-((255/4.0)*(i+1)))
		happyshroom_text.text = dialogue[i]
		await get_tree().create_timer(3).timeout
		if i == 3:
			await get_tree().create_timer(2).timeout
		var tween = get_tree().create_tween()
		tween.tween_property(happyshroom_text,"self_modulate:a",0,3)
		await tween.finished
		await get_tree().create_timer(3).timeout
		if i == 3:
			await get_tree().create_timer(2).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(happyshroom_fade,"self_modulate:a",0,2)
	await tween.finished
	SignalBus.start_happyshroom_fight.emit()
	happyshroom_fade.visible = false

func start_fight() -> void:
	office_layer.lock_movement = false
	
func deactivate_enemies() -> void:
	var enemies = enemies_list.get_children()
	for i in enemies:
		i.deactivate()
