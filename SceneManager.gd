extends Node2D

@export var PlayerScene : PackedScene
@export var bg : PackedScene

var player_count
var player_completed = 0
var scene_no = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var index = 0
	player_count = GameManager.players.size()
	
	for i in GameManager.players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(GameManager.players[i].id)
		add_child(currentPlayer)
		print(str(GameManager.players[i].id))
		print(str(multiplayer.get_unique_id()))
		if currentPlayer.name == str(multiplayer.get_unique_id()):
			var cam = Camera2D.new()
			cam.position_smoothing_enabled = true
			cam.zoom = Vector2(1.5,1.5)
			currentPlayer.add_child(cam)
			var background = bg.instantiate()
			currentPlayer.add_child(background)
			currentPlayer.add_to_group("multigameplayer")
		currentPlayer.global_position = $SpawnPoint.global_position + Vector2(100,0) * index
		index += 1
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("any_peer","call_local")
func player_complete(body: CharacterBody2D):
	body.hide()
	player_completed += 1
	print(player_completed)
	print(player_count)
	if player_completed == player_count:
		loadnextScene.rpc(scene_no + 1)

@rpc("any_peer","call_local")
func loadnextScene(scenenum):
	var index = 0
	for player:CharacterBody2D in get_tree().get_nodes_in_group("player"):
		player.global_position = get_tree().get_nodes_in_group("spawnpoint")[scenenum].global_position + Vector2(100,0) * index
		player.visible = true
		player.completed = false
		player.at_portal = false
		index += 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("multigameplayer"):
		print(body)
		print(player_completed)
		body.at_portal = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
