extends Node2D
class_name BattleField

# Section List
# S1 Functionality related
# -- S1.1 Control related
# -- S1.2 Battle outcome related
# S2 Attack Command related
# S3 Defend Command related
# S4 Skill Command related
# S5 Item Command related
# S6 Enemy Code


# currently working on
# make one full areas
	## Create more enimies
	## Create Characters  ---- both in code and in working documents
	## Create Skills  ----- both in code and working documents
	## Balance game mechainces!!!


# TODO
# A lot more UI for the battle menu
# Create more enimies
# Fix confirm for controller input
# Add a background to the battle message
# Add crit chance into battles

# Refine need to fully impllement later To Do
# balancing mechanics
# implements items and mechanics
# 	22 HP and MP Healing
# 	23 Status healing
# 	24 Buff
# Create more equipment and items
# Over world movement system
# Leveling up system
# How to spawn enemies ---- each area of maps have an array of possible enemy array counters?

#region Attributes
## The currently selected target
var selected_target: CharacterBase
## The current active party member
var active_party_member: CharacterBase
## The selected skill to be used
var used_skill: SkillBase
## The selected item to be used
var used_item: BaseItem
## The current selected button
var current_button: Button # might remove later
## Tracks the current menu
var current_menu: String = "main menu"

## Tracks if there is a party member ready for a turn
var party_member_ready: bool = false
## Tracks if the player is currently selected a target
var selected_state: bool = false
## Tracks the attack state
var attack_state: bool = false
## Track the defend state
var defend_state: bool = false
## Tracks if the pllayer is in the skill menu
var skill_menu_state: bool = false
## Tracks if the player is selecting an enemy from the skill menu
var skill_selected_state: bool = false
## Tracks if the player has multitartgetted a group
var multitargetted: bool = false
## Tracks if the battle is over or not
var battle_over: bool = false

## Holds the possible exp gain for the players party
var possible_exp: int = 0

## The list of skill for the active party member
var skill_list: Array = []
## Holds the whole player party
var player_party: Array = []
## Holds the whole enemy party
var enemies: Array = []
## Holds living enemy party
var enemy_party: Array = []
## Holds living player party
var targetable_player_team: Array = []
## Holds qued actions
var qued_actions: Array = []
## Holds the player character that have a turn ready
var player_que: Array = []
## Holds all living characters with there atb gauge
var atb_tracker: Dictionary = {}

## Holds the whole plays party
@onready var party: Array = PlayerParty.get_party()
## Holds all the buttons for main menu
@onready var controls: Array = $controls.get_children()
## Used to display the character 1 current hp
@onready var player_health: Label = $player_1_health/hp_label # TODO come up with a better way
## Used to display the character 2 current hp
@onready var player2_health: Label = $player_2_health/hp_label # TODO come up with a better way
## Used to display the character 1 current mp
@onready var player_mp: Label = $player_1_health/MP
## Used to display the character 2 current mp
@onready var player2_mp: Label = $player_2_health/MP
## The node that the player party will be put into
@onready var party_node:  = $Party
## Holds the skills for the skill menu
@onready var skill_menu: VBoxContainer = $Skills
## Holds the items for the item menu
@onready var item_menu: VBoxContainer = $Items
## The node that holds the enemy party
@onready var enemy_container: Node = $Enemies
## The label used to display battle message at the top of the screen
@onready var battle_message_display: Label = $battle_message
## The markers used to place the enemy party on the field
@onready var enemy_marker: Array = $enemy_markers.get_children()
## The markers used to place the players party on the field
@onready var party_marker: Array = $party_markers.get_children()
#endregion


