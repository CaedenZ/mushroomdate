extends CharacterBody2D

var MOVE_SPEED = 100
var PUSH_SPEED = 70
const JUMP_VELOCITY = -210.0
var hehe = false
var push = false
var push_direction = 0

var carried = false
var carriedby:CharacterBody2D
var carrying:CharacterBody2D
var at_portal = false
var completed = false

@export var pushForce = 70
@export var boxpushspeed = 70

func _ready() -> void:
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _physics_process(delta: float) -> void:
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		# Add the gravity.
		if not carried:
			if not is_on_floor():
				velocity += get_gravity() * delta
		else:
			position.y =carriedby.position.y + -30
			
		
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or carried):
			jump()
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		if !push:
			velocity.x = 0
		else:
			velocity.x = push_direction * 70
		if Input.is_action_pressed("ui_left"):
			velocity.x = -MOVE_SPEED
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("run")
		elif Input.is_action_pressed("ui_right"):
			velocity.x = MOVE_SPEED
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("run")
		elif Input.is_action_pressed("ui_down"):
			$AnimatedSprite2D.play("hehe")
		elif Input.is_action_just_pressed("ui_up"):
			if at_portal == true:
				complete.rpc()
				completed = true
		else:
			$AnimatedSprite2D.play("default")
			
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			var box = col.get_collider()
			if box.is_in_group("box") :
				box.linear_velocity = col.get_normal() * -boxpushspeed
			elif box.is_in_group("coil") :
				velocity.y = JUMP_VELOCITY * 2.5
		move_and_slide()
	#else:
		#global_position = global_position.lerp(syncposition, .5)
	if not is_on_floor() and not carried:
		$AnimatedSprite2D.play("jump")
			
			
func jump():
	if carrying:
		carrying.jump()
	velocity.y = JUMP_VELOCITY

@rpc("any_peer","call_local")
func complete():
	self.get_parent().player_complete(self)

func disable_down_coll():
	get_child(0).disabled = true

func enable_down_coll():
	get_child(0).disabled = false

func _on_left_area_entered(area: Area2D) -> void:
	if area.is_in_group("pusher"):
		push_direction = 1
		push = true


func _on_left_area_exited(area: Area2D) -> void:
	if area.is_in_group("pusher"):
		push_direction = 0
		push = false


func _on_right_area_entered(area: Area2D) -> void:
	if area.is_in_group("pusher"):
		push_direction = -1
		push = true


func _on_right_area_exited(area: Area2D) -> void:
	if area.is_in_group("pusher"):
		push_direction = 0
		push = false


#func _on_up_area_entered(area: Area2D) -> void:
	#if area.is_in_group("carriable"):
		#area.get_parent().carried = true
		##area.get_parent().disable_down_coll()
		#area.get_parent().carriedby = self
		#carrying = area.get_parent()
#
#func _on_up_area_exited(area: Area2D) -> void:
	#if area.is_in_group("carriable"):
		#area.get_parent().carried = false
		##area.get_parent().enable_down_coll()
		#carrying = null
