extends Settings_Tab

@onready var output: OptionButton = $VBoxContainer/Content/MarginContainer/VBoxContainer/Output

func _ready() -> void:
	output.get_popup().transparent = true
	var devices = AudioServer.get_output_device_list()
	for i in len(devices):
		output.add_item(devices[i], i)

func _on_output_item_selected(index: int) -> void:
	AudioServer.output_device = output.get_item_text(index)
