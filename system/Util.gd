extends Reference
class_name Util

static func replace_node(node:Node, replacement:Node) -> Node:
	# replace node in the tree with the replacement at the same position
	var parent:Node = node.get_parent()
	var index = node.get_index()
	var replacement_parent:Node = replacement.get_parent()
	if replacement_parent:
		replacement_parent.remove_child(replacement)
	parent.add_child(replacement)
	parent.move_child(replacement, index)
	parent.remove_child(node)
	return replacement
