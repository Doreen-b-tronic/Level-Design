extends Node2D

# Only the levels that exist
var levels = [
	"res://levels/level_1.tscn",
	"res://levels/level_2.tscn"
]

var current_index := 0
var current_level : Node = null

const WIN_DELAY := 1.5

func _ready() -> void:
	load_level(0)
	Global.game_ended.connect(_on_game_ended)


func load_level(index: int) -> void:
	if current_level:
		current_level.queue_free()

	current_index = index

	var scene = load(levels[index]).instantiate()
	$LevelContainer.add_child(scene)
	current_level = scene

	print("[main] Loaded level:", levels[index])

	if $HUD.has_method("clear_endings"):
		$HUD.clear_endings()


func next_level() -> void:
	var next_index = current_index + 1
	if next_index < levels.size():
		load_level(next_index)
	else:
		print("[main] All levels complete!")
		if $HUD.has_method("show_final_message"):
			$HUD.show_final_message("🎉 You finished all levels! 🎉")


func _on_game_ended(ending: Global.Endings) -> void:
	print("[main] game_ended signal received. ending =", ending)

	if ending == Global.Endings.WIN:
		await get_tree().create_timer(WIN_DELAY).timeout
		if $HUD.has_method("clear_endings"):
			$HUD.clear_endings()
		next_level()
	elif ending == Global.Endings.LOSE:
		await get_tree().create_timer(WIN_DELAY).timeout
		if $HUD.has_method("clear_endings"):
			$HUD.clear_endings()
		load_level(current_index)  # restart same level
