extends BaseCharacter


func _init():
	
	Name = "Clyde"
	Class = "Archer"
	
	level = 5
	health = 300
	magic_points = 15
	strength = 35
	defense = 25
	magic = 15
	magic_defense = 15
	speed = 80
	luck = 20
	physical_evasion = 20
	magic_evasion = 20
	experience_points = 0
	ATB_Gauge = 0.0
	next_level_exp = 10
	current_health = 600
	current_mp = 30

func _ready():
	var double_shot = DoubleShot.new()
	var fire_shot = FireShot.new()
	Skill_list.push_back(double_shot)
	Skill_list.push_back(fire_shot)
	var short_sword = ShortSword.new()
	var mythril_armor = MythrilArmor.new()
	var featherd_cap = FeatheredCap.new()
	equip_weapon(short_sword)
	equip_armor(mythril_armor)
	equip_helm(featherd_cap)
	play_animation("idle")
