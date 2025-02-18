extends Node2D

# Section List
# S1 Functionality related
# -- S1.1 Control related
# -- S1.2 Battle outcome related
# S2 Attack Command related
# S3 Defend Command related
# S4 Skill Command related
# S5 Item Command related
# S6 Enemy Code


## currently working on
## make one full areas
	## Create more enimies
	## Create Characters  ---- both in code and in working documents
	## Create Skills  ----- both in code and working documents
	## Balance game mechainces!!!


## To Do
## A lot more UI for the battle menu
## Create more enimies

## Refine need to fully impllement later To Do
## balancing mechanics
## implements items and mechanics
## 	22 HP and MP Healing
## 	23 Status healing
## 	24 Buff
## Create more equipment and items
## Over world movement system
## Leveling up system
## How to spawn enemies ---- each area of maps have an array of possible enemy array counters?

var selected_target 
var active_party_member
var skill_button
var current_button
var used_skill
var skill_list
var used_item

var menu_state = false
var attack_state = false
var skill_menu_state = false
var defend_state = false
var selected_state = false
var skill_selected_state = false
var item_menu_state = false
var item_selected_state = false
var party_member_ready = false
var cancle_clicked = false
var multi_target_state = false

var party_group_select = false
var enemy_group_select = false

var possible_exp = 0

var enemy_party = [] 
var targetable_player_team = []
var qued_actions = []
var player_party = []
var enemies = []

@onready var controls = $controls.get_children()
@onready var player_health = $player_1_health/hp_label
@onready var player2_health = $player_2_health/hp_label
@onready var party = PlayerParty.get_party()

@onready var player_mp = $player_1_health/MP
@onready var player2_mp = $player_2_health/MP

@onready var party_node = $Party
@onready var skill_menu = $Skills
@onready var item_menu = $Items
@onready var player_que = []
@onready var enemy_container = $Enemies
@onready var skill_name_display = $name_of_skill
@onready var enemy_marker = $enemy_markers.get_children()
@onready var party_marker = $party_markers.get_children()


signal battle_won


# ------------------- S1 Functionality related ---------------------------------
func _ready():
	load_party()
	player_health.text = String.num_int64(player_party[0].current_health)
	player2_health.text = String.num_int64(player_party[1].current_health)
	player_mp.text = String.num_int64(player_party[0].current_mp)
	player2_mp.text = String.num_int64(player_party[1].current_mp)
	
	enemies = EnemyList.get_enemy_party()
	for enemy in enemies:
		enemy_container.add_child(enemy)
	enemy_party = enemy_container.get_children()
	load_enemies()
	for member in player_party:
		if member.alive():
			targetable_player_team.push_back(member)
		

func load_party():
	var index = 0
	for member in party:
		member.array_order = index
		party_node.add_child(member)
		member.position.x = 1000
		member.battle_start()
		member.global_position = party_marker[index].global_position
		index += 1
		member.death.connect(_on_charaters_death.bind(member))
		member.hp_changed.connect(_on_charaters_hp_changed.bind(member))
		member.mp_changed.connect(_on_charaters_mp_changed.bind(member))
		member.ready_for_action.connect(_on_charaters_ready_for_action.bind(member))
	player_party = party_node.get_children()
	
			
func _on_charaters_hp_changed(character):
	var character_num = character.array_order
	match character_num:
		0:
			player_health.text = String.num_int64(character.current_health)
		1:
			player2_health.text = String.num_int64(character.current_health)
		2:
			pass
		3:
			pass		

	
	
func _on_charaters_mp_changed(character):
	var character_num = character.array_order
	match character_num:
		0:
			player_mp.text = String.num_int64(character.current_mp)
		1:
			player2_mp.text = String.num_int64(character.current_mp)
		2:
			pass
		3:
			pass

	
func add_to_que(attacker, type, target, damage, skill_name, multi_targerted):
	var action = BattleAction.new()
	action.attacker = attacker
	action.type_of_attack = type
	action.whos_being_attacked = target
	action.damage = damage
	action.name = skill_name
	action.multi_target = multi_targerted
	qued_actions.push_back(action)
	
func _process(delta):
	if !qued_actions.is_empty():
		next_action()
	
