extends VBoxContainer

@export var bus: String = "Master"
@export var text: String = "Master Volume"

@onready var label: Label = $Label
@onready var slider: HSlider = $HSlider
@onready var feedback: AudioStreamPlayer = $Feedback

var busID = 0

func _ready() -> void:
	label.text = text
	busID = AudioServer.get_bus_index(bus)
	feedback.bus = bus
	if !Config.firstBoot:
		slider.value = Config.retrieveSetting("audio/%s" % bus.replace(" ", "_"))

func _on_h_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(busID, value)

func _on_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		feedback.play()
		Config.updateSetting("audio/%s" % bus.replace(" ", "_"), slider.value)
