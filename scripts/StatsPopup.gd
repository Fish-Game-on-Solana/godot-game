extends Control

func show_stats(wallet: String, holding: String, position: Vector2) -> void:
	$LabelWallet.text = "Address: %s" % wallet
	$LabelHolding.text = "Holdings: %s" % holding
	
	# Just set position with a small offset
	self.position = position + Vector2(10, -10)
	visible = true


func hide_stats() -> void:
	visible = false