func _input(event):
	if party_member_ready:
		if event.is_action_pressed("Down"):
			if selected_state:
				selected_target = get_next_target("Down")
		elif event.is_action_pressed("Up"):
			if selected_state:
				selected_target = get_next_target("Up")
		elif event.is_action("Right"):
			if selected_state:
				if party_group_select:
					group_select(selected_target, "Right")
				elif enemy_group_select:
					selected_target.beenSelected()
					enemy_group_select = false
					multi_target_state = false
				else:
					switch_target_party(selected_target, "Right")
		elif event.is_action("Left"):
			if selected_state:
				if enemy_group_select:
					group_select(selected_target, "Left")
				elif party_group_select:
					selected_target.beenSelected()
					party_group_select = false
					multi_target_state = false
				else:
					switch_target_party(selected_target, "Left")
					
		elif event.is_action_pressed("Confirm"):
			if skill_selected_state:
				skill_used()
				menu_state = true
				selected_state = false
				remove_selection()
				turn_over(active_party_member)
			elif defend_state:
				defense_boost()
				menu_state = true
				defend_state = false
				active_party_member.beenUnselected()
				active_party_member.atb_reset()
				turn_over(active_party_member)
			elif attack_state:
				player_basic_attack()
				menu_state = true
				selected_state = false
				remove_selection()
				turn_over(active_party_member)
			elif item_selected_state:
				use_item()
				menu_state = true
				selected_state = false
				remove_selection()
				turn_over(active_party_member)
				
				
		elif event.is_action_pressed("Cancle"):
			# item menu state well also go here
			if skill_menu_state:
				skill_menu_state = false
				skill_menu.visible = false
				main_battle_menu()
				cancle_clicked = true	
				
			elif defend_state:
				defend_state = false
				main_battle_menu()
				cancle_clicked = true
				
			elif selected_state:
				if skill_selected_state:
					_on_skill_pressed()
					selected_state = false
				elif attack_state:
					main_battle_menu()
					attack_state = false
				elif item_selected_state:
					_on_item_pressed()
					item_selected_state = false
					selected_state = false	
				remove_selection()
				selected_state = false
				
			elif item_menu_state:
				item_menu_state = false
				item_menu.visible = false
				main_battle_menu()
				cancle_clicked = true
				
			else:
				switch_current_active_player() # end up in an else
				
				
func get_inital_enemy():
	selected_target = enemy_party[0]
	selected_target.beenSelected()
	enemy_group_select = true
	return selected_target

func get_inital_player():
	selected_target = active_party_member
	party_group_select = true
	selected_target.beenSelected()
	return selected_target

func get_next_target(direction):
	selected_target.beenUnselected()
	var next_target_index = 0
	var targeted_party 
	if selected_target is BaseCharacter:
		targeted_party = targetable_player_team
		next_target_index = targeted_party.find(selected_target)
	else:
		targeted_party = enemy_party
		next_target_index = targeted_party.find(selected_target)
	match direction:
		"Up":
			next_target_index -= 1
		"Down":
			next_target_index += 1
	if next_target_index < 0:
		selected_target = targeted_party.back()
	elif next_target_index == targeted_party.size():
		selected_target = targeted_party.front()
	else:
		selected_target = targeted_party[next_target_index]
	selected_target.beenSelected()
	return selected_target
	
func switch_target_party(target, direction):
	target.beenUnselected()
	if target is BaseCharacter && direction == "Left":
		get_inital_enemy()
		enemy_group_select = true
	elif target is BaseEnemy && direction == "Right":
		get_inital_player()
		party_group_select = true
	
func group_select(target, direction):
	multi_target_state = true
	if target is BaseCharacter && direction == "Right" && skill_selected_state:
		if used_skill.get_multi_castable():
			for party_member in targetable_player_team:
				party_member.beenSelected()
	elif target is BaseEnemy && direction == "Left" && skill_selected_state:
		if used_skill.get_multi_castable():
			for enemy in enemy_party:
				enemy.beenSelected()
	
func get_next_menu_button(button, direction):
	var next_button_index
	if menu_state:
		next_button_index = controls.find(button)
	elif skill_menu_state:
		next_button_index = skill_list.find(button)
	match direction:
		"Up":
			next_button_index -= 1
		"Down":
			next_button_index += 1
	if next_button_index < 0:
		if menu_state:
			current_button = controls.back()
		elif skill_menu_state:
			current_button = skill_list.back()
	elif next_button_index == controls.size():
		if menu_state:
			current_button = controls.front()
		elif skill_menu_state:
			current_button = skill_list.front()
	else:
		if menu_state:
			current_button = controls[next_button_index]
		elif skill_menu_state:
			current_button = skill_list[next_button_index]
	current_button.grab_focus()
	
func switch_current_active_player():
	if !player_que.is_empty():
		active_party_member.beenUnselected()
		player_que.push_back(active_party_member)
		active_party_member = player_que.pop_front()
		for skill in $Skills.get_children():
			$Skills.remove_child(skill)
			skill.free()
		$controls.visible = false
		await get_tree().create_timer(.2).timeout
		turn_start()
		
func was_cancled_selected():#--------------------------------Problay remove later
	if cancle_clicked:
		cancle_clicked = false

