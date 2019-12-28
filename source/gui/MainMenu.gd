extends Control

func _on_NewGame_pressed():
	Core._on_new_game();

func _on_ResumeGame_pressed():
	Core._onload_saved_game();
