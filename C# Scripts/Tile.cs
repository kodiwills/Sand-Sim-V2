using Godot;
using System;

public class Tile
{
    public bool updated { get; set; }
    public int type { get; set; }
    public Vector2 position { get; set; }
    public Chunk parentChunk;
}