#region Functionality functions
## Load the players and enemy parties
func _ready() -> void:
	# Loads the player party
	load_party()
	
	# Set the onscreen hp and mp stats TODO come up with a better method
	player_health.text = String.num_int64(player_party[0].get_current_hp())
	player2_health.text = String.num_int64(player_party[1].get_current_hp())
	player_mp.text = String.num_int64(player_party[0].get_current_mp())
	player2_mp.text = String.num_int64(player_party[1].get_current_mp())
	
	# Loads the enemy party
	enemies = EnemyList.get_enemy_party()
	for enemy: BaseEnemy in enemies:
		enemy_container.add_child(enemy)
		# sets the enemies atb gauge
		atb_tracker[enemy] = (randi() % enemy.get_speed_stat())
	enemy_party = enemy_container.get_children()
	load_enemies()
	
	# Set the atb gauge for living charaters
	for member: PlayerCharacter in player_party:
		if member.alive():
			targetable_player_team.push_back(member)
			atb_tracker[member] = (randi() % member.get_speed_stat())
		

## Loads the players party into the active screen
func load_party() -> void: #TODO come up with a better way 
	var index: int = 0
	for member: PlayerCharacter in party:
		# Saves the order of the character in the array
		member.array_order = index
		# Adds the character to the party node
		party_node.add_child(member)
		# Relocates the caracter the battle map
		member.position.x = 1000
		member.global_position = party_marker[index].global_position
		index += 1
		# Connects the characters signal to the field
		member.death.connect(_on_charaters_death.bind(member))
		member.hp_changed.connect(_on_charaters_hp_changed.bind(member))
		member.mp_changed.connect(_on_charaters_mp_changed.bind(member))
	# Saves the child node to the player_party
	player_party = party_node.get_children()
	

## Updates the player hp text on the screen		
func _on_charaters_hp_changed(character: CharacterBase) -> void:
	var character_num: int = character.array_order
	match character_num:
		0:
			player_health.text = String.num_int64(character.get_current_hp())
		1:
			player2_health.text = String.num_int64(character.get_current_hp())
		2:
			pass
		3:
			pass		

	
##	Updates the player mp text on the screen	
func _on_charaters_mp_changed(character: CharacterBase) -> void:
	var character_num: int = character.array_order
	match character_num:
		0:
			player_mp.text = String.num_int64(character.get_current_mp())
		1:
			player2_mp.text = String.num_int64(character.get_current_mp())
		2:
			pass
		3:
			pass


## Creates an action and adds it to the battle que	
func add_to_que(actioneer: CharacterBase, type: String, target: CharacterBase, 
		skill_name: String, multi_targerted: bool) -> void:
	var action: BattleAction = BattleAction.new()
	action.actioneer = actioneer
	action.type_of_action = type
	action.whos_being_attacked = target
	action.name = skill_name
	action.multi_target = multi_targerted
	if current_menu == "item menu":
		action.item = used_item
	qued_actions.push_back(action)
	
	
## Runs every frame
func _process(delta: float) -> void:
	# If there's any action in que
	if !qued_actions.is_empty():
		next_action()
	# If battle not over
	if !battle_over:
		# How much gets added to the atb gauage
		var atb: float = (delta * 9)
		# Add to the enemies atb gauge
		for enemy: BaseEnemy in enemy_party:
			atb_tracker[enemy] += atb
			# If the enemies atb gauge is full
			if atb_tracker[enemy] >= 100:
				# Enemy starts action
				enemy_base_ready_to_attack(enemy)
				enemy.active = true
		# Adds to the player characters atb gauge
		for player: PlayerCharacter in targetable_player_team:
			atb_tracker[player] += atb
			# When the player character atb is full and not active
			if atb_tracker[player] >= 100 && !player.active:
				# Get the character ready for action for the player
				charaters_ready_for_action(player)
				player.active = true


