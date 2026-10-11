extends Area2D

@export var power_value := 20.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("add_charge_power"):
		body.add_charge_power(power_value)
		queue_free()
