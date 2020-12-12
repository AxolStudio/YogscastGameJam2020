package;

import flixel.tile.FlxTilemap;
import axollib.GraphicsCache;
import flixel.FlxSprite;

class Treasure extends FlxSprite
{
    public var parent:FlxTilemap;
    public var column:Int = 0;

    public var treasureType:String = "";
    public var magneted:Bool = false;

    public function new():Void
    {
        super();

        frames = GraphicsCache.loadGraphicFromAtlas("treasures", AssetPaths.treasures__png, AssetPaths.treasures__xml).atlasFrames;
    }

    public function spawn(Column:Int, Parent:FlxTilemap, TreasureType:String):Void
    {
        column = Column;
        parent = Parent;
        treasureType = TreasureType;

        reset(column * World.TILE_SIZE, parent.y);

        animation.frameName = treasureType + ".png";
        magneted = false;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!magneted)
            y = (parent.y + World.TILE_SIZE) - height;
        if (!parent.alive)
            kill();
    }
}
