class_name HealthLootTableEntry extends LootTableEntry

func can_spawn() -> bool:
	# Don't spawn if at full health
	return not Main.data.player_is_full_health
