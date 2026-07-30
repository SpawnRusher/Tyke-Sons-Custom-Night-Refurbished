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
		elif enemy is Seabill:
			if enemy.state == enemy.STATES.IDLE:
				new_text = "[color=deep_sky_blue]%s,[/color] [color=gold]READY=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.current_timer]
			elif enemy.state == enemy.STATES.READY:
				new_text ="[color=chartreuse]%s,[/color] [color=gold]SPAWN=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.current_timer]
			elif enemy.state == enemy.STATES.ACTIVE:
				new_text = "[color=dark_orange]%s,[/color] [color=chartreuse]PROGRESS=%1.2f,[/color] [color=red]KILL=%1.2f,[/color] [color=gold]FLASH=%1.2f,[/color] [color=deep_sky_blue]GRACE=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.current_walk_progress,enemy.current_kill_timer,enemy.current_flash_timer,enemy.current_sleep_assurance_grace_period]
			else:
				new_text = "[color=red]%s[/color]" % enemy.STATES.keys()[enemy.state]
		elif enemy is Rockstar:
			if enemy.current_idle_timer:
				new_text = "[color=deep_sky_blue]IDLE,[/color] [color=chartreuse]%s,[/color] [color=gold]IDLE=%1.2f[/color]" % [enemy.MOVE_DIRECTION.keys()[enemy.move_direction],enemy.current_idle_timer.time_left]
			else:
				new_text = "[color=deep_sky_blue]MOVING,[/color] [color=chartreuse]%s[/color] [color=gold]MOVE=%1.2f[/color]" % [enemy.MOVE_DIRECTION.keys()[enemy.move_direction],enemy.current_elapsed_move_time]
		elif enemy is Bruce:
			new_text = "Bruce dont work yet son"
		elif enemy is Chipper:
			new_text = "[color=deep_sky_blue]SPAWN=%1.2f" % enemy.current_spawn_timer
			if enemy.current_lumber and enemy.current_lumber.active:
				new_text += ", [/color][color=red]KILL=%1.2f[/color]" % enemy.current_lumber.lumber_timer
			else:
				new_text +="[/color]"
		elif enemy is Toy:
			if enemy.state == enemy.STATES.JUMPSCARE:
				new_text = "[color=red]%s[/color]" % enemy.STATES.keys()[enemy.state]
			elif enemy.state == enemy.STATES.ACTIVE:
				new_text = "[color=dark_orange]%s,[/color] [color=red]KILL=%1.2f,[/color] [color=gold]LEAVE=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.current_kill_timer,enemy.current_leave_timer]
			else: # all the stages before active
				new_text = "[color=deep_sky_blue]%s,[/color] [color=gold]TIMER=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.current_spawn_timer]
		elif enemy is Phantom_Chipomat:
			new_text = "[color=red]ATTACK=%1.2f[/color]" % enemy.current_attack_timer
		elif enemy is Happyshroom:
			new_text = "Happyshroom wip son"
		text += new_text + "\r\n"
