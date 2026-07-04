extends RichTextLabel

var time_scene_start: int
var time_happyshroom_start: int
var time_elapsed: int
var time_milliseconds: int
var time_seconds: int
var time_minutes: int
var time_hours: int

var pause_timer: bool

var happyshroom_intro: bool

func _ready() -> void:
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
	time_hours = (time_elapsed / 3600000)
		
	text = ("     %02d:%02d.%02d" % [time_minutes, time_seconds, time_milliseconds])
	
	if happyshroom_intro:
		text = "00:00.00"

func _update_happyshroom_intro() -> void:
	happyshroom_intro = true

func _update_happyshroom_start_time() -> void:
	time_happyshroom_start = Time.get_ticks_msec()
	happyshroom_intro = false
