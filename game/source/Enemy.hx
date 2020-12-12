package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.tile.FlxTilemap;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

class Enemy extends FlxSprite
{
    public var xbounds:FlxPoint;

    public var parent:FlxTilemap;
    public var world:World;

    public var squishable:Bool = false;
    public var damage:Int = 1;
    public var speed:Int = 10;

    public function new(W:World):Void
    {
        super();
        world = W;
        setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
    }

    public function spawn(X:Float, Parent:FlxTilemap):Void
    {
        revive();

        parent = Parent;
        xbounds = FlxPoint.get(X, X + World.TILE_SIZE);

        x = xbounds.x + (World.TILE_SIZE / 2) - (width / 2);
        y = (parent.y + World.TILE_SIZE) - height;

        facing = FlxG.random.bool() ? FlxObject.LEFT : FlxObject.RIGHT;
        velocity.x = speed * (facing == FlxObject.LEFT ? -1 : 1);
    }

    public function squish():Void
    {
        if (!alive)
            return;
        alive = false;
        velocity.x = 0;
        animation.play("squash", true);
        FlxG.sound.play(AssetPaths.enemy_kill__wav, .2);
    }

    public function hit():Void
    {
        if (!alive)
            return;
        alive = false;
        velocity.x = 0;
        animation.play("kill", true);
        FlxG.sound.play(AssetPaths.enemy_kill__wav, .2);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (alive)
        {
            if (!parent.alive)
            {
                kill();
                return;
            }
        }

        y = (parent.y + World.TILE_SIZE) - height;

        if (!alive)
        {
            if (animation.name == "kill" && animation.finished)
            {
                exists = false;
            }
            else if (animation.name == "squash" && animation.finished)
            {
                animation.play("kill");
            }
        }
    }

    public function getLayer():Int
    {
        for (i in 0...world.layers.length)
        {
            if (world.layers[i].y == parent.y)
                return i;
        }

        return -1;
    }
}
