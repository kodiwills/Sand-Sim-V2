using Godot;
using System;
using System.Collections.Generic;

/* To do: 
	Change tile to a struct for performance
	Convert update to an array
	Cut the dirty rects into smaller rect
	Multithread the chunks in a checkerboard pattern
*/ 	
public class Update : TileMap
{
	ChunkDebug chunkDebug;
	enum Types{
		Empty = 0,
		Sand = 1,
		Water = 2
	}

	public int CHUNK_SIZE = 64;
	public const int TILE_SIZE = 8;
	Vector2 CHUNK_GRID_SIZE = new Vector2(2, 1);
	bool playing = false;
	bool dragging = false;
	int currentTile = 1;
	int width, height;

	public Dictionary<int, Chunk> chunks = new Dictionary<int, Chunk>();
	Dictionary<Vector2, Tile> tiles = new Dictionary<Vector2, Tile>();
	Queue<Tile> updatedTiles = new Queue<Tile>();

	bool frame = false;
	int xOff = 1;

	public override void _Ready()
	{
		chunkDebug = GetNode("Debug") as ChunkDebug;

		width = (int)CHUNK_GRID_SIZE.x * CHUNK_SIZE;
		height = (int)CHUNK_GRID_SIZE.y * CHUNK_SIZE;

		int width_px = width * TILE_SIZE;
		int height_px = height * TILE_SIZE;
		Camera2D camera = (Camera2D)GetNode("Camera2D");
		camera.Position = new Vector2(width_px, height_px) / 2;
		camera.Zoom = new Vector2(width_px, height_px) / new Vector2(TILE_SIZE * CHUNK_SIZE * CHUNK_GRID_SIZE.x, TILE_SIZE * CHUNK_SIZE * CHUNK_GRID_SIZE.y);

		InitBoard();
	}
	public void test(){}
	
	public override void _Process(float delta)
  {
	if (!playing)
	{
		return;
	}
	else
	{
		frame = !frame;
		if (frame)
		{
			xOff = xOff * -1;
		}

		chunkDebug.UpdateRectDebug();
		UpdateChunkLists();
		UpdateBoard();
	}
  }

    public override void _Input(InputEvent inputEvent)
    {
		// Tile events
		if(inputEvent.IsActionPressed("select_tile_up"))
			currentTile += 1;
		if(inputEvent.IsActionPressed("select_tile_down"))
			currentTile -= 1;

		// Play/Pause events
		if (inputEvent.IsActionPressed("toggle_play"))
		{
			playing = !playing;
			if(playing)
			{
				GD.Print("The game is playing");
			}
			else
			{
				GD.Print("The game is paused");
			}
		}

		// Mouse events
		if (inputEvent is InputEventMouseButton mouseEvent && (ButtonList)mouseEvent.ButtonIndex == ButtonList.Left)
		{
			if(!dragging && mouseEvent.Pressed)
				dragging = true;
			if(dragging && !mouseEvent.Pressed)
				dragging = false;
		}
		if (inputEvent is InputEventMouseMotion motionEvent && dragging)
		{
			Vector2 pos = (GetLocalMousePosition() / TILE_SIZE).Floor();
			Vector2 chunkPos = (pos / CHUNK_SIZE).Floor();
			Chunk chunk = chunks[(int)((chunkPos.y * CHUNK_GRID_SIZE.y) + chunkPos.x)];
			Brush(pos, chunk);
		}
    }

	private void InitBoard()
	{
		// Create the chunks and add them to chunks list
		for (int i = 0; i < CHUNK_GRID_SIZE.x * CHUNK_GRID_SIZE.y; i++)
		{
			int x = i % (int)CHUNK_GRID_SIZE.x;
			int y = i / (int)CHUNK_GRID_SIZE.x;
			Chunk chunk = new Chunk();
			chunk.position = new Vector2(x, y);
			chunk.rectTop = new Vector2(63, 63);
			chunk.rectBottom = new Vector2(0, 0);
			chunks.Add(i, chunk);
		}
		
		// Populate the chunks with tiles
		int size = (int)CHUNK_GRID_SIZE.x * CHUNK_SIZE;
		for (int y = 0; y < height; y++)
		{
			for (int x = 0; x < width; x++)
			{
				Tile tile = new Tile();
				tiles.Add(new Vector2(x, y), tile);
				SetCell(x, y, 0);
			}
		}
	}

	private void UpdateChunkLists()
	{
		// Update the list of tiles to be updated in each chunk
		for (int i = 0; i < chunks.Count; i++)
		{
			Chunk currentChunk = chunks[i];
			currentChunk.updateList.Clear();
			Vector2 top = currentChunk.rectTop;
			Vector2 bottom = currentChunk.rectBottom;

			if (currentChunk.active)
			{
				Vector2 offset = currentChunk.position * CHUNK_SIZE;
				for (int y = (int)bottom.y; y > top.y - 1; y--)
				{
					for (int x = (int)top.x; x < bottom.x + 1; x++)
					{
						currentChunk.updateList.Enqueue(new Vector2(x + offset.x, y + offset.y));
					}
				}
			}else
			{
				continue;
			}

			if (currentChunk.updateList.Count == 0)
			{
				currentChunk.active = false;
			}

			// Clearing the dirty rect for the tile update
			currentChunk.rectTop = new Vector2(63, 63);
			currentChunk.rectBottom = new Vector2(0, 0);
		}
	}

