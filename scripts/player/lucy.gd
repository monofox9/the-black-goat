extends CharacterBody2D

@export_category("Charge Power")
@export var max_charge_power := 100.0

@export_category("Charge")
@export var charge_speed := 900.0
@export var charge_duration := 0.25

@export_category("Movement")
@export var move_speed := 250.0
@export var acceleration := 1800.0
@export var deceleration := 600.0

@export_category("Jumping")
@export var jump_velocity := -550.0
@export var gravity := 1500.0
@export var air_acceleration := 900.0

var charge_power := 100.0
var facing_direction := 1.0
var is_charging := false
var charge_direction := 1.0
var charge_timer := 0.0

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_charge_input()

	if is_charging:
		handle_charge(delta)
	else:
		handle_movement(delta)
		handle_jump()

	move_and_slide()

func handle_charge_input() -> void:
	if Input.is_action_just_pressed("charge") \
			and not is_charging \
			and charge_power >= max_charge_power:
		start_charge()
		
func start_charge() -> void:
	is_charging = true
	charge_timer = charge_duration
	charge_direction = facing_direction
	
	charge_power = 0.0

func handle_charge(delta: float) -> void:
	velocity.x = charge_direction * charge_speed

	charge_timer -= delta

	if charge_timer <= 0:
		is_charging = false

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func handle_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		facing_direction = direction

	var current_acceleration := acceleration

	if not is_on_floor():
		current_acceleration = air_acceleration

	if direction != 0:
		velocity.x = move_toward(
			velocity.x,
			direction * move_speed,
			current_acceleration * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			deceleration * delta
		)
