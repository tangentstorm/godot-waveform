tool class_name WaveformPanel extends PanelContainer

func _ready():
	pass

func edit_sample(sample:AudioStreamSample):
	edit_path(sample.resource_path)

func edit_path(path):
	# load a new copy (if one exists), bypassing the cache:
	var exists = File.new().file_exists(path)
	var sample = ResourceLoader.load(path, "AudioStreamSample", true) if exists else null
	find_node("WaveControl").sample = sample

	var led = find_node("led_path")
	# setting led.text doesn't emit the signal, so do it manually:
	led.text = path; led.emit_signal("text_changed", path)
