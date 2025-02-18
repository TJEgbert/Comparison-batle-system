class_name CharacterBase
extends AnimatedSprite2D
## Base used for all characters that need stats
## and that are used in battle

#region Attributes
## Characters name
var character_name: String
## Characters class
var character_class: String
## Tracks level
var level: int
## Tracks max hp
var max_hp: int
## Tracks max mp
var max_mp: int
## Tracks max strength stat
var strength: int
## Tracks defense stat
var defense: int
## Tracks magic stat
var magic: int
## Tracks magic defense stat
var magic_defense: int
## Tracks speed stat
var speed: int
## Tracks luck stat
var luck: int
## Tracks physical evasion stat
var physical_evasion:int
## Tracks magic evasion stat
var magic_evasion: int
## The current character hp
var current_hp: int
## The current character mp
var current_mp: int
## Holds the characters skills
var skill_list: Dictionary = {}
## Tracks if character is waiting for an action or not
var waiting_for_action: bool
# The amount of time a message is visible by the characters
var message_delay: float = 1.0
#endregion


#region Genral functions
##  Highlight the selected character
func selected() -> void:
	$selected.visible = true


##  Remove highlight the selected character
func deselected() -> void:
	$selected.visible = false

## Checks if the character has enough mp for a skill returns a bool
func check_mp(skill: SkillBase)-> bool:
	if current_mp >= skill.mp_cost:
		return true
	return false
	
	
## Returns the skill of the passed in name, returns a SkillBase class
func get_skill(skill_name: String) -> SkillBase:
	return skill_list[skill_name]
	

## Display a message next to the character
func show_message(message: String) -> void:
	await get_tree().create_timer(message_delay).timeout
	$character_message.text = message
	await get_tree().create_timer(message_delay).timeout
	$character_message.text = ""	
#endregion


#region Full overided functions
## How the character handles hp changes
func _health_changed(_type: String, _amount: int) -> void:
	pass


## How the character handles mp changes
func _mp_change(_type: String, _amount: int) -> void:
	pass
#endregion


#region Overide Functions
## Returns strength stat
func get_physical_damage_stat() -> int:
	return strength


## Returns defense stat	
func get_physical_defense_stat() -> int:
	return defense

	
## Returns magic stat
func get_magical_damage_stat() -> int:
	return magic

	
## Returns magic_defense stat
func get_magical_defense_stat() -> int:
	return magic_defense


## Returns physical_evasion	stat
func get_physical_evasion_stat() -> int:
	return physical_evasion	


## Returns magical_evasion stat
func get_magical_evasion_stat() -> int:
	return magic_evasion


## Returns speed stat
func get_speed_stat() -> int:
	return speed	


## Returns luck stat
func get_luck_stat() -> int:
	return luck

	
## Returns current hp
func get_current_hp() -> int:
	return current_hp


## Returns current mp
func get_current_mp() -> int:
	return current_mp
#endregion
