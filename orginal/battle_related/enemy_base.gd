extends AnimatedSprite2D

class_name BaseEnemy

# Section List
# S1 Functionality related
# S2 Combat related
# -- S2.1 Defense
# -- S2.2 Physical
# -- S2.3 Magical
# -- S2.4 Skill

var Name 
var health 
var magic_points
var strength
var defense
var magic
var magic_defense
var speed 
var luck
var physical_evasion
var magic_evasion 
var awarded_exp
var skill_list = []

@onready var selected = $selected
var ATB_Gauge = 0.0
var current_health = 0
var current_mp = 0

var dead = false
var waiting_for_action = false
var ready_action = true


@onready var hp_text = $hp
signal ready_to_attack(enemy)
signal death(enemy)


# ------------------- S1 Functionality related ---------------------------------
func _ready():
	current_health = health
	current_mp = magic_points
	ATB_Gauge = (randi() % speed)

func _process(delta):
	if !dead:
		if !waiting_for_action && ready_action:
			ATB_Gauge += (delta * 9)
			if ATB_Gauge >= 100 :
				# create function to to decide what action to take place attack/ skill / defend
				emit_signal("ready_to_attack", $".")
				ready_action = false
			
func beenSelected():
	selected.visible = true
	
func beenUnselected():
	selected.visible = false

func type_of_attack():
	var randnum = randi() % 11
	##if randnum <= 10:
	return "base_attack"
	##return "skill_used"

func missed():
	hp_text.text = "Missed"
	await get_tree().create_timer(1).timeout
	hp_text.text = ""

func check_hp():
	if current_health <= 0:
		emit_signal("death",$"." )
		$".".visible = false
		set_game_over()

func atb_reset():
	ATB_Gauge = 0.0
	ready_action = true
	
func set_game_over():
	dead = true
	atb_reset()		

func health_changed(type, amount):
	if type == "damage":
		await get_tree().create_timer(1).timeout
		hp_text.text = String.num_int64(amount)
		await get_tree().create_timer(1).timeout
		hp_text.text = ""
		current_health -= amount
		check_hp()	
	else:
		print("enemy got healed: " + String.num_int64(amount))
		current_health += amount
		if current_health > health:
			current_health = health
	
func incoming_attack(type, damage):
	if type == "physical":
		if !evades_physical():
			damage -= physical_defense()
			if damage < 0:
				damage = 0
			health_changed("damage", damage)
		else:
			hp_text.text = "missed"
			await get_tree().create_timer(1).timeout
			hp_text.text = ""
			print("ememy dodged")
	elif type == "magical":
		if !evades_magical():
			damage -= magical_defense()
			if damage < 0:
				damage = 0
			health_changed("damage", damage)
		else:
			hp_text.text = "missed"
			await get_tree().create_timer(1).timeout
			hp_text.text = ""
	elif type == "healing":
		health_changed("healing", damage)

# ------------------- S2 Combat related ---------------------------------------
func chose_action(action : BattleAction):
	pass


func inflicted_damage(damage):
	hp_text.text = String.num_int64(damage)
	await get_tree().create_timer(1).timeout
	hp_text.text = ""
	current_health -= damage
	check_hp()		
	
func critChance():
	var rate = randi() % 101
	var extra_damge = 0
	if rate < luck:
		extra_damge = (strength / 2)
		return extra_damge  
	return extra_damge


# ------------ S2.1 Defense --------------
func physical_defense():
	return defense * 3

func magical_defense():
	return magic_defense * 5
			
			
# ------------ S2.2 Physical--------------		
func physical_attack_damage():
	return strength  * 3		
	
func evades_physical():
	var rand_num = (randi() % 101)
	if rand_num < physical_evasion:
		return true
	else:
		return false


# ------------ S2.3 Magical --------------
func magical_attack_damage():
	return magic * 5

func evades_magical():
	var rand_num = (randi() % 101)
	if rand_num < magic_evasion:
		return true
	else:
		return false

# ------------ S2.4 Skill ----------------

func choose_skill():
	# add code to randomly choose and update
	return skill_list[0]
	
func check_mp(skill):
	if magic_points >= skill.MP_Cost:
		magic_points -= skill.MP_Cost
		return true
	print("not enought magic_points")
	return false
	
func skill_calc(skill):
	var skill_damage = 0
	var base_damage = 0
	if skill.type == "physical":
		base_damage = physical_attack_damage()
	else:
		base_damage = magical_attack_damage()
	skill_damage = ((base_damage) * skill.damage_modifier)
	return skill_damage
	
# ------------ S2.5 Items ----------------	

func use_item(item):
	var item_type = item.get_type()
	match item_type:
		20:
			health_changed("healing", item.healing)
		21:
			current_mp += item.healing
			if current_mp > magic_points:
				current_mp = magic_points
			emit_signal("mp_changed", $".")
		22:
			pass
		23: 
			pass
		24:
			pass
		25:
			health_changed("damage", item.damage)