## Handles the players input	
func _input(event: InputEvent) -> void:
	# There is a character ready
	if party_member_ready:
		# If any of the down buttons are pressed
		if event.is_action_pressed("Down"):
			# If in select get the next target down
			if selected_state:
				selected_target = get_next_target("Down")
				
		# If any of the up buttons are pressed		
		elif event.is_action_pressed("Up"):
			# If in select get the next target up
			if selected_state:
				selected_target = get_next_target("Up")
				
		# If any of the left buttons are pressed		
		elif event.is_action_pressed("Left"):
			# If the selected target is a player character
			# switches the party
			if selected_state && selected_target is PlayerCharacter:
				switch_target_party(selected_target, "Left")
		
		# If either GroupSelect buttons are pressed
		elif event.is_action_pressed("GroupSelectLeft") || event.is_action_pressed("GroupSelectRight"):
			# If in the selected state group selects the group of
			# that the current character is selected
			if selected_state:
					group_select(selected_target)
					
		# If any of the right buttons are pressed		
		elif event.is_action_pressed("Right"):
			# If the selected target is a enemy character
			# switches the party
			if selected_state && selected_target is BaseEnemy:
				switch_target_party(selected_target, "Right")
		
		# If any of the confirm buttons are pressed		
		elif event.is_action_pressed("Confirm"):
			# If in select state
			if selected_state:
				# If the current menu is the main menu
				if current_menu == "main menu":
					# Does a basic attack
					player_basic_attack()
				# If the current menu is the skill menu
				elif current_menu == "skill menu":
					# use the selected skill
					skill_used()
				# If the current menu is the item menu
				elif current_menu == "item menu":
					# Uses the selected item
					use_item()
				# Set the character back to default state
				selected_state = false
				remove_selection()
				turn_over(active_party_member)
			# Set the character to defend and the turn
			elif defend_state:
				defend_action()
				turn_over(active_party_member)
		
		# If any of the cancle buttons are pressed			
		elif event.is_action_pressed("Cancle"):
			# If in the main menu
			if current_menu == "main menu":
				# Switch active player character
				switch_current_active_player()
			# If in the selection state
			elif selected_state:
				# remove the selection
				remove_selection()
				selected_state = false
				# Go back to the prevouse menu
				if current_menu != "main menu":
					display_menu()
			else:
				# goes back to the main menu
				current_menu = "main menu"
				display_menu()


## Displays the correct menu bases on state
func display_menu() -> void:
	match current_menu:
		"skill menu":
			skill_menu.visible = true
			skill_list[0].grab_focus()
			current_button = skill_list[0]
		"item menu":
			item_menu.visible = true
			var items: Array = item_menu.get_children()
			if !items.is_empty():
				items[0].grab_focus()
		"main menu":
			skill_menu.visible = false
			item_menu.visible = false
			main_battle_menu()


## Get the first enemy in the array and select them
func get_inital_enemy() -> CharacterBase:
	selected_target = enemy_party[0]
	selected_target.selected()
	return selected_target


## Get the first player in the active array and select them
func get_inital_player() -> CharacterBase:
	selected_target = active_party_member
	selected_target.selected()
	return selected_target


## Switchs to the next target
func get_next_target(direction: String) -> CharacterBase:
	# Deselect target
	selected_target.deselected()
	var next_target_index: int = 0
	var targeted_party: Array 
	# Gets the index of the current target
	if selected_target is PlayerCharacter:
		targeted_party = targetable_player_team
		next_target_index = targeted_party.find(selected_target)
	else:
		targeted_party = enemy_party
		next_target_index = targeted_party.find(selected_target)
	# Updates index of the next selected target
	match direction:
		"Up":
			next_target_index -= 1
		"Down":
			next_target_index += 1
	# if the index is less then zero
	if next_target_index < 0:
		# Gets last charater in the party
		selected_target = targeted_party.back()
	# if the index is equal to the size
	elif next_target_index == targeted_party.size():
		# Gets the first character in the array
		selected_target = targeted_party.front()
	else:
		# Get the character at the index
		selected_target = targeted_party[next_target_index]
	# Selects the target
	selected_target.selected()
	# Returns that newly selected target
	return selected_target


