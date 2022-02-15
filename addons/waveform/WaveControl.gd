tool extends Control

signal notify(sample)

export var sample : AudioStreamSample setget _set_sample,_get_sample
export var start  : float = 0.0
export var end    : float = 0.0
export var head   : float = 0.0 setget _set_head
export var timeScale : int = 128 setget _set_timeScale, _get_timeScale

var selection : Vector2 = Vector2.ZERO  # x=start,y=end (in seconds)
var playing = false
var mix_rate = 44100
var bytesPerSample : int = 4

func get_recorder():
	var idx = AudioServer.get_bus_index("Record")
	return AudioServer.get_bus_effect(idx,0)

func _set_timeScale(x):
	$AudioClip.timeScale = x

func _get_timeScale():
	return $AudioClip.timeScale

func _set_sample(x):
	start = 0.0
	self.head = start
	end = 0.0 if x == null else x.get_length()
	mix_rate = 44100 if x == null else x.mix_rate
	$AudioClip.sample = x
	$AudioClip.rect_size.x = timeToPixels(x.get_length())
	emit_signal("notify", x)

func _get_sample():
	return $AudioClip.sample

func _set_head(x):
	head = x
	$PlayHead.rect_position.x = timeToPixels(x)

func play():
	if $AudioClip.sample == null: return
	if head >= end: head = start
	playing = true
	$AudioStreamOut.stream = $AudioClip.sample
	print("end is:", end)
	print("length is:", $AudioClip.sample.get_length())
	print("playing from ", head)
	$AudioStreamOut.play(head)
	yield($AudioStreamOut, "finished")

func stop():
	self.playing = false
	$AudioStreamOut.stop()

func timeToPixels(t:float) -> float:
	return t * mix_rate / timeScale

func pixelsToTime(px:float) -> float:
	return px * timeScale / mix_rate

func pixelsToIndex(px:float) -> int:
	return timeScale * bytesPerSample * int(floor(px))

var mouse_xy0 : Vector2 = Vector2.ZERO
var mouse_down : bool = false
var mouse_drag : bool = false
func _gui_input(event):

	if event is InputEventKey:
		if event.echo and event.pressed: return # ignore repeat keys
		if event.pressed:
			match event.scancode:
				KEY_HOME: head = 0.0
				KEY_END: delete_selection()
				KEY_DELETE: delete_selection()
				KEY_SPACE: stop() if playing else play()
				KEY_INSERT:
					$AudioStreamIn.playing = true
					get_recorder().set_recording_active(true)
		else:
			match event.scancode:
				KEY_INSERT:
					var rec = get_recorder()
					var clip = rec.get_recording()
					print("DONE RECORDING. recorder:", rec)
					print("CLIP:", clip)
					insert_sample(clip)
					rec.set_recording_active(false)

	if mouse_down and event is InputEventMouseMotion:
		var x = event.position.x
		if ! mouse_drag:
			mouse_drag = true
			$Selection.visible = true
		if event.position.x < mouse_xy0.x:
			# if drag left, move start instead of head
			selection.x = x
			self.head = pixelsToTime(x)
		else:
			selection.y = x
		$Selection.rect_position.x = selection.x
		$Selection.rect_size.x = selection.y - selection.x

	if event is InputEventMouseButton and event.button_index == 1:
		if event.pressed:
			grab_focus()
			mouse_down = true
			mouse_xy0 = event.position
			$Selection.visible = false
			var x = event.position.x
			selection = Vector2(x,x)
			self.head = pixelsToTime(x)
		else: # mouse up (not mouse over, because button_index = 0)
			mouse_down = false
			$Selection.visible = mouse_drag and selection.x != selection.y
			mouse_drag = false

func insert_sample(x):
	var s = self.sample
	if s == null: s = x
	else:
		var d = s.data
		# todo: replace selection with new clip
		d.append_array(x.data)
		s.data = d
	self.sample = s

func delete_selection():
	var s = self.sample
	if s and $Selection.visible:
		var a = pixelsToIndex(selection.x)
		var Z = s.data.size()-1
		var z = int(min(Z, pixelsToIndex(selection.y)))
		var d = PoolByteArray()
		if a>0: d.append_array(s.data.subarray(0,a-1))
		if z<Z: d.append_array(s.data.subarray(z, s.data.size()-1))
		s.data = d
		self.sample = s

func _process(dt):
	if playing:
		self.head += dt
		if self.head > self.end:
			playing = false