func _on_charaters_ready_for_action(character):
	if party_member_ready:
		player_que.push_back(character)
	else:
		active_party_member = character
		turn_start()
				
func main_battle_menu():
	menu_state = true
	$controls.visible = true
	controls[0].grab_focus()
	current_button = controls[0]

func remove_selection():
	selected_target.beenUnselected()
	
func next_action():
	var action = qued_actions.pop_front()
	var attacker = action.attacker
	if attacker.is_in_group("player"):
		attacker.play_animation("base_attack")
	var being_attacked = action.whos_being_attacked
	if action.name != null:
		skill_name_display.text = action.name
		skill_name_display.visible = true
		await get_tree().create_timer(1).timeout
		skill_name_display.visible = false
		skill_name_display.text = ""
	if action.type_of_attack == "defend":
		attacker.activate_defense_boost()
	elif action.type_of_attack == "item":
		being_attacked.use_item(used_item)
	elif being_attacked is BaseCharacter:
		if action.multi_target:
			if action.type_of_attack != "healing":
				for member in targetable_player_team:
					member.incoming_attack(action.type_of_attack, action.damage)
			else:
				var healing = 0;
				for member in targetable_player_team:
					healing = member.health * action.damage;
					member.incoming_attack(action.type_of_attack, healing)
		else:
			if action.type_of_attack != "healing":
				being_attacked.incoming_attack(action.type_of_attack, action.damage)
			else:
				var healing = being_attacked.health * action.damage
				being_attacked.incoming_attack(action.type_of_attack, healing)
		print("an enemy action is happening")
	elif being_attacked is BaseEnemy:
		if action.multi_target:
			if action.type_of_attack != "healing":
				for enemy in enemy_party:
					enemy.incoming_attack(action.type_of_attack, action.damage)
			else:
				var healing = 0;
				for enemy in enemy_party:
					healing = enemy.health * action.damage;
					enemy.incoming_attack(action.type_of_attack, healing)
		else:
			if action.type_of_attack != "healing":
				being_attacked.incoming_attack(action.type_of_attack, action.damage)
			else:
				var healing = being_attacked.health * action.damage
				being_attacked.incoming_attack(action.type_of_attack, healing)
		print("a player action is happening")
	attacker.atb_reset()
	attacker.waiting_for_action = false

# ------------ S1.2 Turn related --------------		
func turn_start():
		party_member_ready = true
		$controls.visible = true
		menu_state = true
		active_party_member.check_defense_boost()
		active_party_member.beenSelected()
		current_button = controls[0]
		current_button.grab_focus()
		load_skills()
		load_items()
	
func turn_over(player : BaseCharacter):
	attack_state = false
	skill_menu_state = false
	selected_state = false
	defend_state = false
	skill_selected_state = false
	menu_state = false
	party_member_ready = false
	party_group_select = false
	enemy_group_select = false
	multi_target_state = false
	
	item_menu_state = false
	item_selected_state = false
	
	player.beenUnselected()
	$controls.visible = false
	for enemy in enemy_party:
		enemy.beenUnselected()
	if player_que.find(player):
		player_que.erase(player)
	for skill in $Skills.get_children():
		$Skills.remove_child(skill)
		skill.free()
	for item in $Items.get_children():
		$Items.remove_child(item)
	if !player_que.is_empty():
		active_party_member = player_que.pop_front()
		await get_tree().create_timer(1).timeout
		turn_start()
		
# ------------ S1.3 Battle outcome related --------------		
func win():
	if enemy_party.is_empty():
		var counter = 0
		var alive_members = []
		for member in player_party:
			member.battle_over()
			if member.health != 0:
				alive_members.push_back(member)
				counter += 1
		var exp_gainded = (possible_exp / counter)
		for member in alive_members:
			member.addEXP(exp_gainded)
		victory_screen()
			
func victory_screen():
	qued_actions.clear()
	turn_over(active_party_member)
	$controls.visible = false
	$player_1_health.visible = false
	$player_2_health.visible = false
	$Skills.visible = false
	attack_state = false
	skill_menu_state = false
	selected_state = false
	defend_state = false
	skill_selected_state = false
	menu_state = false
	party_member_ready = false
	$Victory.visible = true
	for member in party_node.get_children():
		party_node.remove_child(member)
	OverworldStatus.battle_won()
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://Scenes/over_world_test.tscn")
	
	
func game_over():
	if targetable_player_team.size() == 0:
		qued_actions.clear()
		for enemy in enemy_party:
			enemy.set_game_over()
			$Game_over.visible = true
		for member in player_party:
			member.battle_over()
			
func _on_charaters_death(character):
	targetable_player_team.erase(character)
	game_over()

# ------------------- S2 Attack Command related --------------------------------
func _on_attack_pressed():
	selected_state = true
	attack_state = true
	get_inital_enemy()
	$controls.visible = false
	menu_state = false
	
