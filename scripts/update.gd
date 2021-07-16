extends TileMap
# Driver script for the game that controlls input, particle update methods, and the game scene

signal update_debug

enum {TILE_EMPTY, TILE_SAND, TILE_WATER, TILE_WOOD, TILE_FIRE, TILE_STEAM}
const TILE_SIZE = 8
const CHUNK_SIZE = 64
const CHUNK_GRID_SIZE = Vector2(2, 1)

# Resources
var Tile = load("res://scripts/tile.gd")
var Chunk = load("res://scripts/chunk.gd")

# Input variables
var playing = false
var dragging = false
var current_tile = TILE_SAND

# Chunk variables
var width = CHUNK_GRID_SIZE.x * CHUNK_SIZE
var height = CHUNK_GRID_SIZE.y * CHUNK_SIZE
var chunks = []
var board = {}

# Update Variables
var frame = 0
var x_off = 1
var update_list = []
var updated_list = []


func _ready():
	var width_px = width * TILE_SIZE
	var height_px = height * TILE_SIZE
	var cam = $Camera2D
	cam.position = Vector2(width_px, height_px) / 2
	#cam.zoom = Vector2(width_px, height_px) / Vector2(1900, 1000)
	
	_init_board()


func _physics_process(_delta):
	if !playing:
		return
	else:
		frame = !frame
		if frame:
			x_off = x_off * -1
			
			_update_update_list()
			_update_rect_debug()
		else:
			_update()


func _input(event):
	# Start/Pause events
	if event.is_action_pressed("toggle_play"):
		playing = !playing
		if(playing):
			print("The game is playing")
		else:
			print("The game is paused")
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if not dragging and event.pressed:
			dragging = true
			# Stop dragging if the button is released.
		if dragging and not event.pressed:
			dragging = false
	if event is InputEventMouseMotion and dragging:
		var pos = (get_local_mouse_position() / TILE_SIZE).floor()
		_brush(pos, current_tile)
	if event.is_action_pressed("remove_tile"):
		var pos = (get_local_mouse_position() / TILE_SIZE).floor()
		_brush(pos, 0)
	
	# Change tile events
	if event.is_action_pressed("select_tile_up"):
		current_tile += 1
	if event.is_action_pressed("select_tile_down"):
		current_tile -= 1


func _init_board():
	for z in range(CHUNK_GRID_SIZE.x * CHUNK_GRID_SIZE.y):
		var x = z % int(CHUNK_GRID_SIZE.x)
		var y = z / int(CHUNK_GRID_SIZE.x)
		var chunk = Chunk.new()
		chunk.pos = Vector2(x, y)
		chunks.append(chunk)
	
	var size = CHUNK_GRID_SIZE.x * CHUNK_SIZE
	for y in range(height):
		for x in range(width):
			var tile = Tile.new(0)
			board[(y * size) + x] = tile
			set_cell(x, y, 0)


func _update_update_list():
	update_list.clear()
	
	for element in chunks:
		var top = element.rect_top
		var bottom = element.rect_bottom

		if(element.active == 0):
			var offset = element.pos * CHUNK_SIZE
			for y in range(bottom.y, top.y - 1, -1):
				for x in range(top.x, bottom.x + 1):
					update_list.append(Vector2(x + offset.x, y + offset.y))


func _update_rect_debug():
	emit_signal("update_debug")


func _update():
	var board_number
	var size = CHUNK_GRID_SIZE.x * CHUNK_SIZE
	var tile_type = 1
	var tile
	
	for element in update_list:
		board_number = (element.y * size) + element.x
		tile = board[board_number]
		
		if !tile.updated:
			tile_type = tile.type
			if tile_type == 0:
				pass
			elif tile_type == 1:
				_update_Sand(element, board_number)
				tile.set_updated(true)
				updated_list.append(tile)
	
	for element in updated_list:
				element.set_updated(false)
	
	updated_list.clear()


func _update_Sand(pos, board_number):
	var temp_cell
	# Check bottom, bottom-left, and bottom-right
	if get_cell(pos.x, pos.y + 1) == 0:
		_move(pos, Vector2(pos.x, pos.y + 1), TILE_SAND, TILE_EMPTY, board_number)
		return
	if get_cell(pos.x + x_off, pos.y + 1) == 0:
		_move(pos, Vector2(pos.x + x_off, pos.y + 1), TILE_SAND, TILE_EMPTY, board_number)
		return
	if get_cell(pos.x + (x_off * -1), pos.y + 1) == 0:
		_move(pos, Vector2(pos.x + (x_off * -1), pos.y + 1), TILE_SAND, TILE_EMPTY, board_number)
		return


# Allows for the replacing of two tiles on the board
# tile_2 becomes (x, y), tile_1 becomes (new_x, new_y)
func _move(old_pos, new_pos, old_tile, new_tile, board_number):
	board[board_number].type = old_tile
	set_cellv(new_pos, old_tile)
	board[board_number].type = new_tile
	set_cellv(old_pos, new_tile)
	board[board_number].set_updated(true)


func _brush(pos, type):
	var x = pos.y * CHUNK_GRID_SIZE.y * CHUNK_SIZE + pos.x
	board[x].type = type
	set_cellv(pos, type)
#	if x + 1 < width:
#		board[x + 1][y].type = type
#		set_cell(x + 1, y, type)
#	if x - 1 >= 0:
#		board[x - 1][y].type = type
#		set_cell(x - 1, y, type)
#	if y + 1 < height:
#		board[x][y + 1].type = type
#		set_cell(x, y + 1, type)
#	if y - 1 >= 0:
#		board[x][y - 1].type = type
#		set_cell(x, y - 1, type)