## Switches the target party based on current target and direction pressed	
func switch_target_party(target: CharacterBase, direction: String) -> void:
	# Deslects all characters in a party
	if target is PlayerCharacter:
		for member: PlayerCharacter in targetable_player_team:
			member.deselected()
	else:
		for member: BaseEnemy in enemy_party:
			member.deselected()
		multitargetted = false
	# If the target is player character and direction pressed is left 
	if target is PlayerCharacter && direction == "Left":
		# Switch to enemy party
		get_inital_enemy()
	# if the target enemy character and direction pressed is right
	elif target is BaseEnemy && direction == "Right":
		# Switches to player party
		get_inital_player()
	# Sets multitargetted to false
	multitargetted = false


## Selects and deselects entire groups based on based in target
func group_select(target: CharacterBase) -> void:
	# If currently not multitargeting
	if not multitargetted:
# Checks to see if we are in skill select state and the skill multitargetable
		if used_skill.get_multi_castable() && skill_selected_state:
			# Depending on the target selects their whole groups
			if target is PlayerCharacter:
				for party_member: PlayerCharacter in targetable_player_team:
					party_member.selected()
			elif target is BaseEnemy:
				for enemy: BaseEnemy in enemy_party:
					enemy.selected()
			# Currently in multitargettted state
			multitargetted = true
	else:
# Checks to see if we are in skill select state and the skill multitargetable
		if used_skill.get_multi_castable() && skill_selected_state:
			# Depending on the target deselects their whole groups 
			if target is PlayerCharacter:
				for party_member: PlayerCharacter in targetable_player_team:
					party_member.deselected()
			elif target is BaseEnemy:
				for enemy: BaseEnemy in enemy_party:
					enemy.deselected()
			# Selects the orginal selected target
			target.selected()
			# End multitargeted state
			multitargetted = false


## Switch active player character
func switch_current_active_player() -> void:
	# If there is a character waiting in que
	if !player_que.is_empty():
		# Deactive character and but them back in the que
		active_party_member.deactive_player()
		player_que.push_back(active_party_member)
		# Get the next character in que
		active_party_member = player_que.pop_front()
		# Update skill list to new player character
		for skill in $Skills.get_children():
			$Skills.remove_child(skill)
			skill.free()
		# Disable controls
		$controls.visible = false
		await get_tree().create_timer(.2).timeout
		# Start new turn
		turn_start()


## Handles what to do when a player character is ready for 
func charaters_ready_for_action(character: PlayerCharacter) -> void:
	# If there's currently an active party member
	if party_member_ready:
		# Character gets added to que
		player_que.push_back(character)
	else:
		# Character becomes the active character
		active_party_member = character
		turn_start()
	
	
## Enable the battle menu and but focus on the attack button
func main_battle_menu() -> void:
	$controls.visible = true
	controls[0].grab_focus()
	current_button = controls[0]


## Deslects the currently selected target
func remove_selection() -> void:
	selected_target.deselected()


## Sets the character ATB gauge to 0
func reset_atb(character: CharacterBase) -> void:
	atb_tracker[character] = 0.0	


## Handles the player characters animation
func play_animation(sprite: CharacterBase) -> void:
	if sprite.is_in_group("player"):
		sprite.play_animation("base_attack")	


##  Displays the bassed in text on the top of the battle screen
func display_battle_message(text: String) -> void:
	# Updates text
	battle_message_display.text = text
	# Displays the text for one second and deactives it
	battle_message_display.visible = true
	await get_tree().create_timer(1).timeout
	battle_message_display.visible = false
	# Resets the message to being blank
	battle_message_display.text = ""


