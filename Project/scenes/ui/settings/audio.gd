extends Settings_Tab

@export var output: OptionButton

func _ready() -> void:
	output.get_popup().transparent = true
	var devices = AudioServer.get_output_device_list()
	for i in len(devices):
		output.add_item(devices[i], i)
	output.get_popup().get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST

func _on_output_item_selected(index: int) -> void:
	AudioServer.output_device = output.get_item_text(index)
