extends BaseEnemy
## Creates a goblin enemy character

func _init() -> void:
	character_class = "Goblin"
	character_name = "Gobta"
	max_hp = 120
	max_mp = 10
	strength = 60
	defense = 0
	magic = 0
	magic_defense = 0
	speed = 50
	luck = 15
	physical_evasion = 0
	magic_evasion = 0
	awarded_exp = 10
	
	var punch: SkillBase = GoblinPunch.new()
	skill_list[punch.name] = punch


## AI for the character
func _chose_action() -> BattleAction:
	var action: BattleAction = BattleAction.new()
	var random_num: int = randi() % 101
	if random_num <= 90:
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
