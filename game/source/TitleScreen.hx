package;

import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class TitleScreen extends FlxState
{
    private var ready:Bool = false;

    public function new():Void
    {
        super();
    }

    override public function create():Void
    {
        add(new FlxSprite(0, 0, AssetPaths.title__png));

        var a:FlxSprite = new FlxSprite(0, 0, AssetPaths.axol__png);
        a.x = 16;
        a.y = FlxG.height - a.height - 16;
        add(a);

        var t:GameText = new GameText(0, 0, "©2020 Axol Studio, LLC");
        t.x = FlxG.width - t.width - 16;
        t.y = FlxG.height - t.height - 16;
        add(t);

        t = new GameText(0, 0, "Press SPACE to Play");
        t.y = FlxG.height - t.height - 64;
        t.screenCenter(FlxAxes.X);
        add(t);

        FlxG.camera.fade(FlxColor.WHITE, .66, true, () ->
        {
            ready = true;
        });

        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (ready && FlxG.keys.anyJustPressed([Z, X, C, SPACE, ENTER]))
        {
            FlxG.sound.play(AssetPaths.pickup__wav, .2);
            ready = false;
            FlxG.camera.fade(FlxColor.WHITE, .66, false, () ->
            {
                FlxG.switchState(new PlayState());
            });
        }
    }
}
