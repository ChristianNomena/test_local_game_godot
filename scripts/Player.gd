extends KinematicBody2D


const PESANTEUR = 1.5
const GRAVITY = 1000 * PESANTEUR
const UP = Vector2(0, -1) # Indique le plancher (floor)
const ACCELERATION = 10
const DECELERATION = 0.12

var _velocity

export (int) var max_speed = 400
export (int) var jump_height = 750


# Called when the node enters the scene tree for the first time.
func _ready():
	self._velocity = Vector2()


func _physics_process(delta):
	self._movement_loop()
	
	self._velocity.y += GRAVITY * (delta)
	self._velocity = self.move_and_slide(_velocity, UP)


func _movement_loop():
	var left = Input.is_action_pressed("player_left")
	var right = Input.is_action_pressed("player_right")
	var jump = Input.is_action_just_pressed("player_jump")
	
	var direction_horizontal = int(right) - int(left)
	
	if direction_horizontal == 1:
		self._velocity.x = min(self._velocity.x + ACCELERATION, max_speed)
		$Sprite.flip_h = false
	elif direction_horizontal == -1:
		self._velocity.x = max(self._velocity.x - ACCELERATION, -max_speed)
		$Sprite.flip_h = true
	else:
		self._velocity.x = lerp(self._velocity.x, 0, DECELERATION)

	if jump and self.is_on_floor():
		_velocity.y = -self.jump_height

