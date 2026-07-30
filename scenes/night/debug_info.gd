extends RichTextLabel

@export_group("Enemies")
@export var enemies: Node
@export var chipomat_1: Chipomat
@export var chipomat_2: Chipomat
@export var chipomat_3: Chipomat
@export var fun_fungal: Fun_Fungal
@export var springcrab: Springcrab
@export var nightmare_chipper: Nightmare_Chipper
@export var seabill: Seabill
@export var fredbear: Rockstar
@export var bidy: Rockstar
@export var buster: Rockstar
@export var bruce: Bruce
@export var chipper: Chipper
@export var toy: Toy
@export var phantom_chipomat: Phantom_Chipomat
@export var happyshroom: Happyshroom

func _process(delta: float) -> void:
	text = ""
	for enemy: Enemy in enemies.get_children():
		text += "%s: " % Enemy.ENEMY_IDS.keys()[enemy.enemy_id]
		var new_text: String = ""
		if enemy is Chipomat:
			if enemy.state == enemy.STATES.JUMPSCARE:
				new_text = "[color=red]%s[/color]" % enemy.STATES.keys()[enemy.state]
			elif enemy.state == enemy.STATES.IDLE:
				new_text = "[color=deep_sky_blue]%s,[/color] [color=gold]SPAWN=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.current_spawn_timer]
			else:
				new_text = "[color=dark_orange]%s,[/color] [color=deep_sky_blue]SIDE=%s,[/color] [color=red]KILL=%1.2f,[/color] [color=gold]LEAVE=%1.2f[/color]" % [enemy.SIDES.keys()[enemy.side],enemy.STATES.keys()[enemy.state],enemy.current_kill_timer,enemy.current_leave_timer]
		elif enemy is Fun_Fungal:
			if enemy.state == enemy.STATES.IDLE:
				new_text = "[color=deep_sky_blue]%s,[/color] [color=gold]SPAWN=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.current_idle_timer]
			else:
				new_text = "[color=dark_orange]%s,[/color] [color=deep_sky_blue]SIDE=%s,[/color] [color=red]PRORESS=%1.2f[/color]" % [enemy.STATES.keys()[enemy.state],enemy.POSITIONS.keys()[enemy.position],enemy.current_progress_normalized]
		text += new_text + "\r\n"
