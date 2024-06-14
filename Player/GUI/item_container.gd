extends TextureRect

var upgrade = null

func _ready():
	if upgrade != null:
		$ItemTexture.texture = load(UpgradeDb.UPGRADES[upgrade]["icon"])
		$LabelItemNumber.text = UpgradeDb.UPGRADES[upgrade]["level"]

func update_level(update_upgrade):
	$LabelItemNumber.text = UpgradeDb.UPGRADES[update_upgrade]["level"]
