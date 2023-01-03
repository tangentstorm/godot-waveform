@tool
class_name WaveformPanel extends PanelContainer

func _ready():
	pass

func edit_sample(sample:AudioStreamWAV):
	edit_path(sample.resource_path)

func edit_path(path):
	## !! there is a small issue here. when we save some audio
	# for the first time, there is a lag before godot actually imports it.
	# in the editor plugin, we can tell godot to rescan, so it's not a problem.
	# (that happens in WaveControl.update_editor())
	#
	# Unfortunately, if we're outside the editor, we can't tell godot to
	# rescan (??? AFAIK). so loading with ResourceLoader winds up failing,
	# even though the file is there, because it hasn't been imported yet.
	#
	# unfortunately, there is no other built-in way to load a wave file.
	# It looks like someone else has dealt with this problem before,
	# and wrote a pure-gdscript loader for wave files:
	# https://github.com/Gianclgar/GDScriptAudioImport
	#
	# TODO: try this load-at-runtime solution so standalone can load/save audio

	# meanwhile, load a new copy (if one exists), bypassing the cache:
	var exists = FileAccess.file_exists(path)
	if exists: print("file exists. loading: ", path)
	else: print("path does not exist yet:", path)
	var sample:AudioStreamWAV = null
	if exists: sample = ResourceLoader.load(path, "AudioStreamWAV", true)
	print("sample that got loaded: ", sample)
	find_child("WaveControl").sample = sample

	var led = find_child("led_path")
	# setting led.text doesn't emit the signal, so do it manually:
	led.text = path; led.emit_signal("text_changed", path)
