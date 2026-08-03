class_name Happyshroom extends Enemy

@export var enemies_list: Node

@export_group("Nodes")
@export_subgroup("Office Layer")
@export var office_layer: CanvasLayer
@export var office: AnimatedSprite2D
@export var office_modulate: CanvasModulate
@export var window_background: AnimatedSprite2D
@export var front_window: AnimatedSprite2D
@export_subgroup("GUI Layer")
@export var gui_layer: CanvasLayer
@export var gui_modulate: CanvasModulate
@export_subgroup("Happyshroom Layer")
@export var happyshroom_layer: CanvasLayer
@export var happyshroom_fade: ColorRect
@export var happyshroom_text: RichTextLabel

@export_group("Happyshroom AI")

@onready var camera: Camera2D = get_viewport().get_camera_2d()

const HAPPYSHROOM_BOSS_MUSIC = preload("uid://cwjw1aqycksxv")

const dialogue: Array[String] = ["[shake rate=20 level=2]You thought you could go to sleep.","[shake rate=20 level=5]This nightmare isn't over yet.","[color=red][shake rate=25 level=10]Something got inside.[/shake][/color]"]

const happyshroom_laughs: Array[Resource] = [preload("uid://cnq6vu6n6cs5w"), preload("uid://dpj4nc1887c81"), preload("uid://bm5aol3fvyr1b"), preload("uid://memlagcty5cs")]
const happyshroom_startles: Array[Resource] = [preload("uid://c7r6p26y4cvj2"), preload("uid://cfh0sbfs55bjn"), preload("uid://bd06x5cpoxtt6")]

enum STATES {IDLE,INTRO,ACTIVE}
var state: STATES

func _ready() -> void:
	super()
	if not enabled: return
	
	SignalBus.activate_happyshroom.connect(_activate_happyshroom)
	SignalBus.start_happyshroom_fight.connect(_start_fight)
	
func _deactivate() -> void:
	super()
	happyshroom_layer.queue_free()

func _activate_happyshroom() -> void:
	state = STATES.INTRO
	PauseManager.unpause()
	_deactivate_enemies()
	office_layer.lock_movement = true
	office.play("office")
	window_background.play("f")
	front_window.visible = false
	SignalBus.change_camera_position.emit(-1)
	gui_modulate.color = Color(1,0,0)
	office_modulate.color = Color(4.416, 0.0, 0.0)
	happyshroom_layer.show()
	_intro_dialogue()
	
func _intro_dialogue() -> void:
	for i in 3:
		if i == 2:
			SpecialFunctions.create_audio(happyshroom_laughs[3],0,0.2,0.5)
		happyshroom_text.self_modulate = Color(255,255-((255/4.0)*(i+1)),255-((255/4.0)*(i+1)))
		happyshroom_text.text = dialogue[i]
		await get_tree().create_timer(3).timeout
		if i == 2:
			await get_tree().create_timer(2).timeout
		var text_tween = get_tree().create_tween()
		text_tween.tween_property(happyshroom_text,"self_modulate:a",0,3)
		await text_tween.finished
		await get_tree().create_timer(3).timeout
		if i == 2:
			await get_tree().create_timer(2).timeout
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property(happyshroom_fade,"self_modulate:a",0,2)
	await fade_tween.finished
	SignalBus.start_happyshroom_fight.emit()
	happyshroom_fade.visible = false

func _start_fight() -> void:
	state = STATES.ACTIVE
	office_layer.lock_movement = false
	
func _deactivate_enemies() -> void:
	var enemies = enemies_list.get_children()
	for enemy in enemies:
		if enemy is not Happyshroom:
			enemy._deactivate()
