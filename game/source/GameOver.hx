package;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween.FlxTweenType;
import openfl.ui.GameInput;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import axollib.AxolAPI.GameData;
import flixel.FlxSubState;

class GameOver extends FlxSubState
{
    private var bg:FlxSprite;
    private var game:FlxSprite;
    private var over:FlxSprite;
    private var scoreText1:GameText;
    private var scoreText2:GameText;
    private var pressAnyText:GameText;

    private var ready:Bool = false;

    public function new(Score:Int = 0):Void
    {
        super();

        bg = new FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = 0;
        bg.scrollFactor.set();
        add(bg);

        game = new FlxSprite(0, 0, AssetPaths.game__png);
        game.screenCenter(FlxAxes.X);
        game.y -= game.height;
        game.scrollFactor.set();
        add(game);

        over = new FlxSprite(0, 0, AssetPaths.over__png);
        over.screenCenter(FlxAxes.X);
        over.y -= over.height;
        over.scrollFactor.set();
        add(over);

        scoreText1 = new GameText(0, 0, "Your final score is:", "white");
        scoreText1.screenCenter(FlxAxes.XY);
        scoreText1.y -= scoreText1.height + 16;
        scoreText1.alpha = 0;
        add(scoreText1);

        scoreText2 = new GameText(0, 0, "$" + Std.string(Score), "gold");
        scoreText2.screenCenter(FlxAxes.XY);
        scoreText2.y += 16;
        scoreText2.alpha = 0;
        add(scoreText2);

        pressAnyText = new GameText(0, 0, "Press Any Key to Play Again");
        pressAnyText.screenCenter(FlxAxes.X);
        pressAnyText.y = FlxG.height - pressAnyText.height - 32;
        pressAnyText.alpha = 0;
        add(pressAnyText);
    }

    override public function create():Void
    {
        FlxG.sound.play(AssetPaths.game_over__wav, .5);
        FlxTween.tween(game, {y: (FlxG.height * .25) - (game.height / 2)}, 1, {type: FlxTweenType.ONESHOT, ease: FlxEase.backOut});
        FlxTween.tween(over, {y: (FlxG.height * .25) - (game.height / 2)}, 1, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.backOut,
            startDelay: .5,
            onComplete: (_) ->
            {
                FlxTween.tween(bg, {alpha: .8}, .5, {
                    type: FlxTweenType.ONESHOT,
                    ease: FlxEase.sineOut,
                    onComplete: (_) ->
                    {
                        FlxTween.tween(scoreText1, {alpha: 1}, .5, {type: FlxTweenType.ONESHOT, ease: FlxEase.sineOut});
                        FlxTween.tween(scoreText2, {alpha: 1}, .5, {
                            type: FlxTweenType.ONESHOT,
                            ease: FlxEase.sineOut,
                            startDelay: .25,
                            onComplete: (_) ->
                            {
                                FlxTween.tween(pressAnyText, {alpha: 1}, .5, {
                                    type: FlxTweenType.ONESHOT,
                                    ease: FlxEase.sineOut,
                                    startDelay: 1,
                                    onComplete: (_) ->
                                    {
                                        ready = true;
                                        FlxTween.tween(pressAnyText, {alpha: .5}, .2, {type: FlxTweenType.PINGPONG, ease: FlxEase.sineInOut});
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });

        super.create();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (ready && PlayState.action.triggered)
        {
            FlxG.sound.play(AssetPaths.pickup__wav);
            ready = false;
            FlxG.switchState(new PlayState());
        }
    }
}
