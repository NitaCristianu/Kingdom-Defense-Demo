extends Button

class_name SkillPoint

enum categories {tesla, inferno, energifier, strength, manaboost, speed}

@export var unlocked : bool = false
@export var cost: int = 1
@export var previous : SkillPoint
@export var description: String = "default stats"
@export var upgData : float = -1
@export var category :  categories = categories.strength
@onready var desc: Label = %desc
@onready var spcost: Label = $spcost

var newLine: Line2D

func unlock():
	unlocked = true
	var text = ResourceLoader.load("res://assets/levels/skillpoint_unlocked.png")
	spcost.hide()
	set_button_icon(text)

func tryUnlock():
	if unlocked: return
	if previous and not previous.unlocked: return
	var sp = Configuration.read("GAME_DATA", "SKILL_POINTS")
	
	if (sp >= cost):
		Configuration.write("GAME_DATA", "SKILL_POINTS", sp - cost)
		#Configuration.write("SKILLS", description, true)
		var skills : Dictionary = JSON.parse_string(Configuration.read("GAME_DATA", "SKILL_DATA"))
		skills[categories.find_key(category)] = upgData
		Configuration.write("GAME_DATA", "SKILL_DATA", JSON.stringify(skills))
		unlock()

func getPositions():
	var b = global_position + size/2
	var a = previous.global_position + previous.size/2
	return [a,b]

func scale_resize():
	pivot_offset = size / 2
	scale = (scale + scale + Vector2.ONE * 61 / size)/3

func ondragged():
	if not previous: return
	newLine.points = getPositions()

func onResize(newLine : Line2D):
	newLine.points = getPositions()
	scale_resize()

func drawLine():
	if not previous: return
	
	newLine = Line2D.new()
	newLine.name = str(randi()%100)
	newLine.points = getPositions()
	newLine.width = 1
	
	get_node("/root/").add_child(newLine)
	
	tree_exited.connect(func(): newLine.queue_free())
	resized.connect(func() : onResize(newLine))

func showDesc():
	desc.text = description
	desc.position = global_position + Vector2.UP * size / 2
	desc.show()

func _ready():
	
	var sk_data = Configuration.read("GAME_DATA", "SKILL_DATA")
	if sk_data and sk_data is String:
		var skills = JSON.parse_string(sk_data)
		if skills[categories.find_key(category)] >= upgData:
			unlocked = true
		
	if unlocked == true: unlock()
	else: self.pressed.connect(tryUnlock)
	self.mouse_entered.connect(showDesc)
	self.mouse_exited.connect(func(): desc.hide())
	
	spcost.text = str(cost)
	z_index = 2
	drawLine()
	scale_resize()
