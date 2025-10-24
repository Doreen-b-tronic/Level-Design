@tool
extends CanvasLayer

# --- Onready variables ---
@onready var ending_labels = {
	Global.Endings.WIN: %WinEnding,
	Global.Endings.LOSE: %LoseEnding,
}
@onready var goal_label = %GoalLabel  # 🏁 Added goal label reference

# --- Main process updates ---
func _process(_delta):
	%TimeLeft.text = "%.1f" % Global.timer.time_left


func _ready():
	set_process(false)
	set_physics_process(false)

	Global.lives_changed.connect(_on_lives_changed)

	if Engine.is_editor_hint():
		return

	Global.coin_collected.connect(_on_coin_collected)
	Global.game_ended.connect(_on_game_ended)
	Global.timer_added.connect(_on_timer_added)

	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	if DisplayServer.is_touchscreen_available():
		%Start.hide()
		Global.game_started.emit()

	# 🏁 Show the goal message at level start
	show_goal_message("🏁 Reach the flag to win!")


# --- Input Handling ---
func _on_joy_connection_changed(index: int, connected: bool):
	match index:
		0:
			%PlayerOneJoypad.visible = connected
		1:
			%PlayerTwoJoypad.visible = connected


func _unhandled_input(event):
	if (
		(
			event is InputEventKey
			or event is InputEventJoypadButton
			or event is InputEventJoypadMotion
			or event is InputEventScreenTouch
		)
		and %Start.is_visible_in_tree()
	):
		%Start.hide()
		Global.game_started.emit()


# --- Game Event Handlers ---
func _on_coin_collected():
	set_collected_coins(Global.coins)


func set_collected_coins(coins: int):
	%CollectedCoins.text = "Coins: " + str(coins)


func _on_timer_added():
	%TimeLeft.visible = true
	set_process(true)


func _on_lives_changed():
	set_lives(Global.lives)


func set_lives(lives: int):
	%Lives.offset_right = %Lives.offset_left + lives * %Lives.texture.get_width()


func _on_game_ended(ending: Global.Endings):
	ending_labels[ending].visible = true


# --- Goal Message Display ---
func show_goal_message(text: String):
	goal_label.text = text
	goal_label.modulate.a = 1.0  # ensure visible
	goal_label.show()

	# Wait for 2.5 seconds before fade
	await get_tree().create_timer(2.5).timeout

	# Smooth fade out
	var tween = get_tree().create_tween()
	tween.tween_property(goal_label, "modulate:a", 0.0, 1.0)
	await tween.finished

	goal_label.hide()
	goal_label.modulate.a = 1.0  # reset for next time


# --- Helpers for level transitions ---
func clear_endings():
	for label in ending_labels.values():
		label.visible = false
	if has_node("FinalMessage"):
		%FinalMessage.visible = false


func show_final_message(text: String):
	if has_node("FinalMessage"):
		%FinalMessage.text = text
		%FinalMessage.visible = true
