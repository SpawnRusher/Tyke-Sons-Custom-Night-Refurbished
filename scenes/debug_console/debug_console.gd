extends Window

@export var console_text: RichTextLabel
@export var console_input: LineEdit
@export var scroll_container: ScrollContainer

@export var sleep_assurance: RichTextLabel
@export var enemies: Node

var commands: Dictionary = {
	"/help":{
		"description":"[b][color=deep_sky_blue]/help[/color][/b] - If input alone, displays some general info. Can be paired with another command to learn about the command.",
		"function":_help
	},
	"/commands":{
		"description":"[b][color=deep_sky_blue]/commands[/color][/b] - Displays a list of every command",
		"function":_commands
		},
	"/clear":{
		"description":"[b][color=deep_sky_blue]/clear[/color][/b] - Clears the console",
		"function":_clear,
		"print":"Console cleared!"
	},
	"/print":{
		"description":"[b][color=deep_sky_blue]/print[/color][/b] - Prints text to the console",
		"function":_print
	},
	"/set_enemy_property":{
		"description":"[b][color=deep_sky_blue]/set_enemy_property[/color][/b] - Used to modify any property of any active enemy.\r\nUsage: /set_enemy_value Chipomat1 current_kill_timer 1000",
		"function":_set_enemy_property
	},
	"/set_sleep_assurance":{
		"description":"[b][color=deep_sky_blue]/set_sleep_assurance[/color][/b] - Sets the sleep assurance score to the input amount.\r\nUsage: /set_sleep_assurance (score)",
		"help":"Each sleep assurance point is worth 50 score. Accepts integers or decimals.",
		"function":_set_sleep_assurance
	},
	}

func _ready() -> void:
	if not SaveData.get_data(SaveData.FILE_TYPE.SETTINGS,["debug","enable_console"]):
		queue_free()

	scroll_container.get_v_scroll_bar().changed.connect(_scroll_bar_changed.bind(scroll_container.get_v_scroll_bar()))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_text_submit"):
		_input_command(console_input.text)

func _input_command(text: String) -> void:
	console_input.clear()
	var arguments:= text.split(" ")
	var cmd = arguments[0]
	if cmd not in commands:
		_print("[color=red]Invalid command:[/color] '%s'" % cmd)
		return
	
	for action in commands[cmd]:
		match action:
			"print":
				_print(commands[cmd][action])
			"function":
				arguments.remove_at(0)
				if arguments.size() > commands[cmd]["function"].get_argument_count():
					_print("[color=yellow]Too many arguments were entered for command '%s'. Extra arguments will be ignored.[/color]" % cmd)
					arguments.resize(commands[cmd]["function"].get_argument_count())
				print(arguments)
				commands[cmd][action].callv(arguments)
				#arguments.resize(min(arguments.size(),commands[cmd]["function"].get_argument_count()))
				#var optional_arguments: int
				#if "optional_arguments" in commands[cmd]:
					#optional_arguments = commands[cmd]["optional_arguments"]
				#
				#if arguments.size() < commands[cmd]["function"].get_argument_count() - optional_arguments:
					#_print("[b][color=red]Insufficient number of arguments for command '%s'. %d arguments are required, and %d more are optional." % [cmd,commands[cmd]["function"].get_argument_count() - optional_arguments,optional_arguments])
					#continue
					#
				#elif arguments.size() > commands[cmd]["function"].get_argument_count():
					#_print("[color=gray]Command '%s' was called with extra arguments. Some arguments will be ignored.[/color]" % cmd)
					#
				#commands[cmd]["function"].callv(arguments)


func _help(command:= "") -> void:
	if command:
		if ("/" + command) in commands:
			command = "/" + command
		if command in commands:
			if not "help" in commands[command]:
				_print("[color=yellow]No help text available for command '%s'.[/color]" % command)
				return
			_print("\r\n" + commands[command]["help"])
			return
		_print("[color=red]Invalid command '%s' entered for /help.[/color]" % command)
		return
	_print("\r\n[b][color=deep_sky_blue]HELP[/color][/b]")
	_print("Arguments (args) are indicated like this: (Arg). Optionals are prefixed: (?Arg).\r\nArgs will be ignored when inputting commands which lack args, or when inputting more args than a command uses.")

func _commands() -> void:
	_print("\r\n[b][color=deep_sky_blue]COMMANDS[/color][/b]")
	for cmd in commands:
		_print(commands[cmd]["description"])

func _print(text:="") -> void:
	console_text.text += text
	console_text.text += "\r\n"

func _clear() -> void:
	console_text.text = ""

func _scroll_bar_changed(scroll_bar: ScrollBar) -> void:
	scroll_bar.value = scroll_bar.max_value - scroll_bar.page

func _set_enemy_property(enemy_name: String, property_name: String, value_arg: String) -> void:
	var value = float(value_arg)
	var enemy = enemies.find_child(enemy_name)
	if not enemy:
		_print("[color=red]%s does not exist or is not active" % enemy_name)
		return
	if enemy.get(property_name) == null:
		_print("[color=red]%s does not have property '%s'[/color]" % [enemy_name,property_name])
		return
	enemy.set(property_name,value)
	_print("%s property '%s' to %.2f" % [enemy_name,property_name,value])

func _set_sleep_assurance(arg:= "") -> void:
	var score = float(arg)
	sleep_assurance.sleep_assurance_current_score = score
	_print("Set sleep assurance score set to %.2f." % score)