## Loads the next action to be play and handles it
func next_action() -> void:
	# Gets the action
	var action: BattleAction = qued_actions.pop_front()
	# Gets the character doing the action
	var actioneer: CharacterBase = action.actioneer
	# Get the character the action is happening to
	var being_attacked: CharacterBase = action.whos_being_attacked
	# Plays animation if there is one
	play_animation(actioneer)
	# Displays the action name if there is one
	if action.name != "":
		display_battle_message(action.name)
	# Depending on the type of action
	match action.type_of_action:
		"defend":
			# If defend activate defense boost
			actioneer.activate_defense_boost()
		"item":
			# If item uses the item
			item_action(being_attacked, action.item)
		"skill":
			# if skill uses the skill
			skill_damage_calc(actioneer, being_attacked, action.multi_target, action.name)
		"basic attack":
			# if basic attack uses the basic attack
			basic_attack_calc(actioneer, being_attacked)
	
	# Reset character ATB and let them start accumulating again		
	reset_atb(actioneer)
	actioneer.active = false
	actioneer.waiting_for_action = false
#endregion


#region Turn relalted functions
## Sets up the menus for a new character		
func turn_start() -> void:
	# Sets there is a party memeber ready
	party_member_ready = true
	# Displays battle menu puts focus on the first button
	$controls.visible = true
	current_button = controls[0]
	current_button.grab_focus()
	# Gets skill and item menu ready
	load_skills()
	load_items()
	# Gets player character ready
	active_party_member.check_defense_boost()
	active_party_member.active_player()


## Resets everything to the base state	
func turn_over(player : PlayerCharacter) -> void:
	# Updates all bools to false
	attack_state = false
	skill_menu_state = false
	selected_state = false
	defend_state = false
	skill_selected_state = false
	party_member_ready = false
	multitargetted = false
	# Sets the current menu to main menu
	current_menu = "main menu"
	# Disable the menu
	$controls.visible = false
	# Sets used item to null
	used_item = null
	
	# Deselects all character on the field
	player.deactive_player()
	for enemy: BaseEnemy in enemy_party:
		enemy.deselected()
	for member: CharacterBase in targetable_player_team:
		member.deselected()
	if player_que.find(player):
		player_que.erase(player)
	# Remove skills and items from there menus
	for skill in $Skills.get_children():
		$Skills.remove_child(skill)
		skill.free()
	for item in $Items.get_children():
		$Items.remove_child(item)
	# If another player character ready load there turn
	if !player_que.is_empty():
		active_party_member = player_que.pop_front()
		await get_tree().create_timer(1).timeout
		turn_start()
#endregion


# ------------ S1.3 Battle outcome related --------------


#region Battle outcome related
## Used to check if the player has won the batle
func win() -> void:
	# If there are no enemies left
	if enemy_party.is_empty():
		# Sets battle ot over
		battle_over = true
		# Gets the number of living player party members
		var counter: int = 0
		var alive_members: Array = []
		for member: CharacterBase in player_party:
			if member.get_current_hp() != 0:
				alive_members.push_back(member)
				counter += 1
				# Removes the player character from the atb tracker
				atb_tracker.erase(member)
		# Get how much exp each living party member receives
		var exp_gainded: int = (possible_exp / counter)
		# Add the exp to the living party members
		for member: CharacterBase in alive_members:
			member.addEXP(exp_gainded)
		# Display victory screen
		victory_screen()


## Handles end of battle and displays a victory screen also reloads world scene		
func victory_screen() -> void:
	# Removes all qued actions
	qued_actions.clear()
	# Ends the active player turn 
	turn_over(active_party_member)
	# Hides all on screen elements
	$controls.visible = false
	$player_1_health.visible = false
	$player_2_health.visible = false
	$Skills.visible = false
	# Displays victory screen
	$Victory.visible = true
	# Remove players from the party node
	for member in party_node.get_children():
		party_node.remove_child(member)
	# Updates the overworld status
	OverworldStatus.battle_won()
	# Wait for anything that needs to be finished and load over world scene
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://Scenes/over_world_test.tscn")


