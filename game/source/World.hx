package;

import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.tweens.FlxEase;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;

class World extends FlxTypedGroup<FlxTypedGroup<FlxTilemap>>
{
    public static inline var TILE_SIZE:Int = 64;

    public var biomes:Array<Biome>;

    public var worldWidth:Int = Math.ceil(FlxG.width / TILE_SIZE);
    public var worldHeight:Int = Math.ceil(FlxG.height / TILE_SIZE);

    public var layers:Array<FlxTilemap>;
    public var backLayers:Array<FlxTilemap>;

    public var worldTween:FlxTween;
    public var shifting:Bool = false;

    public var parent:PlayState;

    public var depth:Int = 0;

    public var fore:FlxTypedGroup<FlxTilemap>;
    public var back:FlxTypedGroup<FlxTilemap>;

    public var currentBiome:Int = 0;

    private static var TREASURES:Array<String> = ["coinBronze", "coinSilver", "coinGold", "gem1", "gem2", "gem3", "gem4"];

    public function new(Parent:PlayState):Void
    {
        super();

        biomes = [];

        var b:Biome = new Biome(AssetPaths.biome_01__png, AssetPaths.bg_01__png);
        biomes.push(b);

        b = new Biome(AssetPaths.biome_02__png, AssetPaths.bg_02__png);
        biomes.push(b);

        b = new Biome(AssetPaths.biome_03__png, AssetPaths.bg_03__png);
        biomes.push(b);

        fore = new FlxTypedGroup<FlxTilemap>();
        back = new FlxTypedGroup<FlxTilemap>();

        add(back);
        add(fore);

        parent = Parent;

        layers = [];
        backLayers = [];

        var t:FlxTilemap;

        for (y in 0...5)
        {
            // fore
            t = new FlxTilemap();
            if (y < 4)
                t.loadMapFromArray([
                    for (i in 0...worldWidth * 2)
                        FlxG.random.weightedPick([120, 10, 10, 10, 10, 10, 0, 0, 0, 0, 0])
                ], worldWidth * 2, 1, AssetPaths.top_bg__png, TILE_SIZE,
                    TILE_SIZE, FlxTilemapAutoTiling.OFF, 0, 1, 1);
            else
                t.loadMapFromArray([
                    for (i in 0...worldWidth * 2)
                        FlxG.random.weightedPick([20, 0, 0, 0, 0, 0, 10, 10, 10, 10, 10])
                ], worldWidth * 2, 1, AssetPaths.top_bg__png, TILE_SIZE,
                    TILE_SIZE, FlxTilemapAutoTiling.OFF, 0, 1, 1);
            t.x = 0;
            t.y = (y - 1) * TILE_SIZE;
            layers.push(t);
            fore.add(t);

            // back
            t = new FlxTilemap();
            t.loadMapFromArray([for (i in 0...worldWidth * 2) 0], worldWidth * 2, 1, AssetPaths.empty__png, TILE_SIZE, TILE_SIZE, FlxTilemapAutoTiling.OFF, 0,
                0, 1);
            t.x = 0;
            t.y = (y - 1) * TILE_SIZE;
            backLayers.push(t);
            back.add(t);
        }

        for (y in 5...worldHeight + 1)
        {
            addNewLayer();
        }
    }

