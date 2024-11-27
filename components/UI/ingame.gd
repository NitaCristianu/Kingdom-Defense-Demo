extends Control

class_name inGameUI

@onready var wood: Label = $Panel/Wood
@onready var stone: Label = $Panel/Stone
@onready var gold: Label = $Panel/Gold
@onready var mana: Label = $Panel/Mana
@onready var workerButton: Button = $Panel/SpawnWorker
@onready var crossbowButton: Button = $Panel/SpawnCrossbow
@onready var inspect_ui: Panel = $inspect_ui

signal enterbuildmode

func updateCurrency(wood : int, stone : int, gold : int, mana : int) -> void:
	setWood(wood)
	setStone(stone)
	setGold(gold)
	setMana(mana)

func setWood(num : int):
	wood.text = "Wood %s" % str(num)

func setStone(num : int):
	stone.text = "Stone %s" % str(num)

func setGold(num : int):
	gold.text = "Gold %s" % str(num)
		
func setMana(num : int):
	mana.text = "Mana %s" % str(num)

func hide_buttons():
	workerButton.hide()
	crossbowButton.hide()

func show_buttons():
	workerButton.show()
	crossbowButton.show()

func _on_spawn_tesla_pressed() -> void:
	enterbuildmode.emit("tesla")

func _on_spawn_worker_pressed() -> void:
	enterbuildmode.emit("worker")

func _on_spawn_crossbow_pressed() -> void:
	enterbuildmode.emit("crossbow")

func inspect(tower : Tower):
	inspect_ui.inspect(tower)
	
func uninspect(tower : Tower):
	inspect_ui.uninspect(tower)
