using Godot;
using System;
using System.Collections.Generic;

public class Chunk : Node
{
    public int size { get; set; }
    public Vector2 position { get; set; }
    public Vector2 rectTop { get; set; } = new Vector2(0, 0);
    public Vector2 rectBottom { get; set; } = new Vector2(0, 0);
    public bool active { get; set; }
    public Queue<Vector2> updateList = new Queue<Vector2>();
}
