package;

import flixel.graphics.frames.FlxBitmapFont;
import flixel.text.FlxBitmapText;

class GameText extends FlxBitmapText
{
    public function new(X:Float, Y:Float, Text:String, ?Style:String = "white"):Void
    {
        super(FlxBitmapFont.fromAngelCode("assets/images/" + Style + "_ui_font.png", "assets/images/" + Style + "_ui_font.xml"));
        x = X;
        y = Y;
        text = Text;
        scrollFactor.set();
    }
}
