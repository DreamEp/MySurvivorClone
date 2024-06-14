extends Button

signal click_end()

func _on_mouse_entered():
	$snd_hover.play()

func _on_pressed():
	$snd_click.play()

#Permet de s'assurer que le son du bouton soit joué jusqu'a la fin avant de faire quoi que ce soit
func _on_snd_click_finished():
	emit_signal("click_end")
