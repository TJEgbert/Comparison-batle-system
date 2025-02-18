extends CharacterBody2D

class_name BaseCharacter

# Section List
# S1 Functionality related
# S2 Combat related
# -- S2.1 Defense
# -- S2.2 Physical
# -- S2.3 Magical
# -- S2.4 Skill

## TO DO
## Think of away to add health and magic points to max amount

@onready var sprite_animation = $AnimatedSprite2D
@onready var movement_player = $AnimationPlayer

var Name = "Stein"
var Class = "Fighter"
var array_order

var level = 5
var health = 600
var magic_points = 30
var strength = 35
var defense = 25
var magic = 20
var magic_defense = 15
var speed = 80
var luck = 20
var physical_evasion = 20
var magic_evasion = 20
var experience_points = 0
var ATB_Gauge = 0.0
var next_level_exp = 10
var current_health = 600
var current_mp = 30

var equipment_health = 0
var equipment_magic_points = 0
var equipment_strength = 0
var equipment_defense = 0
var equipment_magic = 0
var equipment_magic_defense = 0
var equipment_speed = 0
var equipment_luck = 0
var equipment_physical_evasion = 0
var equipment_magic_evasion = 0


var Skill_list = []
var weapon_slot
var head_armor_slot
var body_armor_slot
var accessory_slot

var defense_boost = false
var ready_state = false
var dead = false
var victory = false
var waiting_for_action = false
var battle_mode = false

var current_defense_boost = 0

signal attack_happend()
signal ready_for_action(character)
signal death(character)
signal hp_changed(character)
signal mp_changed(character)


# ------------------- S1 Functionality related ---------------------------------
func _ready():
	pass
	##var double_punch = Double_Punch.new()
	##var fire_ball = Fire_Ball.new()
	##Skill_list.push_back(double_punch)
	##Skill_list.push_back(fire_ball)
	##var short_sword = ShortSword.new()
	##var mythril_armor = MythrilArmor.new()
	##var featherd_cap = FeatheredCap.new()
	##equip_weapon(short_sword)
	##equip_armor(mythril_armor)
	##equip_helm(featherd_cap)
	##play_animation("idle")
	
func _process(delta):
	if !dead && battle_mode:
		if !waiting_for_action:
			ATB_Gauge += (delta * 10)
			if !ready_state:
				if ATB_Gauge > 100:
					emit_signal("ready_for_action")
					ready_state = true


func play_animation(animation):
	match animation:
		"idle":
			sprite_animation.play("idle")
		"base_attack":
			sprite_animation.play("move")
			movement_player.play("move_foward")
			await get_tree().create_timer(.7).timeout
			sprite_animation.play("base_attack")
			await get_tree().create_timer(.7).timeout
			sprite_animation.flip_h = true
			sprite_animation.play("move")
			movement_player.play("move_back")
			await get_tree().create_timer(.7).timeout
			sprite_animation.flip_h = false
			sprite_animation.play("idle")
		"skill_used":
			movement_player.play("move_foward")
			sprite_animation.play("move")
			sprite_animation.play("skill_use")
			movement_player.play("move_back")
			sprite_animation.flip_v = true
			sprite_animation.play("move")
			sprite_animation.flip_v = false
			sprite_animation.play("idle")
		"died":
			sprite_animation.play("death")
					
func addEXP(amount):
	experience_points += amount
	level_up()
	
func level_up():
	var inc_health = 0
	var inc_magic_points = 0
	var inc_strength = 0
	var inc_defense = 0
	var inc_magic = 0
	var inc_magic_defense = 0
	var inc_speed = 0
	var inc_luck = 0
	while(experience_points >= next_level_exp):
		level += 1
		match level:
			6:
				inc_health += 50
				health += 50
				inc_strength += 4
				strength += 4
				inc_defense +=4
				defense += 7
				var cure = Cure.new()
				Skill_list.push_back(cure)
				next_level_exp = 15
				print("learned skill " + cure.Name)
			7:
				inc_health += 50
				health += 50
				inc_strength += 4
				strength += 4
				inc_defense +=4
				defense += 7
				next_level_exp = 20
			8:
				inc_health += 50
				health += 50
				inc_strength += 4
				strength += 4
				inc_defense +=4
				defense += 7
				next_level_exp = 150
					
	print(inc_health)	
	print(inc_strength)
	print(inc_defense)	
				
func battle_start():
	battle_mode = true
	ATB_Gauge = (randi() % speed)
	
func battle_over():
	battle_mode = false
	atb_reset()

func atb_reset():
	ATB_Gauge = 0.0
	ready_state = false

func beenSelected():
	$selected.visible = true

