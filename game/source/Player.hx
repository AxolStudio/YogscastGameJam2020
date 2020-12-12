package;

import axollib.GraphicsCache;
import flixel.FlxSprite;

class Player extends FlxSprite
{
    public function new():Void
    {
        super();
        frames = GraphicsCache.loadGraphicFromAtlas("player", AssetPaths.player__png, AssetPaths.player__xml).atlasFrames;

        animation.addByNames("idle", ["player_idle.png"], 2, false);
        animation.addByNames("down", ["player_down.png"], 2, false);
        animation.addByNames("jump", ["player_jump.png"], 2, false);
        animation.addByNames("hurt", [
            "player_hit.png",
            "player_hit_flash.png",
            "player_hit.png",
            "player_hit_flash.png",
            "player_hit.png",
            "player_hit_flash.png"
        ], 8, false);

        animation.play("idle");
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (animation.name != "idle" && animation.finished)
            animation.play("idle");
    }
}