	private void UpdateBoard()
	{
		int tileType;
		Tile tile;

		// Update each tile in each chunks updateList
		for (int i = 0; i < chunks.Count; i++)
		{
			Chunk currentChunk = chunks[i];
			// Call the corresponding update for the tile type
			foreach (Vector2 item in currentChunk.updateList)
			{
				tile = tiles[item];
				if (!tile.updated)
				{
					tileType = tile.type;
					switch (tileType)
					{
						case 0:
							break;
						case 1:
							UpdateSand(item, tile, currentChunk);
							break;
						case 2:
							UpdateWater(item, tile, currentChunk);
							break;
					}
				}
			}

			currentChunk.updateList.Clear();
		}

		// Set all tiles back to unupdated and clear the updated list
		foreach (Tile x in updatedTiles)
		{
			x.updated = false;
		}
		updatedTiles.Clear();
	}

	private void UpdateSand(Vector2 pos, Tile tile, Chunk chunk)
	{
		// Could use the tiles array instead of GetCell, but I am pretty sure that GetCell is faster since it is in native C++
		if (GetCell((int)pos.x, (int)pos.y + 1) == 0)
		{
			Swap(pos, new Vector2(pos.x, pos.y + 1), (int)Types.Sand, (int)Types.Empty, tile, chunk);
			return;
		}
		else if (GetCell((int)pos.x + xOff, (int)pos.y + 1) == 0)
		{
			Swap(pos, new Vector2(pos.x + xOff, pos.y + 1), (int)Types.Sand, (int)Types.Empty, tile, chunk);
			return;
		}
		else if (GetCell((int)pos.x + (xOff * -1), (int)pos.y + 1) == 0)
		{
			Swap(pos, new Vector2(pos.x + (xOff * -1), pos.y + 1), (int)Types.Sand, (int)Types.Empty, tile, chunk);
			return;
		}
	}

	private void UpdateWater(Vector2 pos, Tile tile, Chunk chunk)
	{
		if (GetCell((int)pos.x, (int)pos.y + 1) == 0)
		{
			Swap(pos, new Vector2(pos.x, pos.y + 1), (int)Types.Water, (int)Types.Empty, tile, chunk);
			return;
		}
		else if (GetCell((int)pos.x + xOff, (int)pos.y + 1) == 0)
		{
			Swap(pos, new Vector2(pos.x + xOff, pos.y + 1), (int)Types.Water, (int)Types.Empty, tile, chunk);
			return;
		}
		else if (GetCell((int)pos.x + (xOff * -1), (int)pos.y + 1) == 0)
		{
			Swap(pos, new Vector2(pos.x + (xOff * -1), pos.y + 1), (int)Types.Water, (int)Types.Empty, tile, chunk);
			return;
		}
		// Left or right
		else if (GetCell((int)pos.x + xOff, (int)pos.y) == 0)
		{
			Swap(pos, new Vector2(pos.x + xOff, pos.y), (int)Types.Water, (int)Types.Empty, tile, chunk);
			return;
		}
		else if (GetCell((int)pos.x + (xOff * -1), (int)pos.y) == 0)
		{
			Swap(pos, new Vector2(pos.x + (xOff * -1), pos.y), (int)Types.Water, (int)Types.Empty, tile, chunk);
			return;
		}
	}

	private void Swap(Vector2 pos1, Vector2 pos2, int type1, int type2, Tile tile, Chunk chunk)
	{
		// Set the board types, and add moved tiles to the updated list
		SetCellv(pos1, type2);
		tile.type = type2;
		tile.updated = true;
		updatedTiles.Enqueue(tile);

		SetCellv(pos2, type1);
		tiles[pos2].type = type1;
		tiles[pos2].updated = true;
		updatedTiles.Enqueue(tiles[pos2]);

		// Update the dirty rect of the chunks
		Vector2 top = chunk.rectTop;
		Vector2 bottom = chunk.rectBottom;
		Vector2 pos = pos2 - (CHUNK_SIZE * chunk.position);

		float x = Mathf.Clamp(Math.Min(pos.x, top.x), 0, 63);
		float y = Mathf.Clamp(Math.Min(pos.y, top.y), 0, 63);
		chunk.rectTop = new Vector2(x, y);

		x = Mathf.Clamp(Math.Max(pos.x, bottom.x), 0, 63);
		y = Mathf.Clamp(Math.Max(pos.y, bottom.y), 0, 63);
		chunk.rectBottom = new Vector2(x, y);
	}

	private void Brush(Vector2 pos, Chunk chunk)
	{
		tiles[pos].type = currentTile;
		SetCellv(pos, currentTile);

		chunk.active = true;
		Vector2 top = chunk.rectTop;
		Vector2 bottom = chunk.rectBottom;
		Vector2 offsetPos = pos - (CHUNK_SIZE * chunk.position);

		float x = Mathf.Clamp(Math.Min(offsetPos.x, top.x), 0, 63);
		float y = Mathf.Clamp(Math.Min(offsetPos.y, top.y), 0, 63);
		chunk.rectTop = new Vector2(x, y);

		x = Mathf.Clamp(Math.Max(offsetPos.x, bottom.x), 0, 63);
		y = Mathf.Clamp(Math.Max(offsetPos.y, bottom.y), 0, 63);
		chunk.rectBottom = new Vector2(x, y);
	}
}
