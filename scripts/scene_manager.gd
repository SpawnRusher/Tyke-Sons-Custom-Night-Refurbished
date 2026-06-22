extends Node

var scenes: Dictionary

enum CHANGE_SCENE_BEHAVIOR {
	FAIL,
	AWAIT,
	BYPASS
	}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	for scene: String in scenes:
		scenes[scene]["status"] = ResourceLoader.load_threaded_get_status(scene,scenes[scene]["progress"])
		if scenes[scene]["load_immediately"] == true and scenes[scene]["progress"] >= 1.0:
			change_to_scene(scene)

## Loads a scene filepath with a threaded request. Supports an indefinite number of scenes at the same time.
func load_scene(path: String, load_immediately:= false, free_after_use:= true, type_hint:= "", use_sub_threads:= false, cache_mode:= ResourceLoader.CACHE_MODE_REUSE) -> void:
	ResourceLoader.load_threaded_request(path, type_hint, use_sub_threads, cache_mode)
	scenes[path] = {
		"status":-1,
		"progress":[-1],
		"load_immediately":load_immediately,
		"free_after_use":free_after_use
		}

func unload_scene(path: String) -> bool:
	return scenes.erase(path)

## Returns the current loading progress of a threaded scene as a float using the scene's filepath.
func get_progress(path: String) -> float:
	return scenes[path]["progress"][0]
	
## Custom scene changer function to work with the script. Checks if the scene is finished loading before changing, otherwise nothing happens.
func change_to_scene(path: String, behavior:= CHANGE_SCENE_BEHAVIOR.AWAIT) -> void:
	if scenes[path]["progress"][0] < 1 and behavior == CHANGE_SCENE_BEHAVIOR.FAIL:
		push_error("Attempted changing to scene before it finished loading. CHANGE_SCENE_BEHAVIOR.FAIL")
	elif behavior == CHANGE_SCENE_BEHAVIOR.AWAIT and get_progress(path) < 1.0:
		scenes[path]["load_immediately"] = true
	else:
		get_tree().change_scene_to_file(path)
		if scenes[path]["free_after_use"] == true:
			ResourceLoader.load_threaded_get(path)
		unload_scene(path)

## Check for how many scenes are pre-loaded in the scene manager.[br]
## [param start]: The index to start at when printing the dictionary entries.
## [param end]: The index to end at when printing the dictionary entries. Default value of -1 means it will end when the dictionary ends.
func print_loaded_scenes(start:= 0, end:= -1) -> void:
	if start > scenes.size():
		start = scenes.size()
	if end == -1 or end > scenes.size():
		end = scenes.size()
		
	for i in range(start,end):
		print_rich(scenes.keys()[i],": ",scenes[scenes.keys()[i]])
