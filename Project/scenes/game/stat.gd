class_name Stat
extends Node

@export var affectedNode: Node = null
@export var property: String = ""

func assignNode(node: Node) -> void:
	affectedNode = node

func assignVariable(propertyName: String) -> void:
	property = propertyName

func setVal(val: Variant) -> void:
	affectedNode.set(property, val)

func getVal() -> Variant:
	return affectedNode.get(property)