func beenUnselected():
	$selected.visible = false
	
func alive():
	if current_health > 0:
		return true
	dead = true
	current_health = 0
	return false
	
func revive():
	dead = false
	current_health = (health /2)
	atb_reset()

func health_changed(type, amount):
	if type == "damage":
		current_health -= amount
		if current_health < 0:
			current_health = 0
			play_animation("died")
			emit_signal("death")
	else:
		current_health += amount
		if current_health > health:
			current_health = health
	emit_signal("hp_changed")
	
func incoming_attack(type, damage):
	if type == "physical":
		if !evades_physical():
			print("Current defense boost " + String.num_int64(current_defense_boost))
			damage -= (physical_defense() + current_defense_boost)
			print("The damage taken was " + String.num_int64(damage))
			if damage < 0:
				damage = 0
			health_changed("damage", damage)
	elif type == "healing":
		print("player been healed: " + String.num_int64(damage))
		health_changed("healing", damage)
	
		
func equip_weapon(weapon : BaseWeapon):
	weapon_slot = weapon
	add_equip_stats(weapon)

func equip_helm(helm : BaseHelm):
	head_armor_slot = helm
	add_equip_stats(helm)
	
func equip_armor(armor : BaseArmor):
	body_armor_slot = armor
	add_equip_stats(armor)

func equip_accessory(accessory):
	accessory_slot = accessory
	add_equip_stats(accessory)
		
func add_equip_stats(equipment):
	var equipment_stats = equipment.get_stats()
	for stat in equipment_stats:
		match stat:
			"health":
				equipment_health += equipment_stats[stat]
			"magic_points":
				equipment_magic_points += equipment_stats[stat]
			"strength":
				equipment_strength += equipment_stats[stat]
			"defense":
				equipment_defense += equipment_stats[stat]
			"magic":
				equipment_magic += equipment_stats[stat]
			"magic_defense":
				equipment_magic_defense += equipment_stats[stat]
			"speed":
				equipment_speed += equipment_stats[stat]
			"physical_evasion":
				equipment_physical_evasion += equipment_stats[stat]
			"magic_evasion":
				equipment_magic_evasion += equipment_stats[stat]
			"luck":
				equipment_luck += equipment_stats[stat]
	
# ------------------- S2 Combat related ---------------------------------------

# ------------ S2.1 Defense --------------
func activate_defense_boost():
	defense_boost = true
	current_defense_boost = (defense / 2)

func deactivate_defense_boost():
	defense_boost = false
	current_defense_boost = 0

func check_defense_boost():
	if defense_boost:
		deactivate_defense_boost()

# ------------ S2.2 Physical--------------
					
func physical_attack_damage():
	return (strength + equipment_strength) * 4
	
func physical_defense():
	return (defense + equipment_defense) * 3

func evades_physical():
	var rand_num = (randi() % 101)
	if rand_num < (physical_evasion + equipment_physical_evasion):
		return true
	else:
		return false
		
func critChance():
	var rate = randi() % 101
	var extra_damge = 0
	if rate < (luck + equipment_luck):
		extra_damge = (strength / 2)
		return extra_damge  
	return extra_damge


# ------------ S2.3 Magical --------------
func magical_attack_damage():
	return (magic + equipment_magic) * 5
	
func magical_defense():
	return (magic_defense + equipment_magic_defense) * 3
					
func evades_magical():
	var rand_num = (randi() % 101)
	if rand_num < (magic_evasion + equipment_magic_evasion):
		return true
	else:
		return false

		
# ------------ S2.4 Skill ----------------
func check_mp(skill):
	if current_mp >= skill.MP_Cost:
		return true
	print("not enought magic_points")
	return false		

func skill_calc(skill, selected_num):
	var skill_damage = 0
	var base_damage = 0
	current_mp -= skill.MP_Cost
	emit_signal("mp_changed")
	if skill.type == "physical":
		base_damage = physical_attack_damage() 
		skill_damage = (base_damage * skill.damage_modifier) / selected_num 
	elif skill.type == "magical":
		base_damage = magical_attack_damage()
		skill_damage = (base_damage * skill.damage_modifier) / selected_num 
	elif skill.type == "healing":
		base_damage = 1
		skill_damage = (base_damage * skill.damage_modifier)
	return skill_damage
		
# ------------ S2.4 Item ----------------

func use_item(item):
	var item_type = item.get_type()
	match item_type:
		20:
			health_changed("healing", item.healing)
		21:
			current_mp += item.healing
			if current_mp > magic_points:
				current_mp = magic_points
			emit_signal("mp_changed")
		22:
			pass
		23: 
			pass
		24:
			pass
		25:
			health_changed("damage", item.damage)
