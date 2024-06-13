extends TextureButton

var item = null
@onready var player = get_tree().get_first_node_in_group("player")
@onready var backgroundColor = $BackgroundColor

signal selected_upgrade(upgrade)

func _ready() -> void:
	connect("selected_upgrade", Callable(player, "upgrade_character"))

func _on_pressed()-> void:
	selected_upgrade.emit(item)


func _on_mouse_entered():
	#On a changé le pivot pour être au milieu comme ça notre tween fait le scale depuis le centre
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1) * 1.025, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.play()
	backgroundColor.color = Color.WEB_GRAY

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.play()
	backgroundColor.color = Color.DARK_GRAY
