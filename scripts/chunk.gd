class_name Chunk

# just leaving static typing as a reminder that it might help performance in the future
const size: int = 64
var pos: Vector2 = Vector2(0, 0)
var rect_top: Vector2 = Vector2(0, 0) setget set_rect_top, get_rect_top
var rect_bottom: Vector2 = Vector2(20, 20) setget set_rect_bottom, get_rect_bottom
var active: int = 0 setget set_active, get_active


func set_rect_top(value: Vector2) -> void:
	rect_top = value


func get_rect_top() -> Vector2:
	return rect_top


func set_rect_bottom(value: Vector2) -> void:
	rect_bottom = value


func get_rect_bottom() -> Vector2:
	return rect_bottom


func set_active(value: int):
	active = value


func get_active() -> int:
	return active
