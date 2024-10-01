extends CharacterBody2D

var MOVE_SPEED = 100
var PUSH_SPEED = 70
const JUMP_VELOCITY = -180.0
var hehe = false
var push = false
var push_direction = 0

var carried = false
var carriedby:CharacterBody2D
var carrying:CharacterBody2D
var at_portal = false
var completed = false

func _ready() -> void:
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _physics_process(delta: float) -> void:
	if not completed:
		if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
			# Add the gravity.
			if not carried:
				if not is_on_floor():
					velocity += get_gravity() * delta
			else:
				position.y =carriedby.position.y + -30
				
			if is_on_floor():
				var highest_y = 0
				for moving_platform: CharacterBody2D in $down.get_overlapping_bodies(): # only check moving platforms layer
					highest_y = moving_platform.velocity.y # moving platforms need to expose their velocity
				velocity.y += highest_y # apply vertical platform movement
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
				
			
			move_and_slide()
		#else:
			#global_position = global_position.lerp(syncposition, .5)
		if not is_on_floor() and not carried:
			$AnimatedSprite2D.play("jump")
	else:
		velocity = Vector2(0,0)
		if Input.is_action_pressed("ui_left"):
			velocity.x = -MOVE_SPEED * 3
		elif Input.is_action_pressed("ui_right"):
			velocity.x = MOVE_SPEED * 3
		elif Input.is_action_pressed("ui_down"):
			velocity.y = MOVE_SPEED * 3
		elif Input.is_action_pressed("ui_up"):
			velocity.y = -MOVE_SPEED * 3
		move_and_slide()
			
func jump():
	print(carrying)
	if carrying:
		carrying.jump()
	velocity.y = JUMP_VELOCITY

@rpc("any_peer","call_local")
func complete():
	self.get_parent().player_complete(self)

func disable_down_coll():
	print("disabled")
	get_child(0).disabled = true

func enable_down_coll():
	print("enabled")
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
	##print(carriedObject)
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