## Handles a game over if one occurred
func game_over() -> void:
	# If player targetable team is 0
	if targetable_player_team.size() == 0:
		# 
		#for enemy in enemy_party:
		#	enemy.set_game_over()
		#for member in player_party:
		#	member.battle_over()
		# Clears que of actions
		
		qued_actions.clear()
		# Display game over screen
		$Game_over.visible = true


## Signal if a player character dies
func _on_charaters_death(character: PlayerCharacter) -> void:
	# Removes the character from the targetable player team
	targetable_player_team.erase(character)
	game_over()
#endregion


#region Attack command related
## If the player clicks the attack button
func _on_attack_pressed() -> void:
	# Get the first enemy and selected update states 
	get_inital_enemy()
	selected_state = true
	# Disable battle menu
	$controls.visible = false


## Adds a basic attack to the que
func player_basic_attack() -> void:
	var attacker: PlayerCharacter = active_party_member
	attacker.waiting_for_action = true
	add_to_que(attacker, "basic attack", selected_target, "", false)
#endregion


#region Defend command related
## If the player clicks the defend button
func _on_defend_pressed() -> void:
	# Disable menu and selects active party member and go into defend state
	$controls.visible = false
	active_party_member.selected()
	defend_state = true


## Activates the defense boost for the active character
func defense_boost() -> void:
	active_party_member.activate_defense_boost()


## Adds a defend action into the que
func defend_action() -> void:
	var attacker: PlayerCharacter = active_party_member
	attacker.waiting_for_action = true
	add_to_que(attacker, "defend", selected_target, "", false)
	active_party_member.deselected()
#endregion


#region Skill command related
## Loads the skill into the skill menu based on active party member
func load_skills() -> void:
	for skill: String in active_party_member.skill_list:
		# Creates a new button, update name and it the the skill menu node
		var skill_node: Button = Button.new()
		skill_node.text = skill
		skill_menu.add_child(skill_node)
		# Creates a signal on when a skill button is pressed
		skill_node.pressed.connect(_on_skill_node_pressed.bind(active_party_member.skill_list[skill]))
	# Gets all skills of the character a put them in array
	skill_list = skill_menu.get_children()


## If the players clicks the skill button
func _on_skill_pressed() -> void:
	# Switchs the current menu to the skill menu and displays it
	current_menu = "skill menu"
	$controls.visible = false
	skill_menu.visible = true
	# Puts focus on the first skill in the list
	skill_list[0].grab_focus()
	current_button = skill_list[0]


## Handle when the player clicks a skill
func _on_skill_node_pressed(skill: SkillBase) -> void:
	# Checks if the character has enough mp
	if active_party_member.check_mp(skill):
		# Holds on the the selected skill
		used_skill = skill
		# Update states 
		selected_state = true
		skill_selected_state = true
		skill_menu_state = false
		# Disable the skill menu
		skill_menu.visible = false
		# Depending on the type of skill select the first target in the group
		if skill.type != "healing":
			# if not a healing skill get the first enemy
			get_inital_enemy()
		else:
			# if it is a healing skill get the first living character
			get_inital_player()
	# else play error noise and not enough mp


## Adds a skill action to the que
func skill_used() -> void:
	var attacker: PlayerCharacter = active_party_member
	attacker.waiting_for_action = true
	add_to_que(attacker, "skill", selected_target, used_skill.name, multitargetted)
#endregion


#region Item command related
## Loads the items into the item menu
func load_items() -> void:
	# Gets the conentents of the global inventory
	var contents: Dictionary = Inventory.get_inventory()
	# Creates a button for each button for each item in the inventory
	for item: BaseItem in contents:
		# Creates a new button with text like (potion x3)
		var item_button: Button = Button.new()
		var item_text: String = (item.name + " x" +String.num_int64(contents[item]))
		item_button.text = item_text
		# Connects a signal to handle when the button is pressed
		item_button.pressed.connect(_on_item_node_pressed.bind(item))
		# Adds the item to the item menu
		item_menu.add_child(item_button)


