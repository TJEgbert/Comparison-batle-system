class_name BattleAction
## Used to store battle actions until queued to play.

## The character performing the action
var actioneer: CharacterBase:
	get:
		return actioneer
	set(character):
		actioneer = character
		
## The character the action is happening to 
var whos_being_attacked: CharacterBase:
	get:
		return whos_being_attacked
	set(character):
		whos_being_attacked = character
		
## The action to take place (defend, item, healing, skill, basic attack)
var type_of_action: String:
	get:
		return type_of_action
	set(action):
		type_of_action = action
		
## Name of action if there is one
var name: String:
	get:
		return name
	set(action_name):
		name = action_name
		
## Used to check if the action is performed on a group
var multi_target: bool:
	get:
		return multi_target
	set(is_multi_targerted):
		multi_target = is_multi_targerted
		
## Default to null and stores item if one is used
var item: BaseItem:
	get:
		return item
	set(used_item):
		item = used_item


## Creates a new BattleAction with nothing in it
func _init() -> void:
	actioneer = null
	whos_being_attacked = null
	type_of_action = ""
	name = ""
	multi_target = false
	item = null
