extends Control

func _ready() -> void:
	if GameJolt.authorized_username != "":
		GameJolt.api_request("trophies","fetch",{"username":GameJolt.authorized_username,"user_token":GameJolt.authorized_user_token})



func _create_trophies() -> void:
	pass
