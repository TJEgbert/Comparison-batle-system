extends CharacterBase
class_name PlayerCharacter
## Base player controlled character

## TO DO
## Think of away to add health and magic points to max amount

#region Attributes
## Let the battle field know the character is dead
@warning_ignore("unused_signal")
signal death(character: PlayerCharacter)
## Let the battle field know character current_hp changed
@warning_ignore("unused_signal")
signal hp_changed(character: PlayerCharacter)
## Let the battle field know character current_mp changed
@warning_ignore("unused_signal")
signal mp_changed(character: PlayerCharacter)

## Used to play the animation
@onready var sprite_animation: AnimatedSprite2D = $"."
## Used to moves the player forward
@onready var movement_player: AnimationPlayer = $AnimationPlayer
## Used to show the character is the active character
@onready var active_character: ColorRect = $active_character
## Used to display the character message
@onready var character_message: Label = $character_message

## Tracks the players location in the battle order array
var array_order: int
## Tracks the characters next level
var next_level_exp: int = 10
## Tracks the equipment hp
var equipment_hp: int = 0
## Tracks the equipment mp
var equipment_mp: int = 0
## Tracks the equipment strength
var equipment_strength: int = 0
## Tracks the equipment defense
var equipment_defense: int = 0
## Tracks the equipment magic
var equipment_magic: int = 0
## Tracks the equipment magic defense
var equipment_magic_defense: int = 0
## Tracks the equipment speed
var equipment_speed: int = 0
## Tracks the equipment luck
var equipment_luck: int = 0
## Tracks the equipment physical evasion
var equipment_physical_evasion: int = 0
## Tracks the equipment magic evasion
var equipment_magic_evasion: int = 0
## Tracks the character experience points
var experience_points: int = 0

## Holds the weapon for the character
var weapon_slot: BaseWeapon
## Holds the helm for the character
var helm_slot: BaseHelm
## Holds the armor for the character
var armor_slot: BaseArmor
## Holds the accessory for the character
var accessory_slot: BaseAccessory

## Tracks if the player is defending or not
var defense_boost: bool = false
## Tracks if the player is dead or not
var dead: bool = false
## Tracks if the player is active or not
var active: bool = false
#endregion


#region Functions
## Sets the character as the active character
func active_player() -> void:
	active_character.visible = true


## Disable the character as the active character	
func deactive_player() -> void:
	active_character.visible = false


## Plays the animation if the passed in string		
func play_animation(animation_string: String) -> void:
	match animation_string:
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
			

## Adds the amount to experince points				
func addEXP(amount: int) -> void:
	experience_points += amount
	level_up()
	
	
## Stats to be updated for each level
func level_up() -> void:
	while(experience_points >= next_level_exp):
		level += 1
		match level:
			6:
				max_hp += 50
				strength += 4
				defense += 7
				#var cure = Cure.new()
				#skill_list[cure.name] = cure
				next_level_exp = 15
				#print("learned skill " + cure.Name)
			7:
				max_hp += 50
				strength += 4
				defense += 7
				next_level_exp = 20
			8:
				max_hp += 50
				strength += 4
				defense += 7
				next_level_exp = 150


## Returns if the player is alive or not	
func alive() -> bool:
	if current_hp > 0:
		return true
	dead = true
	current_hp = 0
	return false
	

## Revives the character	
func revive() -> void:
	dead = false
	@warning_ignore("integer_division")
	current_hp = ceil(max_hp /2)
	

## Adds the weapon to equipment
func equip_weapon(weapon : BaseWeapon) -> void:
	weapon_slot = weapon
	add_equip_stats(weapon)


## Adds the helm to equipment
func equip_helm(helm : BaseHelm) -> void:
	helm_slot = helm
	add_equip_stats(helm)


## Adds the armor to equipment
func equip_armor(armor : BaseArmor) -> void:
	armor_slot = armor
	add_equip_stats(armor)


## Adds the accessory to equipment
func equip_accessory(accessory : BaseAccessory) -> void:
	accessory_slot = accessory
	add_equip_stats(accessory)


## Adds all equipment_stats to the player stats		
func add_equip_stats(equipment: BaseItem) -> void:
	pass
	#var equipment_stats: BaseItem = equipment.get_stats()
	#for stat in equipment_stats:
	#	match stat:
	#		"health":
	#			equipment_hp += equipment_stats[stat]
	#		"magic_points":
	#			equipment_mp += equipment_stats[stat]
	#		"strength":
	#			equipment_strength += equipment_stats[stat]
	#		"defense":
	#			equipment_defense += equipment_stats[stat]
	#		"magic":
	#			equipment_magic += equipment_stats[stat]
	#		"magic_defense":
	#			equipment_magic_defense += equipment_stats[stat]
	#		"speed":
	#			equipment_speed += equipment_stats[stat]
	#		"physical_evasion":
	#			equipment_physical_evasion += equipment_stats[stat]
	#		"magic_evasion":
	#			equipment_magic_evasion += equipment_stats[stat]
	#		"luck":
	#			equipment_luck += equipment_stats[stat]
	


## Set character to defending
func activate_defense_boost() -> void:
	defense_boost = true


## Set character to not defending
func deactivate_defense_boost() -> void:
	defense_boost = false


## Checks to see if character defense need to deactivate 
func check_defense_boost() -> void:
	if defense_boost:
		deactivate_defense_boost()


##  Everything that happens when a player character dies
func _is_dead() -> void:
	pass 
		
		
## Updates the player mp and let the battle scene know
func _mp_change(type, amount) -> void:
	if amount > 0:
		if type == "used":
			current_mp -= amount
			if current_mp < 0:
				current_mp = 0
		else:
			current_mp += amount
			if current_mp > max_mp:
				current_mp = max_mp
	emit_signal("mp_changed")


##	Updates the player hp and let the battle scene know			
func _health_changed(type, amount) -> void:
	if amount > 0:
		if type == "damage":
			current_hp -= amount
			if current_hp < 0:
				current_hp = 0
				play_animation("died")
				emit_signal("death")
		else:
			current_hp += amount
			if current_hp > max_hp:
				current_hp = max_hp
		emit_signal("hp_changed")
		
		
## Returns total strength stat		
func get_physical_damage_stat() -> int:
	return (strength + equipment_strength)


## Returns total defense stat		
func get_physical_defense_stat() -> int:
	return (defense + equipment_defense)


## Returns total magic stat		
func get_magical_damage_stat() -> int:
	return (magic + equipment_magic)


## Returns total magic defense stat		
func get_magical_defense_stat() -> int:
	return (magic_defense + equipment_magic_defense)


## Returns total physical evasion stat	
func get_physical_evasion_stat() -> int:
	return (physical_evasion + equipment_physical_evasion)	


## Returns total magical evasion stat	
func get_magical_evasion_stat() -> int:
	return (magic_evasion + equipment_magic_evasion)


## Returns total speed stat	
func get_speed_stat() -> int:
	return (speed + equipment_speed)	


## Returns total luck stat	
func get_luck_stat() -> int:
	return (luck + equipment_luck)


## Returns max hp stat	
func get_max_hp() -> int:
	return (max_hp + equipment_hp)


## Returns max mp stat
func get_max_mp() -> int:
	return (max_mp + equipment_mp)
	
#endregion
