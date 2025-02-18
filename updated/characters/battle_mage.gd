extends PlayerCharacter
## Creates the battle mage player character

func _init() -> void:
	character_name = "Blank"
	character_class = "Fighter"
	level = 5
	max_hp = 300
	max_mp = 30
	strength = 30
	defense = 25
	magic = 25
	magic_defense = 15
	speed = 70
	luck = 20
	physical_evasion = 20
	magic_evasion = 20
	experience_points = 0
	next_level_exp = 10
	current_hp = 300
	current_mp = 30

func _ready() -> void:
	var skill_1: SkillBase = DoublePunch.new()
	var skill_2: SkillBase = FireBall.new()
	skill_list[skill_1.name] = skill_1
	skill_list[skill_2.name] = skill_2
	var short_sword: BaseWeapon = ShortSword.new()
	var mythril_armor: BaseArmor = MythrilArmor.new()
	var featherd_cap: BaseHelm = FeatheredCap.new()
	equip_weapon(short_sword)
	equip_armor(mythril_armor)
	equip_helm(featherd_cap)
	play_animation("idle")
