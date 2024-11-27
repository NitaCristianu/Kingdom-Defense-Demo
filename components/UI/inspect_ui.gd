extends Panel

@onready var upgradebuttons: HBoxContainer = $upgradebuttons
@onready var towername: Label = $towername
@onready var description: Label = $description
@onready var upgrade_title: Label = $"upgrade title"
@onready var _1: Button = $"upgradebuttons/1"
@onready var _2: Button = $"upgradebuttons/2"
@onready var _3: Button = $"upgradebuttons/3"
@onready var _4: Button = $"upgradebuttons/4"
@onready var _5: Button = $"upgradebuttons/5"

var mouse_on : bool = false
var data: Dictionary = {}
var tower : Tower
var option = 0

func inspect(_tower: Tower) -> void:
	tower = _tower
	towername.text = tower.display_name
	
	data = Configuration.getData_absolute()['Entity']['Tower'][tower.tower_name]
	var levelChoices: int = data['Upgrade Choices']
	var upgrades = data["Upgrades"]
	var i : int = 0
	var maxed : bool = tower.tier >= floor(upgrades.size() / levelChoices)
	
	if not maxed:
		for child in upgradebuttons.get_children():
			child.text = str(i+1)
			if i < levelChoices:
				var upgrade = upgrades[i+tower.tier*levelChoices]
				child.show()
				child.get_child(0).text = "%sg\n%sw\n%ss" % [upgrade.gold, upgrade.wood, upgrade.stone]
			else:
				child.hide()
			i+=1 
	else:
		upgrade_title.text = upgrades[tower.level+(tower.tier-1)*levelChoices]["Upgrade Name"]
		description.text = upgrades[tower.level+(tower.tier-1)*levelChoices]["Upgrade Description"]
		for child in upgradebuttons.get_children():
			child.hide()
		
	setOption(0)
	show()

func setOption(newOption : int):
	option = newOption
	var upgradesData : Array = data.get("Upgrades")
	if not upgradesData : return
	var levelChoices: int = data['Upgrade Choices']
	if tower.tier >= floor(upgradesData.size() / levelChoices): return

	var upgradeData : Dictionary = upgradesData[option+tower.tier*levelChoices]
	
	upgrade_title.text = upgradeData["Upgrade Name"]
	description.text = upgradeData["Upgrade Description"]

func levelUp(upgradeOption: int) -> bool:
	var player := Configuration.player
	var upgrades : Array = data['Upgrades']
	var levelChoices: int = data['Upgrade Choices']
	if upgradeOption >= levelChoices: return false

	var upgradeReq : Dictionary = upgrades[upgradeOption+tower.tier*levelChoices]
	
	if player.gold < upgradeReq.gold or player.wood < upgradeReq.wood or player.stone < upgradeReq.stone or player.mana < upgradeReq.mana:
		return false
		
	player.incrementCurrency(-upgradeReq.wood, -upgradeReq.stone, -upgradeReq.gold, -upgradeReq.mana)
	
	tower.levelUp(upgradeOption)
	setOption(0)
	
	return true

func uninspect(_tower: Tower) -> void:
	tower = _tower
	hide()
	for child in upgradebuttons.get_children():
		child.hide()

func _ready() -> void:
	hide()
	
	_1.mouse_entered.connect(func (): setOption(0))
	_2.mouse_entered.connect(func (): setOption(1))
	_3.mouse_entered.connect(func (): setOption(2))
	_4.mouse_entered.connect(func (): setOption(3))
	_5.mouse_entered.connect(func (): setOption(4))
	
	_1.button_up.connect(func (): levelUp(0))
	_2.button_up.connect(func (): levelUp(1))
	_3.button_up.connect(func (): levelUp(2))
	_4.button_up.connect(func (): levelUp(3))
	_5.button_up.connect(func (): levelUp(4))
