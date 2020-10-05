extends Control


const PROTO_NAME = "ludus"

onready var _name = $Panel/LineEditName
onready var _host = $Panel/LineEditHost


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	get_tree().connect("network_peer_connected", self, "_peer_connected")
	
	if OS.has_environment("USERNAME"):
		_name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		_name.text = desktop_path[desktop_path.size() - 2]

func start_game():
	print("game started")

func stop_game():
	print("game stopped")

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
	var host = WebSocketServer.new()
	host.listen(8080, PoolStringArray(["ludus"]), true)
	get_tree().connect("server_disconnected", self, "_close_network")
	get_tree().set_network_peer(host)
	start_game()

func _on_JoinButton_pressed():
	var host = WebSocketClient.new()
	host.connect_to_url("ws://" + _host.text + ":" + str(8080), PoolStringArray([PROTO_NAME]), true)
	get_tree().connect("connection_failed", self, "_close_network")
	get_tree().connect("connected_to_server", self, "_connected")
	get_tree().set_network_peer(host)
	start_game()
