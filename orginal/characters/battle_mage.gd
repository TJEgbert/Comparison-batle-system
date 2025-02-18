extends BaseCharacter

func _init():
	Name = "Blank"
	Class = "Fighter"
	level = 5
	health = 600
	magic_points = 30
	strength = 30
	defense = 25
	magic = 25
	magic_defense = 15
	speed = 70
	luck = 20
	physical_evasion = 20
	magic_evasion = 20
	experience_points = 0
	ATB_Gauge = 0.0
	next_level_exp = 10
	current_health = 600
	current_mp = 30

func _ready():
	var skill_1 = Double_Punch.new()
	var skill_2 = Fire_Ball.new()
	Skill_list.push_back(skill_1)
	Skill_list.push_back(skill_2)
	var short_sword = ShortSword.new()
	var mythril_armor = MythrilArmor.new()
	var featherd_cap = FeatheredCap.new()
	equip_weapon(short_sword)
	equip_armor(mythril_armor)
	equip_helm(featherd_cap)
	play_animation("idle")
