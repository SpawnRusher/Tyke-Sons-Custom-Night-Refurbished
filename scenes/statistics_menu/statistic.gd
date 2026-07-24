extends PanelContainer

enum STATISTIC_TYPES {INT,FLOAT,BATTERY_DRAINED,PLAYTIME}

@export var statistics_menu: Control
@export var group: String
@export var statistic_name: String
@export var value_label: RichTextLabel
@export var value_type: STATISTIC_TYPES
@export var value_prefix: String
@export var value_suffix: String

@onready var access_key: Array[String]

func _ready() -> void:
	access_key = ["statistics"]
	access_key.append(group)
	access_key.append(statistic_name)
	var to_text: String
	match value_type:
		STATISTIC_TYPES.INT:
			to_text = str(int(SaveData.get_data(SaveData.FILE_TYPE.SAVE,access_key)))
		STATISTIC_TYPES.FLOAT:
			to_text = str(SaveData.get_data(SaveData.FILE_TYPE.SAVE,access_key))
		STATISTIC_TYPES.BATTERY_DRAINED:
			var battery_value = SaveData.get_data(SaveData.FILE_TYPE.SAVE,access_key)
			battery_value /= 100.0
			to_text = str(battery_value)
		STATISTIC_TYPES.PLAYTIME:
			@warning_ignore_start("integer_division")
			var milliseconds:= int(SaveData.get_data(SaveData.FILE_TYPE.SAVE,access_key))
			var days = milliseconds / 86400000
			milliseconds -= days * 86400000
			var hours = milliseconds / 3600000
			milliseconds -= hours * 3600000
			var minutes = milliseconds / 60000
			milliseconds -= minutes * 60000
			var seconds = milliseconds / 1000
			milliseconds -= seconds * 1000
			to_text = ("%02dd:%02dh:%02dm:%02ds.%02dms" % [days, hours, minutes,seconds,milliseconds])
			@warning_ignore_restore("integer_division")
		_:
			to_text = "VALUE TYPE NOT CONFIGURED OR IS OUT OF BOUNDS IDK"
	value_label.text = value_prefix + to_text + value_suffix
