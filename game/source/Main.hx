package;

import axollib.DissolveState;
import axollib.AxolAPI;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
    public function new()
    {
        super();
        AxolAPI.firstState = TitleScreen;
        addChild(new FlxGame(0, 0, DissolveState));

        // AxolAPI.initialize("89C359408DF0479DA4254F1578384BC5");

        // AxolAPI.sendEvent("Game:Event:Launch");
    }
}
