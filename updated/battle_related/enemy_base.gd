extends CharacterBase
class_name BaseEnemy
# Base enemy class the extends from CharacterBase


#region Attributes
@warning_ignore("unused_signal")
## Used to signal the field the enemy is dead
signal death(enemy: BaseEnemy)
## The number of EXP the enemy can give
var awarded_exp: int
## Keeps track if the character dead or not
var dead: bool = false
## Tracks if the character is active
var active: bool = false
## Tracks if the character defense boost
var defense_boost: bool = false
#endregion


#region Functions
## Sets the current current_hp and current_mp
func _ready() -> void:
	current_hp = max_hp
	current_mp = max_mp


## Checks if the character is dead or not
func check_hp() -> void:
	if current_hp <= 0:
		# Holds for 2 seconds
		await get_tree().create_timer(2).timeout
		# Emit signal
		emit_signal("death",$"." )
		# Deactivate self and set to dead
		$".".visible = false
		set_dead()


## Set the character to death
func set_dead() -> void:
	dead = true	


## Overides base class update current hp
func _health_changed(type: String, amount: int) -> void:
	# If type of damge
	if type == "damage":
		# if amount is a negative number
		if amount < 0:
			amount = 0
		# update current hp
		current_hp -= amount
		# check if dead
		check_hp()	
	else:
		# updates current hp 
		current_hp += amount
		# if greater than max_hp set current hp to max hp
		if current_hp > max_hp:
			current_hp = max_hp


## Overides base class update current mp
func _mp_changed(type: String, amount: int) -> void:
	if amount > 0:
		# If type of used
		if type == "used":
			current_mp -= amount
			# If current mp is negative
			if current_mp < 0:
				current_mp = 0
		else:
			current_mp += amount
			# if current_mp greater than max mp
			if current_mp > max_mp:
				current_mp = max_mp


## Choses the action of the emeny fully overide
func _chose_action() -> BattleAction: # overided in inhereted class
	return BattleAction.new()


## Returns a random skill choose
func choose_skill() -> SkillBase:
	# TODO: Might remove later for choose action
	# add code to randomly choose and update
	var keys: Array = skill_list.keys()
	return skill_list[keys[0]]
#endregion
