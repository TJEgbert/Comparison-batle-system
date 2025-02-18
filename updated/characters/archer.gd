extends PlayerCharacter
## Creates the archer player character

func _init() -> void:
	
	character_name = "Clyde"
	character_class = "Archer"
	
	level = 5
	max_hp = 350
	max_mp = 15
	strength = 35
	defense = 25
	magic = 15
	magic_defense = 15
	speed = 80
	luck = 20
	physical_evasion = 20
	magic_evasion = 20
	experience_points = 0
	next_level_exp = 10
	current_hp = 350
	current_mp = 15

func _ready() -> void:
	var double_shot: SkillBase = DoubleShot.new()
	var fire_shot: SkillBase = FireShot.new()
	skill_list[double_shot.name] = double_shot
	skill_list[fire_shot.name] = fire_shot
	var short_sword: BaseWeapon = ShortSword.new()
	var mythril_armor: BaseArmor = MythrilArmor.new()
	var featherd_cap: BaseHelm = FeatheredCap.new()
	equip_weapon(short_sword)
	equip_armor(mythril_armor)
	equip_helm(featherd_cap)
	play_animation("idle")
