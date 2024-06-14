extends TextureButton

@onready var itemName = $BackgroundColor/LabelItemName
@onready var itemDescription = $BackgroundColor/LabelItemDescription
@onready var itemLevel = $BackgroundColor/LabelItemLevel
@onready var itemIcon = $BackgroundColor/BackgroundItemColor/ItemIcon
@onready var backgroundColor = $BackgroundColor

var item = null
@onready var player = get_tree().get_first_node_in_group("player")

signal selected_upgrade(upgrade)

func _ready() -> void:
	connect("selected_upgrade", Callable(player, "upgrade_character"))
	if item == null:
		item = "food"
	itemName.text = UpgradeDb.UPGRADES[item]["displayname"]
	itemDescription.text = UpgradeDb.UPGRADES[item]["details"]
	itemLevel.text = UpgradeDb.UPGRADES[item]["level"]
	itemIcon.texture = load(UpgradeDb.UPGRADES[item]["icon"])
	
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
