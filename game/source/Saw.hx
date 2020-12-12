package;

import flixel.FlxObject;
import axollib.GraphicsCache;

class Saw extends Enemy
{
    public function new(W:World):Void
    {
        super(W);

        frames = GraphicsCache.loadGraphicFromAtlas("saw", AssetPaths.saw__png, AssetPaths.saw__xml).atlasFrames;

        animation.addByNames("walk", ["saw.png", "saw_move.png"], 8, true);
        animation.addByNames("kill", ["saw_hurt.png", "saw_dead.png"], 8, false);
        damage = 2;
        speed = 64;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (alive)
        {
            var bounced:Bool = false;

            var c:Int;
            var l:Int;
            if (velocity.x < 0 && x < xbounds.x)
            {
                if (animation.finished)
                    animation.play("walk");
                bounced = xbounds.x <= 0;
                c = Std.int(xbounds.x / World.TILE_SIZE) - 1;
                l = getLayer();
                if (!bounced)
                {
                    bounced = !world.parent.hitBlock(c, l);
                }

                if (bounced)
                {
                    velocity.x *= -1;

                    x = xbounds.x;
                    facing = FlxObject.RIGHT;
                }
                else
                {
                    xbounds.x -= World.TILE_SIZE;
                    xbounds.y -= World.TILE_SIZE;
                    if (l == world.parent.getPlayerLayer() && c == Std.int(world.parent.player.x / World.TILE_SIZE))
                    {
                        world.parent.health -= damage * (Std.int(world.depth / 40) + 1);
                        world.parent.player.animation.play("hurt");
                        hit();
                    }
                }
            }
            else if (velocity.x > 0 && x + width > xbounds.y)
            {
                if (animation.finished)
                    animation.play("walk");
                bounced = xbounds.y >= world.worldWidth * World.TILE_SIZE;
                c = Std.int(xbounds.y / World.TILE_SIZE);
                l = getLayer();
                if (!bounced)
                {
                    bounced = !world.parent.hitBlock(c, l);
                }

                if (bounced)
                {
                    velocity.x *= -1;
                    x = xbounds.y - width;
                    facing = FlxObject.LEFT;
                }
                else
                {
                    xbounds.x += World.TILE_SIZE;
                    xbounds.y += World.TILE_SIZE;
                    if (l == world.parent.getPlayerLayer() && c == Std.int(world.parent.player.x / World.TILE_SIZE))
                    {
                        world.parent.health -= damage * (Std.int(world.depth / 40) + 1);
                        world.parent.player.animation.play("hurt");
                        hit();
                    }
                }
            }
        }
    }
}