    private function addNewLayer():Void
    {
        currentBiome = Std.int((depth + layers.length) / 40) % biomes.length;

        var t:FlxTilemap = fore.recycle(FlxTilemap, FlxTilemap.new);

        t.revive();
        if (currentBiome == 0)
        {
            t.loadMapFromArray([
                for (i in 0...worldWidth * 2)
                    FlxG.random.weightedPick([
                        (((depth + layers.length) - 5)) * 2.5,
                        200,
                        ((depth + layers.length)) * .5,
                        0,
                        ((depth + layers.length)) * .25,
                        0,
                        0,
                        ((depth + layers.length)) * .1
                    ])
            ], worldWidth * 2, 1,
                biomes[currentBiome].foreground, TILE_SIZE, TILE_SIZE, FlxTilemapAutoTiling.OFF, 0, 0, 1);
        }
        else
        {
            t.loadMapFromArray([
                for (i in 0...worldWidth * 2)
                    FlxG.random.weightedPick([
                        (((depth + layers.length) % 40)) * 2.5,
                        200,
                        ((depth + layers.length) % 40) * .5,
                        0,
                        ((depth + layers.length) % 40) * .25,
                        0,
                        0,
                        ((depth + layers.length) % 40) * .1
                    ])
            ], worldWidth * 2, 1,
                biomes[currentBiome].foreground, TILE_SIZE, TILE_SIZE, FlxTilemapAutoTiling.OFF, 0, 0, 1);
        }
        t.y = 0;
        t.y = (layers.length - 1) * TILE_SIZE;

        layers.push(t);
        // fore.add(t);

        // chance to add an enemy: 5%
        if (layers.length > 5)
        {
            for (i in 0...worldWidth * 2)
            {
                if (t.getTileByIndex(i) == 0)
                {
                    addEnemy("slime", i, layers.length - 1);
                }
                else
                {
                    if (FlxG.random.bool((depth + layers.length) * 2.5))
                    {
                        // add a treasure!
                        addTreasure(i, layers.length - 1);
                    }
                }
            }
        }

        // background
        var t:FlxTilemap = back.recycle(FlxTilemap, FlxTilemap.new);

        t.revive();
        if (currentBiome == 0)
        {
            t.loadMapFromArray(backLayers.length == 5 ? [for (i in 0...worldWidth * 2) 1] : [
                for (i in 0...worldWidth * 2)
                    Std.int((((depth + backLayers.length) - 5)) / 10) + 2
            ], worldWidth * 2, 1,
                biomes[currentBiome].background, TILE_SIZE, TILE_SIZE, FlxTilemapAutoTiling.OFF, 0, 0, 1);
        }
        else
        {
            t.loadMapFromArray([
                for (i in 0...worldWidth * 2)
                    Std.int((((depth + backLayers.length) % 40)) / 10)
            ], worldWidth * 2, 1,
                biomes[currentBiome].background, TILE_SIZE, TILE_SIZE, FlxTilemapAutoTiling.OFF, 0, 0, 1);
        }
        t.x = 0;
        t.y = (backLayers.length - 1) * TILE_SIZE;

        backLayers.push(t);
        back.add(t);
    }

    public function addEnemy(EnemyType:String, Column:Int, Layer:Int):Void
    {
        var e:Enemy = null;

        var choice:Int = FlxG.random.weightedPick([100, (depth + Layer) * .5]);

        switch (choice)
        {
            case 0:
                switch (currentBiome)
                {
                    case 0:
                        e = parent.enemies.recycle(Slime, Slime.new.bind(this));
                    case 1:
                        e = parent.enemies.recycle(Slime2, Slime2.new.bind(this));
                    case 2:
                        e = parent.enemies.recycle(Slime3, Slime3.new.bind(this));
                }

            case 1:
                e = parent.enemies.recycle(Saw, Saw.new.bind(this));
        }
        e.spawn(Column * TILE_SIZE, layers[Layer]);
    }

    public function addTreasure(Column:Int, Layer:Int):Void
    {
        var t:Treasure = parent.treasure.recycle(Treasure, Treasure.new);
        t.spawn(Column, layers[Layer], TREASURES[
            FlxG.random.weightedPick([
                (100000 + (depth + Layer)) * 1,
                (10000 + (depth + Layer)) * 10,
                (1000 + (depth + Layer)) * 100,
                (100 + (depth + Layer)) * 1000,
                (10 + (depth + Layer)) * 10000,
                (1 + (depth + Layer)) * 100000,
            ])
        ]);
    }

    public function addHealth(Column:Int, Layer:Int):Void
    {
        var t:Treasure = parent.treasure.recycle(Treasure, Treasure.new);
        t.spawn(Column, layers[Layer], FlxG.random.bool(90) ? "healthpickup" : "energypickup");
    }

    public function shiftUp():Void
    {
        // add a new layer:

        addNewLayer();
        depth++;
        shifting = true;
        worldTween = FlxTween.tween(layers[0], {y: layers[0].y - TILE_SIZE}, .33, {
            ease: FlxEase.backIn,
            type: FlxTweenType.ONESHOT,
            startDelay: .2,
            onComplete: (_) ->
            {
                shifting = false;
                fixLayers();
                var l:FlxTilemap = layers.shift();
                l.kill();
                l = backLayers.shift();
                l.kill();
            },
            onUpdate: (_) ->
            {
                fixLayers();
            }
        });
    }

    private function fixLayers():Void
    {
        for (i in 1...layers.length)
        {
            layers[i].y = layers[0].y + (TILE_SIZE * i);
        }
        for (i in 0...backLayers.length)
        {
            backLayers[i].y = layers[i].y;
        }
    }
}

class Biome
{
    public var foreground:FlxTilemapGraphicAsset;
    public var background:FlxTilemapGraphicAsset;

    public function new(Foreground:FlxTilemapGraphicAsset, Background:FlxTilemapGraphicAsset):Void
    {
        foreground = Foreground;
        background = Background;
    }
}
