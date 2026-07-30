extends RichTextLabel

@export var enemies: Node

var enemies_list: Array[Node]

func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
	await get_tree().create_timer(0.05).timeout
	enemies_list = enemies.get_children()
	
func _process(delta: float) -> void:
	text = ""
	for enemy: Enemy in enemies_list:
		text += "%s: " % Enemy.ENEMY_IDS.keys()[enemy.enemy_id]
		var new_text: String = ""
		if enemy is Chipomat:
			if enemy.state == enemy.STATES.IDLE:
				new_text = "[color=deep_sky_blue]%s,[/color] [color=gold]SPAWN=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.current_spawn_timer]
			elif enemy.state == enemy.STATES.ACTIVE:
				new_text = "[color=dark_orange]%s,[/color] [color=deep_sky_blue]SIDE=%s,[/color] [color=red]KILL=%1.2f,[/color] [color=gold]LEAVE=%1.2f[/color]" % [enemy.SIDES.keys()[enemy.side],enemy.STATES.keys()[enemy.state],enemy.current_kill_timer,enemy.current_leave_timer]
			else:
				new_text = "[color=red]%s[/color]" % enemy.STATES.keys()[enemy.state]
		elif enemy is Fun_Fungal:
			if enemy.state == enemy.STATES.IDLE:
				new_text = "[color=deep_sky_blue]%s,[/color] [color=gold]SPAWN=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.current_idle_timer]
			else:
				new_text = "[color=dark_orange]%s,[/color] [color=deep_sky_blue]POSITION=%s,[/color] [color=red]PROGRESS=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.POSITIONS.keys()[enemy.position],enemy.current_progress_normalized]
		elif enemy is Springcrab:
			if enemy.state == enemy.STATES.IDLE:
				new_text = "[color=deep_sky_blue]%s,[/color] [color=gold]SPAWN=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.current_spawn_timer]
			elif enemy.state == enemy.STATES.ACTIVE:
				new_text = "[color=dark_orange]%s,[/color] [color=chartreuse]LAST_SIDE=%s[/color] [color=gold]FLASHES=%d,[/color] [color=red]KILL=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.last_side_flashed.to_upper(),enemy.current_leave_flashes,enemy.current_kill_timer]
			else:
				new_text = "[color=red]%s[/color]" % enemy.STATES.keys()[enemy.state]
		elif enemy is Nightmare_Chipper:
			if enemy.state == enemy.STATES.IDLE:
				new_text = "[color=deep_sky_blue]%s[/color]" % enemy.STATES.keys()[enemy.state]
			elif enemy.state == enemy.STATES.ACTIVE:
				new_text = "[color=dark_orange]%s,[/color] [color=chartreuse]%s,[/color] [color=%s]%s=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.ATTACK_STATES.keys()[enemy.attack_state],["red","gold"][enemy.attack_state],["KILL","FLASH"][enemy.attack_state],enemy.current_timer]
			else:
				new_text = "[color=red]%s[/color]" % enemy.STATES.keys()[enemy.state]
		text += new_text + "\r\n"
