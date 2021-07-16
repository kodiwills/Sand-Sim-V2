extends Node2D

var tile_size = 8
var chunk_size = 64

onready var tile_map = get_parent()


func _ready():
	tile_size = tile_map.TILE_SIZE
	chunk_size = tile_map.CHUNK_SIZE


func _draw():
	for element in tile_map.chunks:
		# Draw dirt rects
		var offset = element.pos * chunk_size
		var top = element.rect_top
		var bot = element.rect_bottom
		draw_rect(Rect2((top + offset) * tile_size , ((bot - top) + Vector2(1, 1)) * tile_size), Color(1, 0, 0), false)
			
		# Draw chunk bounds
		var pos = element.pos * chunk_size * tile_size
		_draw_chunks(pos)


func _on_TileMap_update_debug():
	update()


func _draw_dirty_rect():
	pass


func _draw_chunks(pos):
	var rect = Rect2(pos, Vector2(chunk_size * tile_size - 1, chunk_size * tile_size - 1))
	draw_rect(rect, Color(1, 1, 1), false)



















