package;

import axollib.GraphicsCache;
import flixel.FlxSprite;

class Card
{
    public var name(default, null):String;
    public var image(default, null):String;
    public var cardtype(default, null):String;
    public var effect(default, null):String;

    public function new(Definition:CardDef)
    {
        name = Definition.name;
        image = Definition.image;
        cardtype = Definition.type;
        effect = Definition.effect;
    }
}

typedef CardDef =
{
    name:String,
    image:String,
    type:String,
    effect:String
}

// @:enum
// abstract CardType(String) from String to String
// {
//     public var Action = "action";
//     public var Hazard = "hazard";
//     public var Treasure = "treasure";
// }

class DisplayCard extends FlxSprite
{
    public var showing:String = "";

    public function new():Void
    {
        super();

        frames = GraphicsCache.loadGraphicFromAtlas("cards", AssetPaths.cards__png, AssetPaths.cards__xml).atlasFrames;

        scrollFactor.set();
    }

    public function showAs(Show:String):Void
    {
        showing = Show;
        animation.frameName = "card_" + Show.toLowerCase() + ".png";
    }
}
