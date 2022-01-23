extends Node

var canvaslayer
var time_to_intro = 1
var bat:FlyingCreature

var dialog_trigger_count = {}

func _process(delta):
	if not canvaslayer:
		canvaslayer = get_tree().root.get_node("prototype/CanvasLayer")
		return
	if not bat:
		bat = get_tree().get_nodes_in_group("player")[0]
		return
	if time_to_intro > 0:
		time_to_intro -= delta
		if time_to_intro <= 0 and bat.near_rafter:
			play_dialog("Intro", "once")
			
func pause_gameplay():
	get_tree().paused = true

func unpause_gameplay(_timeline_name):
	get_tree().paused = false
			
func play_dialog(timeline, times):
	if times == "once" and timeline in dialog_trigger_count:
		return
	dialog_trigger_count[timeline] = 1
	pause_gameplay()
	var d = Dialogic.start("Intro", '', "res://addons/dialogic/Nodes/DialogNode.tscn",  false, true)
	canvaslayer.call_deferred('add_child', d)
	d.connect("timeline_end", self, "unpause_gameplay")
