#  Static class with some node helper functions

extends Reference
class_name Nodes

static func clean_node_array(array):
	var new_array = []
	for node in array:
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			new_array.append(node)
	return new_array
