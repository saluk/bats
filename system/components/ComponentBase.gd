extends Node
class_name ComponentBase

class Component:
	var instance:Node
	var base_node:Node

static func base_node(node):
	while node and "component" in node and node.component is Component:
		node = node.get_parent()
	return node
	
static func component_ready(component_node):
	component_node.base_node = base_node(component_node)
