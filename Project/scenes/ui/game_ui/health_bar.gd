extends ProgressBar

@onready var dmgTimer: Timer = $DamageDelay
@onready var dmgBar: ProgressBar = $RecentDamageBar

var tween: Tween

func _ready() -> void:
	await get_tree().process_frame
	dmgBar.value = dmgBar.max_value

func changed(_old: float, new: float) -> void:
	value = new
	if tween and tween.is_running():
		tween.stop()
	dmgTimer.start()
	dmgBar.modulate = Color.WHITE
	var flashTween := create_tween()
	flashTween.tween_interval(0.15)
	flashTween.tween_property(dmgBar, "modulate", Color(0.973, 0.678, 0.675), 0.2)

func maxChanged(_old: float, new: float) -> void:
	max_value = new
	dmgBar.max_value = new

func _on_damage_delay_timeout() -> void:
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(dmgBar, "value", value, 0.5)