func player_basic_attack():
	var attacker = active_party_member
	var damage = active_party_member.physical_attack_damage()
	damage += active_party_member.critChance()
	attacker.waiting_for_action = true
	add_to_que(attacker, "physical", selected_target, damage, null, false)
	
#-------------------- S3 Defend Command related --------------------------------
func _on_defend_pressed():
	$controls.visible = false
	active_party_member.beenSelected()
	defend_state = true

func defense_boost():
	active_party_member.activate_defense_boost()
	active_party_member.beenUnselected()
	
	
func defend_action():
	var attacker = active_party_member
	var damage = 0
	attacker.waiting_for_action = true
	add_to_que(attacker, "defend", selected_target, damage, null, false)
	
#-------------------- S4 Skill Command related ---------------------------------
func _on_skill_pressed():
	$controls.visible = false
	skill_menu.visible = true
	skill_menu_state = true
	menu_state = false
	skill_list[0].grab_focus()
	current_button = skill_list[0]
	
func load_skills():
	for skill in active_party_member.Skill_list:
		var skill_node = Button.new()
		skill_node.text = skill.Name
		skill_menu.add_child(skill_node)
		skill_node.pressed.connect(_on_skill_node_pressed.bind(skill))
	skill_list = skill_menu.get_children()


func _on_skill_node_pressed(skill):
	if active_party_member.check_mp(skill):
		selected_state = true
		skill_selected_state = true
		used_skill = skill
		skill_menu_state = false
		skill_menu.visible = false
		if skill.type != "healing":
			get_inital_enemy()
		else:
			get_inital_player()
	# else play error noise and not enough mp
	
func skill_attack():
	var attacker = active_party_member
	var damage = 0
	damage = active_party_member.skill_calc(used_skill)
	attacker.waiting_for_action = true
	add_to_que(attacker, used_skill.type, selected_target, damage, used_skill.Name, false)
	
func skill_used():
	var attacker = active_party_member
	var damage = 0
	var num_selected = 0
	attacker.waiting_for_action = true
	if multi_target_state:
		if selected_target is BaseCharacter:
			num_selected = targetable_player_team.size()
			for party_member in targetable_player_team:
				party_member.beenSelected()
		else:
			num_selected = enemy_party.size()
			for enemy in enemy_party:
				enemy.beenSelected()
		damage = active_party_member.skill_calc(used_skill, num_selected)
		add_to_que(attacker, used_skill.type, selected_target, damage, used_skill.Name, true)
	else:
		damage = active_party_member.skill_calc(used_skill, 1)
		add_to_que(attacker, used_skill.type, selected_target, damage, used_skill.Name, false)

#-------------------- S5 Item Command related ----------------------------------
func _on_item_pressed():
	$controls.visible = false
	item_menu.visible = true
	item_menu_state = true
	menu_state = false
	var items = item_menu.get_children()
	if !items.is_empty():
		items[0].grab_focus()

func load_items():
	var contents = Inventory.get_inventory()
	for item in contents:
		var item_button = Button.new()
		var item_text = (item.name + " x" +String.num_int64(contents[item]))
		item_button.text = item_text
		item_button.pressed.connect(_on_item_node_pressed.bind(item))
		item_menu.add_child(item_button)
		
func _on_item_node_pressed(item):
	selected_state = true
	item_menu.visible = false
	item_selected_state = true
	used_item = item
	if item.type < 25:
		get_inital_player()
	else:
		get_inital_enemy()

func use_item():
	Inventory.use_item(used_item)
	var attacker = active_party_member
	var damage = 0
	if used_item.get_type()== 20:
		damage = used_item.healing
	elif used_item.get_type() == 25:
		damage = used_item.damage
	add_to_que(attacker, "item", selected_target, damage, used_item.get_name(), false)
	

#-------------------- S6 Enemy Code --------------------------------------------

func load_enemies():
	var counter = 0
	for enemy in enemy_party:
		enemy.ready_to_attack.connect(_on_enemy_base_ready_to_attack)
		enemy.death.connect(_on_enemy_base_death)
		possible_exp += enemy.awarded_exp
		enemy.global_position = enemy_marker[counter].global_position 
		counter += 1
		

func _on_enemy_base_ready_to_attack(enemy):
	if !targetable_player_team.is_empty():
		var action = BattleAction.new()
		action.attacker = enemy
		var attacking_number = randi() % targetable_player_team.size()
		# print("Player being attack: " + String.num_int64(attacking_number))
		action.whos_being_attacked = targetable_player_team [attacking_number]
		enemy.chose_action(action)
		qued_actions.push_back(action)
	
func _on_enemy_base_death(enemy):
	enemy_party.erase(enemy)
	win()
