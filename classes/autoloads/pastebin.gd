extends Node

#region VERSION VARIABLES
enum VERSION_TYPE {LATEST, OUTDATED, DISABLED, DEV}
var version: String
var version_val: int
var temp_version: PackedStringArray
var latest_version: String
var version_verdict: VERSION_TYPE
#endregion

#region PASTEBIN VARIABLES
const pastebin_id: String = "iRTnzuBH"
var http_request_output: Error
var pastebin_lines: PackedStringArray
var pastebin_current_line_elements: PackedStringArray
#endregion

var http_request: HTTPRequest

func _ready() -> void:
	version = ProjectSettings.get_setting("application/config/version")

	temp_version = version.split(".")
	version_val = (temp_version[0].right(1)+temp_version[1]+temp_version[2]).to_int()
	print_debug("Build version: ", version, " (", version_val, ")")
	pastebin_get()

func pastebin_get() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(request_completed)
	print_debug("Attempting to request HTTP " + "https://pastebin.com/raw/"+pastebin_id)
	http_request_output = http_request.request("https://pastebin.com/raw/"+pastebin_id)
	if http_request_output != OK:
		print_debug("An error occurred while initiating the HTTP request: ", http_request_output) 

func request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print_debug("Failed to fetch Pastebin. Status code: ", response_code)
		return
	pastebin_checks(body.get_string_from_utf8())


func pastebin_checks(paste_text: String) -> void:
	print_debug("Comparing Pastebin")
	pastebin_lines = paste_text.split("\r\n") # Pastebin files end a line with '\r', and start a new line with '\n\. This allows detecting new lines.
	
	for line: int in pastebin_lines.size():
		pastebin_current_line_elements = pastebin_lines[line].split("$") # Goes line by line and splits each one for use.
			
		if line == 0:
			temp_version = pastebin_current_line_elements[1].split(".")
			
			if (temp_version[0].right(1)+temp_version[1]+temp_version[2]).to_int() < version_val:
				version_verdict = VERSION_TYPE.DEV
					
			if (temp_version[0].right(1)+temp_version[1]+temp_version[2]).to_int() == version_val:
				version_verdict = VERSION_TYPE.LATEST
					
			if (temp_version[0].right(1)+temp_version[1]+temp_version[2]).to_int() > version_val:
				version_verdict = VERSION_TYPE.OUTDATED
				
			for element: int in range(3,pastebin_current_line_elements.size()):
				var temp_disabled_version: PackedStringArray = pastebin_current_line_elements[element].split(".")
				if (temp_disabled_version[0].right(1)+temp_disabled_version[1]+temp_disabled_version[2]).to_int() == version_val:
					version_verdict = VERSION_TYPE.DISABLED
					temp_version = temp_disabled_version
					
			
			latest_version = temp_version[0] + "." + temp_version[1] + "." + temp_version[2]
			version_check(version_verdict,latest_version)
		

func version_check(version_type: VERSION_TYPE, pastebin_version: String) -> void:
	http_request.queue_free()
	if version_type == VERSION_TYPE.DISABLED:
		SignalBus.pastebin_version_check.emit(version_type, pastebin_version)
		return

	if version_type == VERSION_TYPE.DEV:
		SignalBus.pastebin_version_check.emit(version_type, pastebin_version)
		
	if version_type == VERSION_TYPE.LATEST:
		SignalBus.pastebin_version_check.emit(version_type, pastebin_version)

	if version_type == VERSION_TYPE.OUTDATED:
		SignalBus.pastebin_version_check.emit(version_type, pastebin_version)
	