## Signal to handle if a item button is pressed  
func _on_item_pressed() -> void:
	# current menu = item menu
	current_menu = "item menu"
	# Disable main menu and display item menu
	$controls.visible = false
	item_menu.visible = true
	# Gets the first item in the group if the item menu is not empty
	var items: Array = item_menu.get_children()
	if !items.is_empty():
		items[0].grab_focus()


## Handle if an item button is clicked
func _on_item_node_pressed(item: BaseItem) -> void:
	# Update states as needed
	selected_state = true
	item_menu.visible = false
	# Save the clicked item
	used_item = item
	# Target the correct group based on if the item is beneficial or not
	if item.type < 25:
		get_inital_player()
	else:
		get_inital_enemy()


## Adds a item action to the que
func use_item() -> void:
	Inventory.use_item(used_item)
	var attacker: PlayerCharacter = active_party_member
	add_to_que(attacker, "item", selected_target, used_item.get_name(), false)
#endregion


#region Enemy code
## Loads the enemies in the battle scene
func load_enemies() -> void:
	var counter: int = 0
	# For each enemy
	for enemy: BaseEnemy in enemy_party:
		# Connect there death signal
		enemy.death.connect(_on_enemy_base_death)
		# Add there exp together
		possible_exp += enemy.awarded_exp
		# Place there postition onto the preplace markers
		enemy.global_position = enemy_marker[counter].global_position 
		# Update counter to get the next marker posistion
		counter += 1


## Handles the enemey turn
func enemy_base_ready_to_attack(enemy: BaseEnemy) -> void:
	# If there is still a player character alive
	if !targetable_player_team.is_empty():
		# Get the action the enemy chose
		var action: BattleAction = enemy._chose_action()
		# Fills out the rest of the action object
		action.actioneer = enemy
		# Randomly choose who to attack and add them to who's being attacked
		# TODO: add away to prioritize a certain target more 
		var attacking_number: int = randi() % targetable_player_team.size()
		var target_player_character: PlayerCharacter = targetable_player_team[attacking_number]
		action.whos_being_attacked = target_player_character
		qued_actions.push_back(action)


## Gets called when an enemy is killed
func _on_enemy_base_death(enemy: BaseEnemy) -> void:
	# Remove them from atb tracker and enemy party
	atb_tracker.erase(enemy)
	enemy_party.erase(enemy)
	# Check if the player as wone
	win()
#endregion


#region Combat code
## Calculates the attacker physical damage
func get_physical_damage(attacker: CharacterBase) -> int:
	return ((attacker.get_physical_damage_stat() * (randi() % 3 + 1)) / 2)


## Calculates the attacker magical damage
func get_magical_damage(attacker: CharacterBase) -> int:
	return ((attacker.get_magical_damage_stat() * (randi() % 3 + 1)) / 2)
	

## Check if the attacky dodge a physical attack	
func dodged_physical(attacky: CharacterBase) -> bool:
	var rand_num: int = (randi() % 101)
	if rand_num < attacky.get_physical_evasion_stat():
		return true
	else:
		return false


## Check if the attacky dodge a magical attack	
func dodged_magical(attacker: CharacterBase) -> bool:
	var rand_num: int = (randi() % 101)
	if rand_num < attacker.get_magical_evasion_stat():
		return true
	else:
		return false


## Checks if the attacker crits and returns the extra damage
func crit_damage(attacker: CharacterBase) -> int:
	var additional_damage: int = 0
	var rand_num: int = (randi() % 101)
	if rand_num < attacker.get_luck_stat():
		additional_damage = (attacker.get_physical_damage_stat() / 2)
	return additional_damage


## Calculates the received damage
func received_damage(damage: int, defense: int) -> int:
	var damage_taken: int = damage - defense
	if damage_taken < 0:
		damage_taken = 0
	return damage_taken


