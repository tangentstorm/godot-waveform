@tool
extends EditorPlugin

var dock : WaveformPanel

func handles(object)->bool:
	if object is AudioStreamWAV:
		dock.edit_sample(object)
		return true
	else: return false

func _make_visible(visible):
	if visible: make_bottom_panel_item_visible(dock)

func _enter_tree():
	dock = preload("res://addons/waveform/waveform_panel.tscn").instantiate()
	add_control_to_bottom_panel(dock, "Waveform")

func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.queue_free()
