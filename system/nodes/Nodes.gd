#  Static class with some node helper functions

extends Reference
class_name Nodes

# From an array of nodes, prune all nodes that are deleted or about to be
static func clean_node_array(array) -> Array:
	var new_array = []
	for node in array:
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			new_array.append(node)
	return new_array

static func walk_children(node:Node) -> Array:
	var get_children_array := [node]
	var leaf_children := []
	var n:Node
	var c:Array
	while get_children_array:
		n = get_children_array.pop_front()
		c = n.get_children()
		leaf_children.append(n)
		get_children_array = c + get_children_array
	return leaf_children

static func get_classname(node:Node) -> String:
	var s:Script = node.get_script()
	var spl_arr
	if s:
		for line in s.source_code.split("\n"):
			if "class_name" in line:
				spl_arr = line.split(" ")
				print(line)
				return spl_arr[spl_arr.size()-1]
		return "no_class"
	return node.get_class()
	
static func get_class_node(node:Node, classname:String) -> Node:
	for child in walk_children(node):
		print(child.name+":"+get_classname(child))
		if get_classname(child) == classname:
			return child
	return null
