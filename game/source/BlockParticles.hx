package;

import axollib.GraphicsCache;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter.FlxTypedEmitter;

class BlockParticles extends FlxTypedEmitter<BlockParticle>
{
    public function new():Void
    {
        super(0, 0, 50);

        width = height = World.TILE_SIZE;

        lifespan.set(0.1, 1);

        acceleration.start.min.y = 800;
        acceleration.start.max.y = 1000;
        acceleration.end.min.y = 800;
        acceleration.end.max.y = 1000;

        scale.set(1, 1, 1, 1, 0, 0, 1, 1);

        var p:BlockParticle;
        for (i in 0...50)
        {
            p = new BlockParticle();
            add(p);
        }
    }

    public function spawn(X:Float, Y:Float):Void
    {
        //revive();
        x = X;
        y = Y;
        start(true);
    }

    override private function onFinished():Void
    {
        super.onFinished();
        //kill();
    }
}

class BlockParticle extends FlxParticle
{
    public function new():Void
    {
        super();
        frames = GraphicsCache.loadGraphicFromAtlas("block-particles", AssetPaths.block_particles__png, AssetPaths.block_particles__xml).atlasFrames;
    }

    override public function onEmit():Void
    {
        super.onEmit();
        animation.randomFrame();
    }
}
