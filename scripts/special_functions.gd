extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

## Creates an AudioStreamPlayer (or 2D if using panning) to play an audio and delete. Volume, pitch, and panning can be changed, as well as looping the audio any number of times. Audio can be persisted through scenes if needed as well.[br]
## [br][param stream]: The AudioStream to play.
## [br][param bus]: The index of the audio bus to play audio in.
## [br][param volume]: The volume to play the audio at. Uses linear volume instead of dBs.
## [br][param pitch]: The pitch to play the audio at.
## [br][param pan]: The panning to play the audio at.
## [br][param repeats]: The amount of times to repeat the audio. -1 can be used to make something repeat infinitely.
## [br][param persist_through_scenes]: Allows the audio to persist playing through scenes. Not recommended to use with infinite repeats.
## [br][param deferred]: Allows deferring the add_child process of the AudioStreamPlayer. Useful for if errors occur when trying to add the node to the tree.
func audio(stream: AudioStream, bus:= 0, volume:= 1.0, pitch:= 1.0, pan:= 0.0, start_delay:= 0.0, repeats:= 0, persist_through_scenes:= false, deferred:= false) -> void:
	assert(start_delay >= 0,"Parameter 'start_delay' must be greater than or equal to 0.")
	assert(repeats >= -1,"Parameter 'repeats' must be greater than or equal to -1.")
	
	@warning_ignore("shadowed_variable")
	var audio: Node
	if pan == 0.0:
		audio = AudioStreamPlayer.new()
	else:
		audio = AudioStreamPlayer2D.new()

	if not persist_through_scenes:
		if not deferred:
			get_tree().current_scene.add_child(audio)
		else:
			get_tree().current_scene.add_child.call_deferred(audio)
	else:
		if not deferred:
			add_child(audio)
		else:
			add_child.call_deferred(audio)
	
	audio.finished.connect(audio.queue_free)
	
	if audio is AudioStreamPlayer2D:
		var camera: Camera2D = get_viewport().get_camera_2d()
		audio.position.x = (camera.position.x+640)+(640*pan)
	audio.bus = AudioServer.get_bus_name(bus)
	audio.stream = stream
	audio.volume_linear = volume
	audio.pitch_scale = pitch
	
	
	if start_delay != 0:
		await get_tree().create_timer(start_delay).timeout
	if not audio.is_inside_tree():
		await audio.tree_entered
	audio.play()

	await audio.finished
	if repeats >= 1:
		repeats -= 1
		SpecialFunctions.audio(stream, bus, volume, pitch, pan, 0, repeats, persist_through_scenes, deferred)
	elif repeats == -1:
		SpecialFunctions.audio(stream, bus, volume, pitch, pan, 0, repeats, persist_through_scenes, deferred)

## Creates a timer that calls a function after its interval expires. Can be given a start delay, a number of repeats, and a random negative or positive offset.[br]
## [br][param function_name]: The name of the function you want to call after the timer expires.
## [br][param interval]: The time in seconds you want to use for the timer's wait_time.
## [br][param start_delay]: The time in seconds you want to delay before allowing the timer's wait_time to start for the first time, subsequent repeats will not use this delay.
## [br][param repeats]: The amount of times you want the timer to be repeated. -1 can be used to repeat indefinitely.
## [br][param random_offset_negative]: The time in seconds you want for the timer to have as a random negative offset.
## [br][param random_offset_positive]: The time in seconds you want for the timer to have as a random positive offset.
## [br][param real_time]: Makes the timer consistent with real time and not be affected by game engine speed changes.
## [br][param persist_through_scenes]: Allows the timer to not be deleted when the scene changes.
## [br][param deferred]: Allows deferring the add_child process of the AudioStreamPlayer. Useful for if errors occur when trying to add the node to the tree.
func timer(function_name: Callable, interval: float, start_delay:= 0.0, repeats:= 0, random_offset_negative:= 0.0, random_offset_positive:= 0.0, real_time:= false, persist_through_scenes:= false, deferred:= false) -> void:
	assert(interval >= 0,"Parameter 'interval' must be greater than or equal to 0.")
	assert(start_delay >= 0,"Parameter 'start_delay' must be greater than or equal to 0.")
	assert(repeats >= -1,"Parameter 'repeats' must be greater than or equal to -1.")
	assert(random_offset_negative <= 0,"Parameter 'random_offset_negative' must be lower than or equal to 0.")
	assert(random_offset_positive >= 0,"Parameter 'random_offset_positive' must be greater than or equal to 0.")
	
	
	@warning_ignore("shadowed_variable")
	var timer:= Timer.new()
	if persist_through_scenes == false:
		if not deferred:
			get_tree().current_scene.add_child(timer)
		else:
			get_tree().current_scene.add_child.call_deferred(timer)
	else:
		if not deferred:
			add_child(timer)
		else:
			add_child.call_deferred(timer)
		
	timer.wait_time = interval + randf_range(random_offset_negative, random_offset_positive)
	timer.ignore_time_scale = real_time # Real_time:= false, if true, it will ignore the time scale and run on real time, not being affected by engine changes
	timer.timeout.connect(function_name)
	timer.timeout.connect(timer.queue_free)
	
	if start_delay != 0:
		await get_tree().create_timer(start_delay).timeout
	if not timer.is_inside_tree():
		await timer.tree_entered
	timer.start()
	
	await timer.timeout
	if repeats >= 1:
		repeats -= 1
		SpecialFunctions.timer(function_name, interval, 0, repeats, random_offset_negative, random_offset_positive, real_time, persist_through_scenes, deferred)
	elif repeats == -1:
		SpecialFunctions.timer(function_name, interval, 0, repeats, random_offset_negative, random_offset_positive, real_time, persist_through_scenes, deferred)

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
