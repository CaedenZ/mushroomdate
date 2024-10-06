extends Node2D

@export var scene:Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
	if body.is_in_group("multigameplayer"):
		print(scene.player_completed)
		body.at_portal = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
