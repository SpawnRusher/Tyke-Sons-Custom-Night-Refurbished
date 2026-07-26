extends PanelContainer

enum STATISTIC_TYPES {INT,FLOAT,BATTERY_DRAINED,PLAYTIME}

@export var statistics_menu: Control
@export var group: String
@export var statistic_name: String
@export var value_label: RichTextLabel
@export var value_type: STATISTIC_TYPES
@export_range(0,10,1,"prefer_slider") var float_decimal_places: int = 2
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
			to_text = str(snappedf(SaveData.get_data(SaveData.FILE_TYPE.SAVE,access_key),1.0/(10**float_decimal_places)))
		STATISTIC_TYPES.BATTERY_DRAINED:
			var battery_value = SaveData.get_data(SaveData.FILE_TYPE.SAVE,access_key)
			battery_value = snappedf(battery_value,1.0/(10**float_decimal_places))
			to_text = str(battery_value)
		STATISTIC_TYPES.PLAYTIME:
			@warning_ignore_start("integer_division")
			var milliseconds:= int(SaveData.get_data(SaveData.FILE_TYPE.SAVE,access_key))
			var hours = milliseconds / 3600000
			milliseconds -= hours * 3600000
			var minutes = milliseconds / 60000
			milliseconds -= minutes * 60000
			var seconds = milliseconds / 1000
			milliseconds -= seconds * 1000
			milliseconds /= 10 #milliseconds is stored as a 3 digit int value from 0-999, so this "rounds it to 2 decimal places"
			to_text = ("%d hour(s), %d minute(s), %d.%02d second(s) [%02d:%02d:%02d.%02d]" % [hours,minutes,seconds,milliseconds,hours,minutes,seconds,milliseconds])
			@warning_ignore_restore("integer_division")
	value_label.text = value_prefix + to_text + value_suffix
