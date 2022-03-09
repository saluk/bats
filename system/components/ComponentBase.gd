extends Node
class_name ComponentBase

static func base_node(component):
	while component and (
		component is NodeComponent or
		component is Node2DComponent or
		component is Area2DComponent):
		component = component.get_parent()
	return component
	
static func component_ready(component):
	component.base_node = base_node(component)
