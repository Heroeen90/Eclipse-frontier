extends Node

class_name QuestRewards

var experience_reward = 0
var gold_reward = 0
var item_rewards: Array[InventoryItem] = []
var resource_rewards: Dictionary = {}
var unlock_rewards: Array[String] = []

func add_experience_reward(amount: int):
	experience_reward += amount

func add_gold_reward(amount: int):
	gold_reward += amount

func add_item_reward(item: InventoryItem):
	item_rewards.append(item)

func add_resource_reward(resource_type: String, amount: int):
	if resource_rewards.has(resource_type):
		resource_rewards[resource_type] += amount
	else:
		resource_rewards[resource_type] = amount

func add_unlock_reward(unlock_id: String):
	unlock_rewards.append(unlock_id)

func claim_rewards() -> Dictionary:
	var player_stats = GameManager.instance.player_manager
	var inventory_manager = GameManager.instance.inventory_manager
	var resource_manager = GameManager.instance.resource_manager
	var logger = GameManager.instance.logger
	
	# Claim experience
	if experience_reward > 0:
		player_stats.gain_experience(experience_reward)
		logger.info("Claimed %d experience" % experience_reward, "QuestRewards")
	
	# Claim gold
	if gold_reward > 0:
		logger.info("Claimed %d gold" % gold_reward, "QuestRewards")
	
	# Claim items
	for item in item_rewards:
		inventory_manager.add_item(item)
		logger.info("Claimed item: %s" % item.item_name, "QuestRewards")
	
	# Claim resources
	for resource_type in resource_rewards:
		var amount = resource_rewards[resource_type]
		resource_manager.add_resource(resource_type, amount)
		logger.info("Claimed %d %s" % [amount, resource_type], "QuestRewards")
	
	# Handle unlocks
	for unlock_id in unlock_rewards:
		logger.info("Unlocked: %s" % unlock_id, "QuestRewards")
	
	return {
		"experience": experience_reward,
		"gold": gold_reward,
		"items": item_rewards,
		"resources": resource_rewards,
		"unlocks": unlock_rewards
	}

func to_dict() -> Dictionary:
	var items_data = []
	for item in item_rewards:
		items_data.append(item.to_dict())
	
	return {
		"experience": experience_reward,
		"gold": gold_reward,
		"items": items_data,
		"resources": resource_rewards,
		"unlocks": unlock_rewards
	}

func from_dict(data: Dictionary):
	experience_reward = data.get("experience", 0)
	gold_reward = data.get("gold", 0)
	resource_rewards = data.get("resources", {})
	unlock_rewards = data.get("unlocks", [])
	
	for item_data in data.get("items", []):
		var item = InventoryItem.new()
		item.from_dict(item_data)
		item_rewards.append(item)