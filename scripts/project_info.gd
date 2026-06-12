extends Node

## VERSION VARIABLES
var version: String = "v0.1.0"
var version_val: int
var temp_version: PackedStringArray
var version_verdict: String

## PASTEBIN VARIABLES
const pastebin_id: String = "iRTnzuBH"
var http_request_output: Error
var pastebin_lines: PackedStringArray
var pastebin_current_line_elements: PackedStringArray


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	temp_version = version.split(".")
	version_val = (temp_version[0].right(1)+temp_version[1]+temp_version[2]).to_int()
	print("Build version: ", version, " (", version_val, ")")
	pastebin_get()

func pastebin_get() -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(request_completed)
	http_request_output = http_request.request("https://pastebin.com/raw/"+pastebin_id)
	if http_request_output != OK:
		print("An error occurred while initiating the HTTP request: ", http_request_output) 

func request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("Failed to fetch Pastebin. Status code: ", response_code)
	pastebin_checks(body.get_string_from_utf8())


func pastebin_checks(paste_text) -> void:
	pastebin_lines = paste_text.split("\r\n") # Pastebin files end a line with '\r', and start a new line with '\n\. This allows detecting new lines.
	
	for i in pastebin_lines.size():
		pastebin_current_line_elements = pastebin_lines[i].split("$") # Goes line by line and splits each one for use.
			
		if i == 0:
			temp_version = pastebin_current_line_elements[1].split(".")
			
			if (temp_version[0].right(1)+temp_version[1]+temp_version[2]).to_int() < version_val:
				version_verdict = "dev"
					
			if (temp_version[0].right(1)+temp_version[1]+temp_version[2]).to_int() == version_val:
				version_verdict = "current"
					
			if (temp_version[0].right(1)+temp_version[1]+temp_version[2]).to_int() > version_val:
				version_verdict = "outdated"
				
			for j in range(3,pastebin_current_line_elements.size()):
				temp_version = pastebin_current_line_elements[j].split(".")
				if (temp_version[0].right(1)+temp_version[1]+temp_version[2]).to_int() == version_val:
					version_verdict = "disabled"
		
			version_check(version_verdict,temp_version)
		

func version_check(version_type,pastebin_version) -> void:
	if version_type == "disabled":
		print("Version ", version, " is a disabled version of the game. Please launch the game on a different version.")
		return

	if version_type == "dev":
		print("Version ", version, " is a newer build than the current public release. This can mean this is a work-in-progress developer build, or I forgot to update the pastebin.")
		
	if version_type == "current":
		print("Version ", version, " is the most up-to-date public release.")

	if version_type == "outdated":
		print("Version ", version, " is an outdated version of the game. The latest release is ", pastebin_version, ". Updating is recommended.")
	
