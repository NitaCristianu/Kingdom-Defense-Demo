extends Node3D

class_name WaveHandler

@onready var chunk_container: ChunkContainerClass = $"../ChunkContainer"
@onready var enemies: Node3D = $"../Enemies"
@onready var new_wave: AudioStreamPlayer3D = $newWave

var maxWaves = -1
var wave: int =-1

static var BaseHp = 8

signal wave_start(wave: int)
signal wave_end
signal base_damaged(hp : int)

func getEnemyData(enemy_name : String) -> Dictionary:
	return Configuration.Data['Entity']['Enemy'][enemy_name]

func damageBase(dmg: int):
	BaseHp -= dmg
	base_damaged.emit(BaseHp)
	if BaseHp <= 0:
		get_tree().change_scene_to_file("res://components/UI/game_lost.tscn")

func spawnEnemy(chunk: Chunk, exitIndex : int, enemyName : String):
	var enemy_class : Resource
	if enemyName == "r6":
		enemy_class= preload("res://components/Enemies/humanoid_r6.tscn")
	elif enemyName == "golden slime":
		enemy_class= preload("res://components/Enemies/golden_slime.tscn")
	elif enemyName == "super slime":
		enemy_class= preload("res://components/Enemies/super_slime.tscn")
	elif enemyName == "glass golem":
		enemy_class= preload("res://components/Enemies/glass_golem.tscn")
	elif enemyName == "pixel knight":
		enemy_class= preload("res://components/Enemies/pixel_knight.tscn")
	elif enemyName == "goblin":
		enemy_class= preload("res://components/Enemies/goblin.tscn")
	elif enemyName == "spider":
		enemy_class= preload("res://components/Enemies/spider.tscn")
	elif enemyName == "solider":
		enemy_class= preload("res://components/Enemies/solider.tscn")
	else:
		enemy_class= preload("res://components/Enemies/enemy.tscn")
		
	var enemy = enemy_class.instantiate()
	var data := getEnemyData(enemyName)
	
	enemy.health = data.Health
	enemy.maxhealth = enemy.health
	enemy.enemy_name = enemyName
	enemy.speed = data.Speed
	enemy.reward = data.Reward
	enemy.shadow = data.shadow
	enemy.fly = data.fly
	enemy.display_name = data.Name
	enemy.init_enemy(chunk, exitIndex)
	enemies.add_child(enemy)
	enemy.animate()

func startWave(chunk_pos: Vector2i, exitIndex: int):
	var extension: Chunk = chunk_container.extend_chunk(chunk_pos, exitIndex)
	# modify to handle every single map end  
	if not extension: extension = chunk_container.get_chunk(chunk_pos)
	var waveData = Configuration.WaveData
	
	var reward = Configuration.read("GAME_DATA", "REWARD")
	var difficulty = -1
	if reward == 2:
		difficulty = 0
	elif reward == 8:
		difficulty = 1
	else:
		difficulty = 2
	new_wave.play()
	var waves = waveData[difficulty]
	if waves.size() <= wave + 1 : return
	var enemies = waves[wave+1]
	var nOfEnemies = enemies.size()
	
	if nOfEnemies > 0:
		disableExtendbuttons()
	wave_start.emit(wave+1)
	
	
	for miniwave in enemies:
		var enemy_name = miniwave[0]
		var ammount = miniwave[1]
		var delay = miniwave[2]
		
		for i in ammount:
			spawnEnemy(extension, randi() % extension.path.to.size(), enemy_name)
			await get_tree().create_timer(delay).timeout
		
	for chunk: Chunk in chunk_container.get_chunks():
		for structure in chunk.structs:
			if structure.dead: structure.respawn()
	for tower : Tower in get_node("/root/main/Towers").get_children():
		if tower is Worker: tower.thinking.emit()
	
	wave += 1
	if wave % 3 == 0: (get_node("/root/main/Player/") as Player).incrementCurrency(0, 0, 0, 1)

func disableExtendbuttons():
	for el in get_tree().get_nodes_in_group("wave_starters"):
		el.hide()

func toggleExtendButtons():
	for el in get_tree().get_nodes_in_group("wave_starters"):
		el.show()

func _ready() -> void:
	maxWaves = Configuration.read("GAME_DATA", "REWARD")
	if maxWaves == 2:
		maxWaves = 8
	elif maxWaves == 8:
		maxWaves = 15
	else:
		maxWaves = 20
	toggleExtendButtons()

func _on_enemies_child_exiting_tree(node: Node) -> void:
	if node is Enemy:
		if %Enemies.get_children().size() <= 1:
			wave_end.emit()
			
func _on_wave_end() -> void:
	toggleExtendButtons()
	if wave > maxWaves:
		var sp = Configuration.read("GAME_DATA", "SKILL_POINTS")
		Configuration.write("GAME_DATA", "SKILL_POINTS", sp + Configuration.read("GAME_DATA", "REWARD"))
		get_tree().change_scene_to_file("res://components/UI/game_won.tscn")
