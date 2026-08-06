class_name Wave
extends Resource

@export var normal: int = 0
@export var elite: int = 0
@export var boss: int = 0

func _init(pNormal: int = 0, pElite: int = 0, pBoss: int = 0):
	normal = pNormal
	elite = pElite
	boss = pBoss
func spawnNormal() -> void:
	normal -= 1
func spawnElite() -> void:
	elite -= 1
func spawnBoss() -> void:
	boss -= 1
func getRandEnemyBossLast() -> DefenceEnemy.EnemyType:
	if (total() > 0):
		var options = []
		if (normal > 0):
			options.append(DefenceEnemy.EnemyType.NORMAL)
		if (elite > 0):
			options.append(DefenceEnemy.EnemyType.ELITE)
		if (options.is_empty() && boss > 0):
			options.append(DefenceEnemy.EnemyType.BOSS)
		var index = randi() % options.size()
		subType(options[index])
		return (options[index])
	return (DefenceEnemy.EnemyType.NORMAL)
func subType(type:DefenceEnemy.EnemyType):
	match type:
		DefenceEnemy.EnemyType.NORMAL:
			spawnNormal()
		DefenceEnemy.EnemyType.ELITE:
			spawnElite()
		DefenceEnemy.EnemyType.BOSS:
			spawnBoss()
func total() -> int:
	return (normal + elite + boss)
