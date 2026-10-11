extends CharacterBody2D

@export_category("Charge Power")
@export var max_charge_power := 100.0

@export_category("Charge")
@export var charge_speed := 900.0
@export var charge_duration := 0.40

@export_category("Movement")
@export var move_speed := 250.0
@export var acceleration := 1800.0
@export var deceleration := 600.0

@export_category("Jumping")
@export var jump_velocity := -550.0
@export var gravity := 1500.0
@export var air_acceleration := 900.0

@onready var charge_bar: ProgressBar = $HUD/ChargeBar

var charge_power := 0.0
var facing_direction := 1.0
var is_charging := false
var charge_direction := 1.0
var charge_timer := 0.0

func _ready() -> void:
	charge_bar.max_value = max_charge_power
	update_charge_bar()

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_charge_input()

	if is_charging:
		handle_charge(delta)
	else:
		handle_movement(delta)
		handle_jump()

	move_and_slide()
	check_charge_collisions()

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
	update_charge_bar()

func handle_charge(delta: float) -> void:
	charge_timer -= delta

	if charge_timer <= 0.0:
		is_charging = false
		velocity.x = charge_direction * move_speed
		return

	velocity.x = charge_direction * charge_speed

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

func add_charge_power(amount: float) -> void:
	charge_power = clampf(charge_power + amount, 0.0, max_charge_power)
	update_charge_bar()
	
func update_charge_bar() -> void:
	charge_bar.value = charge_power
	
func check_charge_collisions() -> void:
	if not is_charging:
		return

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()

		if collider.has_method("break_block"):
			collider.break_block()

			# Preserve charge speed after hitting a block.
			velocity.x = charge_direction * charge_speed
