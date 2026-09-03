extends Node2D

@onready var tree_nodes: Array[TreeTrim] = [$Tree, $Tree2, $Tree3]
@onready var completion_container: Container = $HUD/ReturnBox
@onready var completion_button: Button = $HUD/ReturnBox/ReturnButton
@onready var branchesLabel: Label = $HUD/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer2/CurrentBranches

func _ready() -> void:
	if PlayerData.infected_trees.is_empty() and PlayerData.trimed_trees.is_empty():
		_randomize_infected_trees()

	for i in range(tree_nodes.size() - 1, -1, -1):
		var node: TreeTrim = tree_nodes[i]
		node.infected = (
			node.name in PlayerData.infected_trees
		and node.name not in PlayerData.trimed_trees
		)
		node._ready()

		if not node.infected:
			tree_nodes.remove_at(i)
	
	branchesLabel.text = str(tree_nodes.size())
	
	if (_all_trees_cleared()):
		completion_container.visible = true

func _randomize_infected_trees() -> void:
	var shuffled_trees: Array[TreeTrim] = tree_nodes.duplicate()
	shuffled_trees.shuffle()
	var infected_count := randi_range(1, shuffled_trees.size())

	for i in range(infected_count):
		PlayerData.infected_trees.append(shuffled_trees[i].name)


func _on_static_body_clicked(viewport: Viewport, event: InputEvent, shape_idx: int, treeName: String) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var treeNode: TreeTrim = getTreeNodeFromName(treeName)
		if treeNode && treeNode.infected:
			print("Clicked tree: ", treeNode.name, " healthy=", treeNode.infected)
			PlayerData.add_trimmed_tree_name(treeNode.name)
			get_tree().change_scene_to_file("res://main/scenes/levels/minigames/BranchTrim.tscn")

func _all_trees_cleared() -> bool:
	for node in tree_nodes:
		if node and node.infected:
			return false
	return true

func getTreeNodeFromName(name: String) -> TreeTrim:
	for node in tree_nodes:
		if (node.name == name):
			return(node)
	return null


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main/scenes/levels/platforming/Platforming.tscn")
