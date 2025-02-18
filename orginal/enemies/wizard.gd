extends BaseEnemy

func _init():
	Name = "Wizard"
	health = 120
	magic_points = 20
	strength = 55
	defense = 15
	magic = 40
	magic_defense = 20
	speed = 40
	luck = 15
	physical_evasion = 5
	magic_evasion = 40
	awarded_exp = 10
	
	var fireball = Fire_Ball.new()
	skill_list.push_back(fireball)
	

func chose_action(action : BattleAction):
	var random_num = randi() % 101
	var damage = 0
	if random_num <= 40:
		damage += physical_attack_damage()
		damage += critChance()
		action.damage = damage
		action.type_of_attack = "physical"
		action.name = null
	else:
		var skill_used = choose_skill()
		if check_mp(skill_used):
			damage += skill_calc(skill_used)
			action.damage = damage
			action.type_of_attack = skill_used.type
			action.name = skill_used.Name
		else:
			action.damage = damage
			action.type_of_attack = "none"
			action.name = "not enought MP"
