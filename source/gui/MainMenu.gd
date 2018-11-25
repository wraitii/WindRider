extends Control

func _on_NewGame_pressed():
	Core.create_new_game();

func _on_ResumeGame_pressed():
	Core.load_saved_game();
