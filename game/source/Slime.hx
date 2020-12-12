package;

import flixel.FlxObject;
import axollib.GraphicsCache;

class Slime extends Enemy
{
    public function new(W:World):Void
    {
        super(W);

        frames = GraphicsCache.loadGraphicFromAtlas("slime", AssetPaths.slimePurple__png, AssetPaths.slimePurple__xml).atlasFrames;

        animation.addByNames("walk", ["slimePurple.png", "slimePurple_move.png"], 8, true);
        animation.addByNames("squash", ["slimePurple_hit.png"], 8, false);
        animation.addByNames("kill", ["slimePurple_hurt.png", "slimePurple_dead.png"], 8, false);
        squishable = true;
        speed = 0;
        animation.frameName = "slimePurple.png";
    }
    // override public function update(elapsed:Float):Void
    // {
    //     super.update(elapsed);
    //     // if (alive)
    //     // {
    //     //     var c:Int;
    //     //     var l:Int;
    //     //     if (velocity.x <= 0 && x < xbounds.x)
    //     //     {
    //     //         c = Std.int(xbounds.x / World.TILE_SIZE) - 1;
    //     //         l = getLayer();
    //     //         if (world.parent.isEmptyBlock(c, l))
    //     //         {
    //     //             if (animation.finished)
    //     //                 animation.play("walk", true);
    //     //             xbounds.x -= World.TILE_SIZE;
    //     //             xbounds.y -= World.TILE_SIZE;
    //     //             facing = FlxObject.LEFT;
    //     //             velocity.x = -speed;
    //     //             if (l == world.parent.getPlayerLayer() && c == Std.int(world.parent.player.x / World.TILE_SIZE))
    //     //             {
    //     //                 world.parent.health -= damage * (Std.int(world.depth / 40) + 1);
    //     //                 hit();
    //     //             }
    //     //         }
    //     //         else
    //     //         {
    //     //             velocity.x = 0;
    //     //             x = xbounds.x;
    //     //             animation.stop();
    //     //             animation.frameName = "slimePurple.png";
    //     //         }
    //     //     }
    //     //     else if (velocity.x >= 0 && x + width > xbounds.y)
    //     //     {
    //     //         c = Std.int(xbounds.y / World.TILE_SIZE);
    //     //         l = getLayer();
    //     //         if (world.parent.isEmptyBlock(c, l))
    //     //         {
    //     //             if (animation.finished)
    //     //                 animation.play("walk", true);
    //     //             facing = FlxObject.RIGHT;
    //     //             velocity.x = speed;
    //     //             xbounds.x += World.TILE_SIZE;
    //     //             xbounds.y += World.TILE_SIZE;
    //     //             if (l == world.parent.getPlayerLayer() && c == Std.int(world.parent.player.x / World.TILE_SIZE))
    //     //             {
    //     //                 world.parent.health -= damage * (Std.int(world.depth / 40) + 1);
    //     //                 hit();
    //     //             }
    //     //         }
    //     //         else
    //     //         {
    //     //             velocity.x = 0;
    //     //             x = xbounds.y - width;
    //     //             animation.stop();
    //     //             animation.frameName = "slimePurple.png";
    //     //         }
    //     //     }
    //     // }
    // }
}
