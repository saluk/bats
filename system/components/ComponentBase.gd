extends Node
class_name ComponentBase

class Component:
	var instance:Node
	var base_node:Node
	func _init(component):
		instance = component

static func base_node(component):
	while component and "component" in component and component.component is Component:
		component = component.get_parent()
	return component
	
static func component_ready(component):
	component.component = Component.new(component)
	component.base_node = base_node(component)
