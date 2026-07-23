extends Node2D

const INFECTED_PIECES := [
	"InfectedBot",
	"InfectedLeft",
	"InfectedMid",
	"InfectedRight",
	"InfectedTop",
]

@onready var healthy_sprite: Sprite2D = $Healthy
@onready var branchesLabel: Label = $HUD/MarginContainer/HBoxContainer/Wave/HBoxContainer/MarginContainer2/CurrentBranches
@onready var completion_container: Container = $HUD/ReturnBox
@onready var completion_button: Button = $HUD/ReturnBox/ReturnButton

var infected_sprites: Array[Sprite2D] = []
var active_pieces: Array[Sprite2D] = []
var healthy_base_image: Image
var healthy_cut_image: Image
var healthy_cut_texture: ImageTexture
var dragging := false
var last_mouse_position := Vector2.ZERO


func _ready() -> void:
	_prepare_healthy_cutout()
	_cache_infected_sprites()
	_setup_random_infected_visibility()
	updateBranchLabel(str(active_pieces.size()))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			last_mouse_position = get_global_mouse_position()
			_check_drag_path(last_mouse_position, last_mouse_position)
		else:
			dragging = false
		return

	if event is InputEventMouseMotion and dragging:
		var current_mouse_position := get_global_mouse_position()
		_check_drag_path(last_mouse_position, current_mouse_position)
		last_mouse_position = current_mouse_position


func _cache_infected_sprites() -> void:
	infected_sprites.clear()
	for piece_name in INFECTED_PIECES:
		var sprite := get_node_or_null(piece_name) as Sprite2D
		if sprite:
			infected_sprites.append(sprite)


func _prepare_healthy_cutout() -> void:
	if healthy_sprite.texture == null:
		return

	healthy_base_image = healthy_sprite.texture.get_image()
	if healthy_base_image == null:
		return

	healthy_cut_image = healthy_base_image.duplicate()
	healthy_cut_texture = ImageTexture.create_from_image(healthy_cut_image)
	healthy_sprite.texture = healthy_cut_texture


func _setup_random_infected_visibility() -> void:
	for sprite in infected_sprites:
		sprite.visible = false

	active_pieces.clear()

	var count := randi_range(1, 3)
	var pool := infected_sprites.duplicate()

	for i in count:
		if pool.is_empty():
			break
		var index := randi_range(0, pool.size() - 1)
		var chosen: Sprite2D = pool[index]
		pool.remove_at(index)
		chosen.visible = true
		active_pieces.append(chosen)


func _check_drag_path(from_point: Vector2, to_point: Vector2) -> void:
	if active_pieces.is_empty():
		return

	if from_point.distance_to(to_point) < 1.0:
		_check_mouse_point(to_point)
		return

	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(from_point, to_point)
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var result := space_state.intersect_ray(query)
	while not result.is_empty():
		var collider: Object = result["collider"]
		var hit_area := collider as Area2D
		if hit_area:
			_clip_piece_for_area(hit_area)

		var hit_position: Vector2 = result["position"]
		var remaining_length := to_point.distance_to(hit_position)
		if remaining_length <= 1.0:
			break

		var new_from := hit_position + (to_point - from_point).normalized() * 0.5
		query = PhysicsRayQueryParameters2D.create(new_from, to_point)
		query.collide_with_areas = true
		query.collide_with_bodies = false
		result = space_state.intersect_ray(query)


func _check_mouse_point(point: Vector2) -> void:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var results := space_state.intersect_point(query)
	for result in results:
		var collider: Object = result["collider"]
		var hit_area := collider as Area2D
		if hit_area:
			_clip_piece_for_area(hit_area)


func _clip_piece_for_area(area: Area2D) -> void:
	var sprite := area.get_parent() as Sprite2D
	if sprite == null or not active_pieces.has(sprite):
		return

	active_pieces.erase(sprite)
	_apply_cutout_from_sprite(sprite)
	sprite.visible = false
	print("Trimmed a branch")
	updateBranchLabel(str(active_pieces.size()))
	

	area.monitoring = false
	area.monitorable = false

	for child in area.get_children():
		var collision_shape := child as CollisionShape2D
		if collision_shape:
			collision_shape.disabled = true

	if active_pieces.is_empty():
		print("Branches Trimmed")
		completion_container.visible = true
		#_on_branch_trimmed()


func _on_branch_trimmed() -> void:
	print("Branch trimmed")
	get_tree().change_scene_to_file("res://main/scenes/levels/minigames/TreeTrim.tscn")


func _apply_cutout_from_sprite(sprite: Sprite2D) -> void:
	if healthy_cut_image == null or healthy_base_image == null or sprite.texture == null:
		return

	var source_image := sprite.texture.get_image()
	if source_image == null:
		return

	var source_size := source_image.get_size()
	var target_size := healthy_cut_image.get_size()

	for y in range(source_size.y):
		for x in range(source_size.x):
			var source_color := source_image.get_pixel(x, y)
			if source_color.a <= 0.01:
				continue

			var source_local := Vector2(x, y)
			if sprite.centered:
				source_local -= source_size / 2.0

			var world_point := sprite.to_global(source_local)
			var healthy_local := healthy_sprite.to_local(world_point)
			var healthy_pixel := healthy_local
			if healthy_sprite.centered:
				healthy_pixel += target_size / 2.0

			var px := int(round(healthy_pixel.x))
			var py := int(round(healthy_pixel.y))

			if px < 0 or py < 0 or px >= target_size.x or py >= target_size.y:
				continue

			var current_color := healthy_cut_image.get_pixel(px, py)
			current_color.a = 0.0
			healthy_cut_image.set_pixel(px, py, current_color)

	healthy_cut_texture.update(healthy_cut_image)

func updateBranchLabel(text: String):
	branchesLabel.text = text

func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main/scenes/levels/minigames/TreeTrim.tscn")
