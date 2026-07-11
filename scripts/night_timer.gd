extends RichTextLabel

@export var happyshroom: Happyshroom

var time_scene_start: int
var time_before_happyshroom: int
var time_happyshroom_start: int
var time_happyshroom_fight: int
var time_elapsed: int
var time_milliseconds: int
var time_seconds: int
var time_minutes: int

var pause_timer: bool

func _ready() -> void:
	SignalBus.go_to_sleep.connect(_go_to_sleep)
	SignalBus.activate_happyshroom.connect(_update_happyshroom_intro)
	SignalBus.start_happyshroom_fight.connect(_update_happyshroom_start_time)
	time_scene_start = Time.get_ticks_msec()
	
func _process(delta: float) -> void:
	time_elapsed = Time.get_ticks_msec() - time_scene_start
	if time_happyshroom_start != 0:
		time_elapsed = Time.get_ticks_msec() - time_happyshroom_start

	@warning_ignore_start("integer_division")
	time_milliseconds = (time_elapsed % 1000) / 10
	time_seconds = (time_elapsed / 1000) % 60
	time_minutes = ((time_elapsed / 1000) / 60) % 60
		
	text = ("     %02d:%02d.%02d" % [time_minutes, time_seconds, time_milliseconds])
	
	if happyshroom.state == happyshroom.STATES.INTRO:
		text = "00:00.00"

func _go_to_sleep() -> void:
	if happyshroom != null and happyshroom.enabled == true:
		if happyshroom.state == happyshroom.STATES.IDLE:
			time_before_happyshroom = time_elapsed
		if happyshroom.state == happyshroom.STATES.ACTIVE:
			time_happyshroom_fight = time_elapsed
		Global.win_time = time_before_happyshroom + time_happyshroom_fight
		return
	Global.win_time = time_elapsed

func _update_happyshroom_intro() -> void:
	happyshroom.state = happyshroom.STATES.INTRO

func _update_happyshroom_start_time() -> void:
	time_happyshroom_start = Time.get_ticks_msec()
	happyshroom.state = happyshroom.STATES.ACTIVE