## Handles a basic attack related action
func basic_attack_calc(attacker: CharacterBase, attacky: CharacterBase) -> void:
	# Checks if the person being attack dodges
	if !dodged_physical(attacky):
		# Get the damage and defense of the character involved
		var damage: int = get_physical_damage(attacker)
		var defense: int = attacky.get_physical_defense_stat()
		# Gets crit damage
		damage += crit_damage(attacker)
		# Checks if the attacky has a defense boost active
		if attacky.defense_boost:
			defense += (attacky.get_physical_defense_stat() / 4)
		# Get how much damage happen
		var damage_taken: int = received_damage(damage, defense)
		# Updates the attack health and display damage numbers
		attacky._health_changed("damage", damage_taken)
		attacky.show_message(str(damage_taken))
	else:
		# If the person dodges show Missed message
		attacky.show_message("Missed")


## Handles a skill related acction
func skill_damage_calc(attacker: CharacterBase, attacky: CharacterBase, 
		multi_targeted: bool, skill_name: String) -> void:
	# Gets the used skill from the attack and reduced the attackers mp
	var skill: SkillBase = attacker.get_skill(skill_name)
	attacker._mp_change("used", skill.mp_cost)
	# Set up variables to be used for calculations
	var damage: int = 0
	var defense: int = 0
	var damage_taken: int = 0
	# Depending on the skill type calculate damge and defense accordinly
	match skill.type:
		"physical":
			if !dodged_physical(attacky):
				# Gets the damage and defense
				damage = (get_physical_damage(attacker) * skill.damage_modifier)
				defense = attacky.get_physical_defense_stat()
				# Check if there is a deffense boost is active
				if attacky.defense_boost:
					defense += (attacky.get_physical_defense_stat() / 4) 
			else:
				# Displays missed if the character being attack dodges
				attacky.show_message("Missed")
		"magical":
			if !dodged_magical(attacky):
				# Gets the damage and defense
				damage = (get_magical_damage(attacker) * skill.damage_modifier)
				defense = attacky.get_magical_defense_stat()
				# Check if there is a deffense boost is active
				# TODO: used this for something like shell from final fantasy
				if attacky.defense_boost:
					defense += (attacky.get_magical_defense_stat() / 4)  
			else:
				# Displays missed if the character being attack dodges
				attacky.show_message("Missed")
		"healing":
			pass
	# If the skill being used is multi_targeted
	if multi_targeted:
		if attacky is BaseEnemy:
			# Divides damage by the number of living enemies
			damage = (damage / enemy_party.size())
			# Applies the damge to each enemy
			for enemy: BaseEnemy in enemy_party:
				defense = enemy.get_magical_defense_stat()
				damage_taken = received_damage(damage, defense)
				enemy._health_changed("damage", damage_taken)
				enemy.show_message(str(damage_taken))
		else:
			# Divides damage by the number of living player party members
			damage = (damage / targetable_player_team.size())
			# Applies the damge to each living party members
			for member: PlayerCharacter in targetable_player_team:
				defense = member.get_magical_defense_stat()
				damage_taken = received_damage(damage, defense)
				member._health_changed("damage", damage_taken)
				member.show_message(str(damage_taken))
	else:
		# Applies damge to the character being attack and display the message
		damage_taken = received_damage(damage, defense)
		attacky._health_changed("damage", damage_taken)
		attacky.show_message(str(damage_taken))


## Handles a item related acction
func item_action(attacky: CharacterBase, item: BaseItem) -> void:
	match item.type:
		20: # hp healing items
			attacky._health_changed("healling", item.healing)
			attacky.show_message(str(item.healing))
		21: # mp healing items
			attacky._mp_change("healling", item.healing)
			attacky.show_message(str(item.healing))
		22: # HP and healing items
			pass
		23: # status healing items
			pass
		24: # buff items
			pass
		25:  # damaging items
			attacky._health_changed("damage", item.damage)
			attacky.show_message(str(item.damage))

#endregion	
