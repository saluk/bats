extends Node

var canvaslayer
var time_to_intro = 1

func _process(delta):
	if not canvaslayer:
		canvaslayer = get_tree().root.get_node("prototype/CanvasLayer")
	if time_to_intro > 0:
		time_to_intro -= delta
		if time_to_intro <= 0:
			play_dialog("Intro")
			
func pause_gameplay():
	get_tree().paused = true

func unpause_gameplay(_timeline_name):
	get_tree().paused = false
			
func play_dialog(timeline):
	pause_gameplay()
	var d = Dialogic.start("Intro", '', "res://addons/dialogic/Nodes/DialogNode.tscn",  false, true)
	canvaslayer.call_deferred('add_child', d)
	d.connect("timeline_end", self, "unpause_gameplay")
