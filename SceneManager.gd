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
			var remote:RemoteTransform2D = currentPlayer.get_child(0)
			remote.remote_path = $Camera2D.get_path()
			currentPlayer.add_to_group("multigameplayer")
		currentPlayer.global_position = $SpawnPoint.global_position + Vector2(100,0) * index
		index += 1
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

@rpc("any_peer","call_local")
func player_complete(body: CharacterBody2D):
	body.queue_free()
	player_completed += 1
	print(player_completed)
	print(player_count)
	if player_completed == player_count:
		loadnextScene(scene_no + 1)

#@rpc("any_peer","call_local")
func loadnextScene(scenenum):
	Transitions.transition()
	await Transitions.on_transition_finished
	var index = 0
	player_completed = 0
	for i in GameManager.players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(GameManager.players[i].id)
		add_child(currentPlayer)
		print(str(GameManager.players[i].id))
		print(str(multiplayer.get_unique_id()))
		if currentPlayer.name == str(multiplayer.get_unique_id()):
			var remote:RemoteTransform2D = currentPlayer.get_child(0)
			remote.remote_path = $Camera2D.get_path()
			currentPlayer.add_to_group("multigameplayer")
		currentPlayer.global_position = get_tree().get_nodes_in_group("spawnpoint")[scenenum].global_position + Vector2(100,0) * index
		index += 1
		
