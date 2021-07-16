using Godot;
using System;

public class ChunkDebug : Node2D
{
    // Todo: bind these values to the update script
    Update update;
    int tileSize = 8;
    int chunkSize = 64;

    public override void _Ready()
    {
        //TileMap tileMap = (TileMap)GetParent();
        update = GetParent() as Update;
    }

    public override void _Draw()
    {
        for (int i = 0; i < update.chunks.Count; i++)
        {
            // Draw the chunk dirty rects
            Chunk chunk = update.chunks[i];
            Vector2 offset = chunk.position * chunkSize;
            Vector2 top = chunk.rectTop;
            Vector2 bottom = chunk.rectBottom;
            DrawRect(new Rect2((top + offset) * tileSize, ((bottom - top) + new Vector2(1, 1)) * tileSize), new Color(1, 0, 0), false);
        
            // Draw the chunk boundries
            Vector2 pos = chunk.position * chunkSize * tileSize;
            DrawChunks(pos);
        }
    }

    public void UpdateRectDebug()
    {
        Update();
    }

    private void DrawChunks(Vector2 pos)
    {
        Rect2 rect = new Rect2(pos, new Vector2(chunkSize * tileSize - 1, chunkSize * tileSize - 1));
        DrawRect(rect, new Color(1, 1, 1), false);
    }

}
