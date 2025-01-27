extends RigidBody2D
class_name Crate

@export var mu_static := 0.8  # friction coefficients
@export var mu_moving := 0.5  # pushing something moving is easier


@export var move_strength := 50.0

var applied_forces: Vector2 = Vector2(0, 0)

func add_force_for_frame(force: Vector2):
	# add_force adds a permanent force, for a temporary one we need to wipe it
	# by undo the force next frame, just keep track of forces applied
	applied_forces += force
	self.add_constant_central_force(force)

func _physics_process(delta: float) -> void:
	add_force_for_frame(-applied_forces) # wipe out previous forces

	if self.linear_velocity.length() == 0:
		self.add_force_for_frame(- self.mass * mu_static * self.linear_velocity.normalized())
	else:
		self.add_force_for_frame(- self.mass * mu_moving * self.linear_velocity.normalized())
