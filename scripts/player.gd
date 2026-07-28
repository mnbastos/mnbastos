extends CharacterBody3D

#========================
# VELOCIDADE
#========================
@export var MAX_SPEED := 10.0
@export var REVERSE_SPEED := 4.0

@export var ACCELERATION := 5.0
@export var BRAKE_FORCE := 40.0
@export var FRICTION := 10.0

#========================
# DIREÇÃO
#========================
@export var STEERING_SPEED := 2.5
@export var STEERING_SPEED_STOPPED := 1.2

#========================
# CÂMERA
#========================
@export var CAMERA_DISTANCE := 8.0
@export var CAMERA_HEIGHT := 4.0
@export var CAMERA_SMOOTH := 6.0
@export var CAMERA_LOOK_AHEAD := 4.0


#========================
# VARIÁVEIS
#========================
var speed := 0.0
var camera_angle := 0.0

@onready var camera := Camera3D.new()


func _ready():

	add_child(camera)

	camera.name = "Camera3D"
	camera.current = true

	camera.global_position = global_position \
		+ transform.basis.z * CAMERA_DISTANCE \
		+ Vector3.UP * CAMERA_HEIGHT

	camera.look_at(global_position)


func _physics_process(delta):

	_apply_gravity(delta)

	_handle_acceleration(delta)

	_handle_steering(delta)

	_move_car()

	move_and_slide()

	_update_camera(delta)


#========================
# GRAVIDADE
#========================
func _apply_gravity(delta):

	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = -0.1


#========================
# ACELERAÇÃO
#========================
func _handle_acceleration(delta):

	if Input.is_action_pressed("acelerar"):

		speed = move_toward(
			speed,
			MAX_SPEED,
			ACCELERATION * delta
		)

	elif Input.is_action_pressed("frear"):

		if speed > 0:

			speed = move_toward(
				speed,
				0.0,
				BRAKE_FORCE * delta
			)

		else:

			speed = move_toward(
				speed,
				-REVERSE_SPEED,
				ACCELERATION * delta
			)

	else:

		speed = move_toward(
			speed,
			0.0,
			FRICTION * delta
		)

	camera_angle = lerp_angle(
		camera_angle,
		rotation.y,
		2.5 * delta
	)

#========================
# DIREÇÃO
#========================
func _handle_steering(delta):

	var steering := 0.0

	if Input.is_action_pressed("direita"):
		steering += 1.0

	if Input.is_action_pressed("esquerda"):
		steering -= 1.0

	if steering == 0.0:
		return

	# Inverte ao dar ré
	if speed < 0:
		steering *= -1.0

	# Quanto menor a velocidade, menor a velocidade de giro
	var steering_speed = STEERING_SPEED

	if abs(speed) < 0.1:
		steering_speed = STEERING_SPEED_STOPPED

	rotate_y(-steering * steering_speed * delta)

#========================
# MOVIMENTO
#========================
func _move_car():

	var forward = -transform.basis.z

	velocity.x = forward.x * speed
	velocity.z = forward.z * speed


#========================
# CÂMERA
#========================
func _update_camera(delta):

	var offset = Vector3(
		sin(camera_angle),
		0,
		cos(camera_angle)
	) * CAMERA_DISTANCE

	var desired_position = global_position
	desired_position += offset
	desired_position += Vector3.UP * CAMERA_HEIGHT

	camera.global_position = camera.global_position.lerp(
		desired_position,
		CAMERA_SMOOTH * delta
	)

	var look_target = global_position
	look_target += -transform.basis.z * CAMERA_LOOK_AHEAD
	look_target += Vector3.UP * 1.5

	camera.look_at(look_target, Vector3.UP)