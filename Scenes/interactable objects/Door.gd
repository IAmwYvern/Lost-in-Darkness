extends Area2D

signal page_changed
signal player_entered(scene_name)

const DIALOGUE_BOX_SCENE = preload("res://Scenes/GUI/DialogueBox.tscn")

onready var InventoryGUI 

var player_is_colliding : bool
var player_is_looking : bool
var required_item : Item

export(String) var scene_name : String
export(bool) var locked : bool 
export(String) var locked_text : String
export(String) var unlocked_text : String
export(String) var key_name : String 
export(bool) var unlock_on_interact : bool = false
export(NodePath) var inv_gui_path : NodePath 
export(Vector2) var required_look_dir : Vector2

func _ready() -> void:
	var game_node = get_node("/root/Game")
	connect("player_entered", game_node, "_on_Door_player_entered")
	locked_text = "[center]" + locked_text + "[/center]"
	required_item = Item.new(key_name, 1, null, Item.ITEM_TYPES.KEY_ITEM)
	$CanvasLayer/Sprite.visible = true
	$CanvasLayer/Sprite/AnimationPlayer.play("fade out")

func _process(delta : float) -> void:
	InventoryGUI = get_node(inv_gui_path)
	var interact = Input.is_action_just_pressed("interact")

	# things that prevent the player from opening the door
	if not InventoryGUI:
		return
	if InventoryGUI.visible:
		return
	if not  $"../Player".look_dir == required_look_dir:
		return
	if not player_is_colliding :
		return

	# nothing preventing the player from opening the door
	if  interact:
		if not locked and scene_name:
			$CanvasLayer/Sprite/AnimationPlayer.play("fade in")
			$Sounds/Open.play()
		elif locked:
			if InventoryHandler.get_item(required_item) != -1:
				locked = false
				$Sounds/Unlocked.play()
				return
			if get_node("DialogueBox"):
				get_node("DialogueBox").queue_free()
				DialogueHandler.emit_signal("player_unpause")
				DialogueHandler.dialogue_open = false
			else:
				$Sounds/Locked.play()
				var dialogue_box = DIALOGUE_BOX_SCENE.instance()
				add_child(dialogue_box)
				dialogue_box.get_node("Panel/Label").bbcode_text = locked_text
				DialogueHandler.emit_signal("player_pause")
				DialogueHandler.dialogue_open = true
		
func _on_Door_body_entered(body : Node) -> void:
	if body is Player:
		player_is_colliding = true

func _on_Door_body_exited(body : Node) -> void:
	if body is Player:
		player_is_colliding = false

func _on_Open_finished():
	emit_signal("player_entered", scene_name)
	InventoryGUI.refresh_inventory()
	$CanvasLayer/Sprite/AnimationPlayer.play("fade out")
