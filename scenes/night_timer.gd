extends RichTextLabel

var time_scene_start: int
var time_elapsed: int
var time_milliseconds: int
var time_seconds: int
var time_minutes: int
var time_hours: int

var pause_timer: bool

func _ready() -> void:
	SignalBus.go_to_sleep.connect(_pause_timer)
	time_scene_start = Time.get_ticks_msec()

func _process(delta: float) -> void:
	if pause_timer == false:
		time_elapsed = Time.get_ticks_msec() - time_scene_start

		@warning_ignore_start("integer_division")
		time_milliseconds = (time_elapsed % 1000) / 10
		time_seconds = (time_elapsed / 1000) % 60
		time_minutes = ((time_elapsed / 1000) / 60) % 60
		time_hours = (time_elapsed / 3600000)
		
		text = ("%02d:%02d.%02d" % [time_minutes, time_seconds, time_milliseconds])


func _pause_timer():
	pause_timer = true
