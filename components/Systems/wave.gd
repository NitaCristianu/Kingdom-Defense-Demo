extends Node3D

class_name WaveHandler

@onready var chunk_container: ChunkContainerClass = $"../ChunkContainer"
@onready var enemies: Node3D = $"../Enemies"

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
	else:
		enemy_class= preload("res://components/Enemies/enemy.tscn")
		
	var enemy = enemy_class.instantiate()
	var data := getEnemyData(enemyName)
	
	enemy.health = data.Health
	enemy.maxhealth = enemy.health
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
	var nOfEnemies = 4; # number of eneies
	
	if nOfEnemies > 0:
		disableExtendbuttons()
	wave_start.emit(wave+1)
	
	for i in nOfEnemies:
		spawnEnemy(extension, randi() % extension.path.to.size(), "r6")
		await get_tree().create_timer(.2).timeout
		
	for chunk: Chunk in chunk_container.get_chunks():
		for structure in chunk.structs:
			if structure.dead: structure.respawn()
	for tower : Tower in get_node("/root/main/Towers").get_children():
		if tower is Worker: tower.thinking.emit()
	
	wave += 1
	if wave % 3 == 0: (get_node("/root/main/Player") as Player).incrementCurrency(0, 0, 0, 1)

func disableExtendbuttons():
	for el in get_tree().get_nodes_in_group("wave_starters"):
		el.hide()

func toggleExtendButtons():
	for el in get_tree().get_nodes_in_group("wave_starters"):
		el.show()

func _ready() -> void:
	maxWaves = Configuration.read("GAME_DATA", "REWARD")
	if maxWaves == 2:
		maxWaves = 10
	elif maxWaves == 8:
		maxWaves = 25
	else:
		maxWaves = 35
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
