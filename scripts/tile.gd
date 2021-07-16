class_name Tile

var updated: bool setget set_updated, get_updated
var type: int = 0 setget , get_type
var pos: Vector2 setget set_pos, get_pos


func _init(_type):
	type = _type


func set_updated(value: bool):
	updated = value


func get_updated() -> bool:
	return updated


func set_type(value: int):
	type = value


func get_type() -> int:
	return type


func set_pos(value: Vector2):
	pos = value


func get_pos() -> Vector2:
	return pos
