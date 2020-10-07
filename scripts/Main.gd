extends Control


const PROTO_NAME = "ludus"

export var DEFAULT_PORT = 8092

onready var _name = $Panel/LineEditName
onready var _host = $Panel/LineEditAddress


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	if OS.has_environment("USERNAME"):
		_name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		_name.text = desktop_path[desktop_path.size() - 2]


func _player_connected(_id):
	# Someone connected, start the game!
	var game = load("res://scenes/gameplay.tscn").instance()
	# Connect deferred so we can safely erase it from the callback.
	game.connect("game_finished", self, "_end_game", [], CONNECT_DEFERRED)
	
	get_tree().get_root().add_child(game)
	hide()


func _player_disconnected(_id):
	if get_tree().is_network_server():
		_end_game("Client disconnected")
	else:
		_end_game("Server disconnected")


func _connected_ok():
	_set_status("Connection established")


func _connected_fail():
	_set_status("Couldn't connect")
	get_tree().set_network_peer(null)


func _server_disconnected():
	_end_game("Server disconnected")


func _end_game(with_error = ""):
	if has_node("/root/Player"):
		# Erase immediately, otherwise network might show errors (this is why we connected deferred above).
		get_node("/root/Player").free()
		show()
	
	get_tree().set_network_peer(null) # Remove peer.
	_set_status(with_error)

func _set_status(text):
	$Panel/LabelStatus.show()
	$Panel/LabelStatus.text = text


func start_game():
	print("game started")
	_set_status("game started")


func stop_game():
	print("game stopped")
	_set_status("game stopped")


func _close_network():
	if get_tree().is_connected("server_disconnected", self, "_close_network"):
		get_tree().disconnect("server_disconnected", self, "_close_network")
	if get_tree().is_connected("connection_failed", self, "_close_network"):
		get_tree().disconnect("connection_failed", self, "_close_network")
	if get_tree().is_connected("connected_to_server", self, "_connected"):
		get_tree().disconnect("connected_to_server", self, "_connected")
	stop_game()
	get_tree().set_network_peer(null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HostButton_pressed():
#	var host = WebSocketServer.new()
#	host.listen(DEFAULT_PORT, PoolStringArray(["ludus"]), true)
#	get_tree().connect("server_disconnected", self, "_close_network")
#	get_tree().set_network_peer(host)
#	start_game()

	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = host.create_server(DEFAULT_PORT, 1) # Maximum of 1 peer, since it's a 2-player game.
	if err != OK:
		# Is another server running?
		_set_status("Can't host, address in use.")
		return
	
	get_tree().set_network_peer(host)
	_set_status("Waiting for player...")


func _on_JoinButton_pressed():
#	var host = WebSocketClient.new()
#	host.connect_to_url("ws://" + _host.text + ":" + str(DEFAULT_PORT), PoolStringArray([PROTO_NAME]), true)
#	get_tree().connect("connection_failed", self, "_close_network")
#	get_tree().connect("connected_to_server", self, "_connected")
#	get_tree().set_network_peer(host)
#	start_game()

	var ip = _host.text
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid")
		return
	
	var host = NetworkedMultiplayerENet.new()
	host.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)
	
	_set_status("Connecting...")
