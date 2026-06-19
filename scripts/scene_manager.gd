extends Node

var threaded_scenes: Dictionary[String, bool]
var scene_progresses: Dictionary[String, Array]
var scene_statuses: Dictionary[String,int]

enum CHANGE_SCENE_BEHAVIOR {
	FAIL,
	AWAIT,
	BYPASS
	}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	for scene in threaded_scenes:
		scene_statuses[scene] = ResourceLoader.load_threaded_get_status(scene,scene_progresses[scene])
		if threaded_scenes[scene] == true and scene_progresses[scene][0] >= 1.0:
			change_to_scene(scene)

## Loads a scene filepath with a threaded request. Supports an indefinite number of scenes at the same time.
func load_scene(path: String, load_immediately:= false, type_hint:= "", use_sub_threads:= false, cache_mode:= ResourceLoader.CACHE_MODE_REUSE) -> void:
	ResourceLoader.load_threaded_request(path, type_hint, use_sub_threads, cache_mode)
	threaded_scenes[path] = load_immediately
	scene_progresses[path] = [-1]
	scene_statuses[path] = -1

## Returns the current lofading progress of a threaded scene as a float using the scene's filepath.
func get_progress(path: String) -> float:
	return scene_progresses[path][0]
	
## Custom scene changer function to work with the script. Checks if the scene is finished loading before changing, otherwise nothing happens.
func change_to_scene(path: String, behavior:= CHANGE_SCENE_BEHAVIOR.FAIL) -> void:
	if scene_progresses[path][0] < 1 and behavior == CHANGE_SCENE_BEHAVIOR.FAIL:
		print("Scene not fully loaded yet!")
	elif behavior == CHANGE_SCENE_BEHAVIOR.AWAIT and get_progress(path) < 1.0:
		threaded_scenes[path] = true
	else:
		get_tree().change_scene_to_file(path)
		threaded_scenes.erase(path)
		scene_progresses.erase(path)
		scene_statuses.erase(path)
