extends BaseEnemy


func _init():
	Name = "Goblin"
	health = 120
	magic_points = 10
	strength = 60
	defense = 20
	magic = 0
	magic_defense = 0
	speed = 50
	luck = 15
	physical_evasion = 10
	magic_evasion = 20
	awarded_exp = 10
	
	var punch = Goblin_Punch.new()
	skill_list.push_back(punch)

func chose_action(action : BattleAction):
	var random_num = randi() % 101
	var damage = 0
	if random_num <= 90:
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
