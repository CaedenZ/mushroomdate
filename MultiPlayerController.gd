extends Control

@export var Address = "127.0.0.1"
@export var Port = 8910
var peer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		hostgame()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func peer_connected(id):
	print("Player Connected " + str(id))
	
func peer_disconnected(id):
	print("Player Disonnected " + str(id))
	
func connected_to_server():
	print("Player connected to server ")
	SendPlayerInfo.rpc_id(1, $LineEdit.text, multiplayer.get_unique_id())

@rpc("any_peer")
func SendPlayerInfo(name,id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"name": name,
			"id": id
		}
	
	
	if multiplayer.is_server():
		for i in GameManager.players:
			SendPlayerInfo.rpc(GameManager.players[i].name, i)
func connection_failed():
	print("Player connection failed ")
	
@rpc("any_peer","call_local")	
func startgame():
	var scene = load("res://MainScene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func hostgame():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Port,4)
	if error != OK:
		print("can not host " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players")
	
func _on_host_button_down() -> void:
	hostgame()
	SendPlayerInfo($LineEdit.text, multiplayer.get_unique_id())
	
	
	pass # Replace with function body.

func _on_join_button_down() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address,Port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func _on_start_button_down() -> void:
	startgame.rpc()
