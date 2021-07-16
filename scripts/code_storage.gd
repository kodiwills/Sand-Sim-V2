extends TileMap
# Driver script for the game that controlls input, particle update methods, and the game scene

signal update_debug

enum {TILE_EMPTY, TILE_SAND, TILE_WATER, TILE_WOOD, TILE_FIRE, TILE_STEAM}
const TILE_SIZE = 8
const CHUNK_SIZE = 64
const CHUNK_GRID_SIZE = Vector2(2, 1)

var Tile = load("res://scripts/tile.gd")
var Chunk = load("res://scripts/chunk.gd")

var playing = false
var dragging = false

#export(int) var width
#export(int) var height
var width = CHUNK_GRID_SIZE.x * CHUNK_SIZE
var height = CHUNK_GRID_SIZE.y * CHUNK_SIZE
var chunks = []
var board = []

var frame = 0
var x_off = 1
var current_tile = TILE_SAND
var density = [null, 5, 1, null, null, null]
var update_list = []


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
#		for x in range(update_list.size()):
#			set_cellv(update_list[x], 1)
		
		var tile_type = 1
		if update_list.size() != 0:
			for z in range(update_list.size()):
				var tile = update_list[z]
				if !board[tile.x][tile.y].updated:
					# Normally I would use board[x][y].type to
					tile_type = board[tile.x][tile.y].type
					match tile_type:
						0:
							pass
						1:
							_update_Sand(tile.x, tile.y)
				else:
					board[tile.x][tile.y].set_updated(false)
		
		# need to change this later
		for x in range(width):
			for y in range(height - 1, 0, -1):
				board[x][y].set_updated(false)
		
		update_list.clear()
		_update_rect_debug()


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
		_brush(pos.x, pos.y, current_tile)
	if event.is_action_pressed("remove_tile"):
		var pos = (get_local_mouse_position() / TILE_SIZE).floor()
		_brush(pos.x, pos.y, 0)
	
	# Change tile events
	if event.is_action_pressed("select_tile_up"):
		current_tile += 1
	if event.is_action_pressed("select_tile_down"):
		current_tile -= 1


func _init_board():
	for x in range(CHUNK_GRID_SIZE.x):
		chunks.append([])
		for y in range(CHUNK_GRID_SIZE.y):
			var chunk = Chunk.new()
			chunks[x].append(chunk)
	
	for x in range(width):
		board.append([])
		for y in range(height):
			var tile = Tile.new(0)
			board[x].append(tile)
			set_cell(x, y, board[x][y].type)
	update()


func _update_update_list():
	for b in range(CHUNK_GRID_SIZE.y - 1, -1, -1):
		for a in CHUNK_GRID_SIZE.x:
			var current_chunk = chunks[a][b]
			var top = current_chunk.rect_top
			var bottom = current_chunk.rect_bottom

			if(current_chunk.active == 0):
				var offset = Vector2(a * CHUNK_SIZE, b * CHUNK_SIZE)
				for y in range(bottom.y, top.y - 1, -1):
					for x in range(top.x, bottom.x + 1):
						update_list.append(Vector2(x + offset.x, y + offset.y))


func _update_rect_debug():
	emit_signal("update_debug")


func _update_Sand(x, y):
	var temp_cell
	# Check bottom, bottom-left, and bottom-right
	if get_cell(x, y + 1) == 0:
		_move(x, y, x, y + 1, TILE_SAND, TILE_EMPTY)
		return
	if get_cell(x + x_off, y + 1) == 0:
		_move(x, y, x + x_off, y + 1, TILE_SAND, TILE_EMPTY)
		return
	if get_cell(x + (x_off * -1), y + 1) == 0:
			_move(x, y, x + (x_off * -1), y + 1, TILE_SAND, TILE_EMPTY)
			return
	
	board[x][y].set_updated(true)


# Allows for the replacing of two tiles on the board
# tile_2 becomes (x, y), tile_1 becomes (new_x, new_y)
func _move(x, y, new_x, new_y, tile_1, tile_2):
	board[new_x][new_y].type = tile_1
	set_cell(new_x, new_y, tile_1)
	board[x][y].type = tile_2
	set_cell(x, y, tile_2)
	board[new_x][new_y].set_updated(true)


func _brush(x, y, type):
	board[x][y].type = type
	set_cell(x, y, type)
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




