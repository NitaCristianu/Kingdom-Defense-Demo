class_name BookOfUpgrades extends Panel

# Called every frame. 'delta' is the elapsed time since the previous frame.delta

var closed_book = {}
var open_book = {}

@onready var pages: HBoxContainer = $pages
@onready var animator: AnimationComponent = $Animator
@onready var tower_name: RichTextLabel = $tower_name
@onready var tower_icon: Panel = $tower_icon
@onready var description: RichTextLabel = $description
@onready var upgrade_name: RichTextLabel = $upgradeName
@onready var close_button: Button = $close
@onready var price: RichTextLabel = $Price
@onready var reward: RichTextLabel = $Reward

var page = 1
var inspecting: Tower
var data : Dictionary

var isOpen : bool = false

func _ready():
	configBookStyle()
	handlePages()

func handlePages():
	for button : Button in pages.get_children():
		button.mouse_entered.connect(func() : switchPage(button.name.to_int()))
		button.pressed.connect(func() : processUpgrade(button.name.to_int()))

func processUpgrade(upgradeChoice: int):
	inspecting.levelUp(upgradeChoice-1)
	#page = 1
	loadTowerData(inspecting)

func switchPage(pageNum : int):
	page = pageNum
	loadTowerData(inspecting)

func configBookStyle() -> void:
	open_book = {
		"position:x" : func() : return get_node("/root/main/ingame_ui").size.x * .6,
		"rotation" : rotation,
		"modulate:a" : 1,
	}
	closed_book = {
		"position:x" : func(): return open_book.get("position:x").call() + 2000,
		"rotation" : open_book.get("rotation") + PI/4,
		"modulate:a" : 0,
	}
	for property in closed_book:
		var value = closed_book.get(property)
		if value is Callable: value = value.call()
		animator.add_tween(property, value, 0.01)

func getUpgradePrice(upgradeData : Dictionary) -> String:
	var s = "Price: \n"
	
	for item in ["wood", "stone", "gold", "mana"]:
		if upgradeData[item] > 0:
			s += str(upgradeData[item]) + " " + item + "\n"
	
	return s

func getRoundProcentage(old:float, new:float) -> String:
	var raw = new/old
	if old > new: raw = old / new
	raw = round(raw*10) / 10
	return str(int(raw*100)).substr(0, 3) + "%"

func getUpgradeDescription(upgradeData : Dictionary) -> String:
	var s = ""
	var raw = inspecting.getRawStats()
	for item: String in ["Strength", "Speed", "Range"]:
		var old: float = raw[item.to_lower()]
		var new: float = upgradeData[item]
		
		var add = "+"
		if item == "Speed" : add = "-"
		if new > old:
			s += "\n%s %s %s" % [add , getRoundProcentage(old, new), item] 
		elif new < old:
			add = "+" if add == "-" else "-"
			s += "\n%s %s %s" % [add , getRoundProcentage(old, new), item] 
			
	return s

func getUpgradeData(level : int, tier: int) -> Dictionary:
	var upgradesData : Array = data.get("Upgrades")
	if not upgradesData : return {}
	var levelChoices: int = data['Upgrade Choices']
	if tier >= floor(upgradesData.size() / levelChoices): return {}
	if upgradesData.size() <= level+tier*levelChoices: return {}
	return upgradesData[level+tier*levelChoices]

func findtowerIcon(isMaxed: bool = false) -> Texture2D:
	var upgradeData = getUpgradeData(inspecting.level if isMaxed else page-1, inspecting.tier-1 if isMaxed else inspecting.tier)
	var upgradeName = upgradeData["Upgrade Name"]
	return load("res://assets/Icons/upgrades/%s/%s.png" % [inspecting.tower_name, upgradeName])

func loadTowerData(tower: Tower):
	inspecting = tower
	data = Configuration.getData_absolute()['Entity']['Tower'][inspecting.tower_name]
	var maxed : bool = tower.tier >= floor(data["Upgrades"].size() / data["Upgrade Choices"])
	
	var style := StyleBoxTexture.new() # used for setting texture alter
	
	var upgradeData: Dictionary
	if not maxed:
		upgradeData = getUpgradeData(page-1, inspecting.tier)
		style.texture = findtowerIcon()
	else:
		upgradeData = getUpgradeData(inspecting.level, inspecting.tier-1)
		style.texture = findtowerIcon(true)
		
	tower_name.text = inspecting.tower_name
	description.text = upgradeData["Upgrade Description"]
	upgrade_name.text = upgradeData["Upgrade Name"]
	reward.text = getUpgradeDescription(upgradeData)
	price.text = getUpgradePrice(upgradeData)
	
	for btn in pages.get_children():
		if maxed or data["Upgrade Choices"] < btn.name.to_int(): btn.hide()
		else: btn.show()
		
	tower_icon.add_theme_stylebox_override("panel", style)

func open(tower: Tower) -> Tween:
	if isOpen: return null
	var tween: Tween
	isOpen = true
	
	loadTowerData(tower)
	
	for property in open_book:
		var value = open_book.get(property)
		tween = animator.add_tween(property, value, .4)
	return null

func close(tower:Tower = null) -> Tween:
	if not isOpen: return null
	var tween: Tween
	isOpen = false
	for property in closed_book:
		var value = closed_book.get(property)
		tween = animator.add_tween(property, value, .8)
	return tween
	
func _process(delta: float) -> void:
	pass

func _on_close_pressed() -> void:
	close()
