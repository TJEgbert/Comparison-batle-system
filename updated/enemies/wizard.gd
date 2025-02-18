extends BaseEnemy
## Creates a wizard enemy character

func _init() -> void:
	character_class = "Wizard"
	character_name = "Jim"
	max_hp = 120
	max_mp = 20
	strength = 55
	defense = 0
	magic = 40
	magic_defense = 0
	speed = 40
	luck = 15
	physical_evasion = 0
	magic_evasion = 0
	awarded_exp = 10
	
	var fireball: SkillBase = FireBall.new()
	skill_list[fireball.name] = fireball
	
## AI for the character
func _chose_action() -> BattleAction:
	var action: BattleAction = BattleAction.new()
	var random_num: int = randi() % 101
	if random_num <= 40:
		action.type_of_action = "basic attack"
		action.name = ""
	else:
		var skill_used: SkillBase = choose_skill()
		if check_mp(skill_used):
			action.type_of_action = "skill"
			action.name = skill_used.name
		else:
			action.type_of_action = "none"
			action.name = "not enought MP"
	return action
