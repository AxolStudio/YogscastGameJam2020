package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.util.FlxSort;
import Card.DisplayCard;
import StringTools;

using StringTools;

class HandDisplay extends FlxTypedGroup<DisplayCard>
{
    public var parent:PlayState;

    public var cards:Array<DisplayCard>;

    private var leftBuff:Float = 35;
    private var rightBuff:Float = FlxG.width - 35;

    private var maxDistance:Float = 10;
    private var minDistance:Float = -100;

    public var tweening:Array<FlxTween>;
    public var anyTweening(get, null):Bool;

    public var selectedCard:Int = -1;

    public function new(Parent:PlayState):Void
    {
        super();

        parent = Parent;
        cards = [];
        tweening = [];
    }

    public function sortHand():Void
    {
        sort(sortByX, FlxSort.ASCENDING);

        var space:Float = ((rightBuff - leftBuff) / cards.length) - 140;
        space = Math.min(space, maxDistance);
        space = Math.max(minDistance, space);
        var width:Float = (space + 140) * cards.length;
        var centerX:Float = width / 2;
        var startX:Float = (FlxG.width / 2) - centerX;

        tweening = [];
        for (i in 0...cards.length)
        {
            tweening.push(FlxTween.tween(cards[i], {x: startX + ((140 + space) * i)}, .1, {type: FlxTweenType.ONESHOT, ease: FlxEase.sineOut}));
        }
    }

    private function sortByX(Order:Int, Obj1:DisplayCard, Obj2:DisplayCard):Int
    {
        return FlxSort.byValues(Order, Obj1.x, Obj2.x);
    }

    public function addCard(C:Card):Void
    {
        var dc:DisplayCard = recycle(DisplayCard);
        if (dc == null)
            dc = new DisplayCard();
        dc.revive();
        dc.showAs(C.image);
        dc.y = FlxG.height - 140;
        dc.x = (FlxG.width / 2) - (dc.width / 2);
        cards.push(dc);
        add(dc);
        sortHand();
    }

    private function get_anyTweening():Bool
    {
        var any:Bool = false;
        for (t in tweening)
        {
            if (!t.finished)
            {
                any = true;
                break;
            }
        }
        return any;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (parent.moveCooldown <= 0 && !anyTweening)
        {
            if (parent.playerControl && selectedCard < 0 && cards.length > 0)
            {
                changeSelectedCard(0);
            }
            else if (PlayState.left.triggered)
            {
                parent.moveCooldown = .1;

                changeSelectedCard(selectedCard == 0 ? cards.length - 1 : selectedCard - 1);
            }
            else if (PlayState.right.triggered)
            {
                parent.moveCooldown = .1;
                changeSelectedCard(selectedCard == cards.length - 1 ? 0 : selectedCard + 1);
            }
            else if (PlayState.action.triggered)
            {
                parent.moveCooldown = .1;
                parent.playerControl = false;
                // trace(selectedCard, cards[selectedCard].animation.frameName);

                if ((Std.int(parent.player.x / World.TILE_SIZE) <= 0 && cards[selectedCard].showing.startsWith("left"))
                    || (Std.int(parent.player.x / World.TILE_SIZE) >= parent.world.worldWidth - 1
                        && cards[selectedCard].showing.startsWith("right")))
                {
                    // no good
                }
                else
                {
                    parent.useCard(selectedCard);
                    selectedCard = -1;
                }
            }
        }
    }

    private function unShowOldCard(Index:Int, OnComplete:FlxTween->Void):Void
    {
        tweening.push(FlxTween.tween(cards[Index], {y: FlxG.height - 140}, .05, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.backOut,
            onComplete: OnComplete
        }));
    }

    private function showNewCard(Index:Int):Void
    {
        tweening.push(FlxTween.tween(cards[Index], {y: FlxG.height - 200}, .05, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.backIn,
            onComplete: (_) ->
            {
                tweening = [];
            }
        }));
    }

    public function changeSelectedCard(NewCard:Int):Void
    {
        tweening = [];
        if (selectedCard > -1)
        {
            unShowOldCard(selectedCard, (_) ->
            {
                showNewCard(NewCard);
            });
        }
        else
            showNewCard(NewCard);
        selectedCard = NewCard;
    }
}
