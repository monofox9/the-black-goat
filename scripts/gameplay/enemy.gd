extends StaticBody2D

@export var stomp_power_reward := 20.0


func stomp() -> float:
	queue_free()
	return stomp_power_reward
	
func hit_by_charge() -> void:
	queue_free()
