extends ProgressBar

@onready var dmgTimer: Timer = $DamageDelay
@onready var dmgBar: ProgressBar = $RecentDamageBar

var tween: Tween

func changed(old: float, new: float) -> void:
	value = new
	if tween and tween.is_running():
		tween.stop()
	dmgTimer.start()

func maxChanged(old: float, new: float) -> void:
	max_value = new
	dmgBar.max_value = new

func _on_damage_delay_timeout() -> void:
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(dmgBar, "value", value, 0.5)
