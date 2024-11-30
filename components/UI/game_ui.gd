class_name gameUI extends Control

signal enterbuildmode(selected: String)
signal book_closed

@onready var woodLabel: Label = $resource1/wood/Label
@onready var stoneLabel: Label = $resource1/stone/Label
@onready var goldLabel: Label = $resource2/gold/Label
@onready var manaLabel: Label = $resource2/mana/Label
@onready var enemy_data: EnemyDataClass = $EnemyData
@onready var tower_collection: TowerCollectionContainer = $towerCollection
@onready var book: BookOfUpgrades = $Book
@onready var wave_allert: Label = $WaveAllert

var initial_resources = {'wood' : 0, 'stone' : 0, 'gold' : 0, 'mana' : 0}

func hideEnemyData():
	enemy_data.dissapear()

func showEnemy(enemy : Enemy):
	enemy_data.pop(enemy)

func updateCurrency(wood : int, stone : int, gold : int, mana : int) -> void:
	setWood(wood)
	setStone(stone)
	setGold(gold)
	setMana(mana)

func setWood(num : int):
	if not is_instance_valid(woodLabel):
		initial_resources["wood"] = num
	else:	
		woodLabel.text = str(num)

func setStone(num : int):
	if not is_instance_valid(stoneLabel):
		initial_resources["stone"] = num
	else:	
		stoneLabel.text = str(num)

func setGold(num : int):
	if not is_instance_valid(goldLabel):
		initial_resources["gold"] = num
	else:	
		goldLabel.text = str(num)
		
func setMana(num : int):
	if not is_instance_valid(manaLabel):
		initial_resources["mana"] = num
	else:	
		manaLabel.text = str(num)

func _ready() -> void:
	setWood(initial_resources['wood'])
	setStone(initial_resources['stone'])
	setGold(initial_resources['gold'])
	setMana(initial_resources['mana'])
	
func hide_buttons():
	pass

func show_buttons():
	tower_collection.stop_selection()

func inspect(tower : Tower):
	#inspect_ui.inspect(tower)
	book.open(tower)
	
func uninspect(tower : Tower):
	#inspect_ui.uninspect(tower)
	book.close(tower)

func _on_tower_collection_selected(selected: String) -> void:
	enterbuildmode.emit(selected)

func _on_wave_wave_start(waveNum: int) -> void:
	wave_allert.allert(waveNum)

@onready var healthbar: Panel = $healthbar
func _on_wave_base_damaged(hp: int) -> void:
	if hp > 0 and hp <= 8:
		healthbar.setImage(hp)
