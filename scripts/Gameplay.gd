extends Node2D


onready var player2 = $Player2


# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().is_network_server():
		# For the server, give control of player 2 to the other peer.
		player2.set_network_master(get_tree().get_network_connected_peers()[0])
	else:
		# For the client, give control of player 2 to itself.
		player2.set_network_master(get_tree().get_network_unique_id())
	print("unique id: ", get_tree().get_network_unique_id())


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
