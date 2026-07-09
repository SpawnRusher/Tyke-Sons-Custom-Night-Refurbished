extends Resource
class_name Preset

@export_group("Enemies")
@export var enabled_enemies: Dictionary[Enemy.ENEMY_IDS,bool]
@export_group("Sleep Assurance")
@export var points: int = 8
@export var score_per_point: float = 100
