extends RigidBody2D

@export var replicated_position : Vector2
@export var replicated_rotation : float
@export var replicated_linear_velocity : Vector2
@export var replicated_angular_velocity : float

const MOVE_SPEED = 150
const JUMP_VELOCITY = 300.0
@onready
var just_aired_timer : Timer = $JustAiredTimer
@onready
var _transitions := {
	IDLE:[RUN,AIR],
	RUN:[IDLE,AIR],
	AIR:[IDLE]
}
@onready
var sync:MultiplayerSynchronizer = $MultiplayerSynchronizer
enum {IDLE,RUN,AIR,}
var _state:int = IDLE
var states_strings := {
	IDLE:"idle",
	RUN:"run",
	AIR:"air",
}
func _ready() -> void:
	sync.set_multiplayer_authority(str(name).to_int())
	$Label.text = name
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	
	
	if sync.get_multiplayer_authority() == multiplayer.get_unique_id():
		var is_on_ground := state.get_contact_count() > 0 and int(state.get_contact_collider_position(0).y) >= int(global_position.y)
		state.get_contact_count()
		var move_direction := get_move_direction()
		match _state:
			IDLE:
				$AnimatedSprite2D.play("default")
				if move_direction.x:
					change_state(RUN)
				elif is_on_ground and Input.is_action_just_pressed("ui_accept"):
					state.linear_velocity.y += -JUMP_VELOCITY
					change_state(AIR)
					
			RUN:
				$AnimatedSprite2D.play("run")
				if not move_direction.x:
					change_state(IDLE)
				elif state.get_contact_count() == 0:
					change_state(AIR)
				elif is_on_ground and Input.is_action_just_pressed("ui_accept"):
					state.linear_velocity.y += -JUMP_VELOCITY
					change_state(AIR)
				else:
					state.linear_velocity.x = move_direction.x * MOVE_SPEED
					
			AIR:
				$AnimatedSprite2D.play("jump")
				if move_direction.x :
					state.linear_velocity.x = move_direction.x * MOVE_SPEED
				else:
					state.linear_velocity.x = 0
				if is_on_ground and just_aired_timer.is_stopped():
					change_state(IDLE)

func change_state(target_state: int) -> void:
	if not target_state in _transitions[_state]:
		return
	_state = target_state
	enter_state()
	
func enter_state() -> void:
	match _state:
		IDLE:
			linear_velocity.x = 0
		AIR:
			just_aired_timer.start()
		_:
			return
			
func get_move_direction() -> Vector2:
	var dir = Vector2(0,0)
	if Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
		dir.x = -1
	elif !Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right"):
		dir.x = 1
	else:
		dir.x = 0
	return dir
