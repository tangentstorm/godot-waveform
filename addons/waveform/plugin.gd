tool
extends EditorPlugin

var dock : Control

func handles(object)->bool:
	if object is AudioStreamSample:
		var cs = dock.find_node("WaveControl")
		var lp:LineEdit = dock.find_node("led_path")
		cs.sample = object
		lp.text = object.resource_path
		return true
	else: return false

func make_visible(visible):
	if visible: make_bottom_panel_item_visible(dock)

func _enter_tree():
	dock = preload("res://addons/waveform/waveform_panel.tscn").instance()
	add_control_to_bottom_panel(dock, "Waveform")

func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.queue_free()
