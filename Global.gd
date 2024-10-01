extends Node

#Steam Variable
var OWNED = false
var ONLINE = false
var STEAM_ID = 0
var STEAM_NAME = ""

#Lobby Variable
var DATA
var LOBBY_ID
var LOBBY_MEMBERS = []
var LOBBY_INVITE_ARG = false

#func _ready() -> void:
	#var INIT = Steam.steamInit()
	#if INIT['status'] != 1:
		#print("Fail to initialise Steam. " + str(INIT["verbal"]) + " Shutting down...")
		#get_tree().quit()
		#
	#ONLINE = Steam.loggedOn()
	#STEAM_ID = Steam.getSteamID()
	#STEAM_NAME = Steam.getPersonalName()
