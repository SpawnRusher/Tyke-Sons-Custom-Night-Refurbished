extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func create_audio(stream: AudioStream, bus:= 0, volume:= 1.0, pitch:= 1.0, repeats:= 0, autoplay:= true, persist_through_scenes:= false) -> AudioStreamPlayer:
	var audio:= AudioStreamPlayer.new()
	audio.stream = stream
	audio.bus = AudioServer.get_bus_name(bus)
	audio.volume_linear = volume
	audio.pitch_scale = pitch
	audio.autoplay = autoplay
	audio.finished.connect(_repeat_audio.bind(audio,repeats))
	
	if not persist_through_scenes: 
		SceneManager.scene_changed.connect(audio.queue_free)
		SceneManager.scene_reloaded.connect(audio.queue_free)
	
	return audio
	
func create_audio_2d(stream: AudioStream, bus:= 0, volume:= 1.0, pitch:= 1.0, panning_strength:= 1.0, repeats:= 0, max_distance:= 2000.0, attenuation:= 1.0, area_mask:= 0, autoplay:= true, persist_through_scenes:= false) -> AudioStreamPlayer2D:
	var audio:= AudioStreamPlayer2D.new()
	audio.stream = stream
	audio.bus = AudioServer.get_bus_name(bus)
	audio.volume_linear = volume
	audio.pitch_scale = pitch
	audio.panning_strength = panning_strength
	audio.max_distance = max_distance
	audio.attenuation = attenuation
	audio.autoplay = autoplay
	audio.finished.connect(_repeat_audio.bind(audio,repeats))
	
	if not persist_through_scenes: 
		SceneManager.scene_changed.connect(audio.queue_free)
		SceneManager.scene_reloaded.connect(audio.queue_free)

	return audio

func _repeat_audio(audio: Node, repeats: int) -> void:
	audio.finished.disconnect(_repeat_audio)
	if repeats == 0:
		audio.queue_free()
		return
	audio.play()
	repeats -= 1
	audio.finished.connect(_repeat_audio.bind(audio,repeats))
	
func create_timer(function_name: Callable, interval: float, repeats:= 0, autostart:= true, persist_through_scenes:= false) -> Timer:
	var timer:= Timer.new()
	timer.timeout.connect(function_name)
	timer.one_shot = true
	timer.autostart = autostart
	timer.wait_time = interval
	timer.timeout.connect(_repeat_timer.bind(timer,repeats))
	
	if not persist_through_scenes: 
		SceneManager.scene_changed.connect(timer.queue_free)
		SceneManager.scene_reloaded.connect(timer.queue_free)
	
	return timer

func _repeat_timer(timer: Timer, repeats: int)	-> void:
	timer.timeout.disconnect(_repeat_timer)
	if repeats == 0:
		timer.queue_free()
		return
	timer.start()
	repeats -= 1
	timer.timeout.connect(_repeat_timer.bind(timer,repeats))

func in_range(value: float,min_value: float,max_value: float,min_exclusive:=false,max_exclusive:=false) -> bool:
	if min_exclusive == false and value < min_value:
		return false
	if min_exclusive == true and value <= min_value:
		return false
	if max_exclusive == false and value > max_value:
		return false
	if max_exclusive == true and value >= max_value:
		return false
	return true
