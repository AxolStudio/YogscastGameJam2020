package;

import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import flixel.util.FlxAxes;
import flixel.group.FlxGroup;
import BlockParticles.BlockParticle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera.FlxCameraFollowStyle;
import hscript.Interp;
import hscript.Parser;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxAction.FlxActionDigital;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Card.DisplayCard;
import flixel.FlxG;
import haxe.Json;
import haxe.DynamicAccess;
import lime.utils.Assets;
import Card.CardDef;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxState;

class PlayState extends FlxState
{
    private var paused:Bool = true;

    public static var inputs:FlxActionManager;
    public static var left:FlxActionDigital;
    public static var right:FlxActionDigital;
    public static var action:FlxActionDigital;

    public var cardDefinitons:Map<String, CardDef>;
    public var deckDefinitions:Map<String, Map<String, Int>>;
    public var deck:Array<Card>;
    public var hand:Array<Card>;
    public var discard:Array<Card>;

    public var handDisplay:HandDisplay;

    public var world:World;

    public var player:Player;

    public var deckDisplay:DisplayCard;
    public var discardDisplay:DisplayCard;

    private var cardsToGive:Int = 0;

    private var showCard:DisplayCard;

    private var gameState:String = "starting";
    private var showCardTween:FlxTween;

    public var playerControl:Bool = false;

    public var moveCooldown:Float = .33;

    public var playerTween:FlxTween;

    public var digDirs:Array<String>;

    public var playerMoving:Bool = false;

    public var wait:Float = 0;
    public var explosions:FlxTypedGroup<BlockParticles>;

    // public var explosion:BlockParticles;
    public var enemies:FlxTypedGroup<Enemy>;

    public var depthText:GameText;
    public var scoreText:GameText;

    public var score:Int = 0;

    public var hud:FlxGroup;

    public var health:Int = 5;
    public var maxHealth:Int = 5;

    public var energy:Int = 3;
    public var maxEnergy:Int = 3;

    public var healthBar:FlxBar;
    public var energyBar:FlxBar;

    public var treasure:FlxTypedGroup<Treasure>;
    public var tmpCards:Array<DisplayCard>;

    public var shock:FlxSprite;

    public var shocking:Bool = false;

    public var shockTween:FlxTween;

    public var magneting:Bool = false;
    public var magList:Array<Treasure>;
    public var treasureTweens:Array<FlxTween>;

    override public function create():Void
    {
        FlxG.sound.playMusic(AssetPaths.diggydeck_music__ogg, .5);

        bgColor = FlxColor.CYAN;

        initializeInput();

        // add the world

        enemies = new FlxTypedGroup<Enemy>();
        treasure = new FlxTypedGroup<Treasure>();

        world = new World(this);

        add(world);

        // add the player

        player = new Player();
        // player.makeGraphic(World.TILE_SIZE, World.TILE_SIZE, FlxColor.RED);
        player.x = ((world.worldWidth / 2) * World.TILE_SIZE);
        player.y = 3 * World.TILE_SIZE;

        add(player);

        add(enemies);

        shock = new FlxSprite(0, 0, AssetPaths.shock__png);
        shock.visible = false;
        add(shock);

        add(treasure);

        // set up particles

        explosions = new FlxTypedGroup<BlockParticles>(20);
        add(explosions);

        for (i in 0...20)
        {
            explosions.add(new BlockParticles());
        }
        // explosion = new BlockParticles();
        // explosions.add(explosion);

        // set up camera

        FlxG.camera.setScrollBounds(0, world.layers[0].width, 0, FlxG.height);
        FlxG.camera.follow(player, FlxCameraFollowStyle.PLATFORMER, .25);
        FlxG.camera.snapToTarget();

        // load card definitons

        loadCardDefs();

        // load deck

        initializeDeck();

        // add the deck

        deckDisplay = new DisplayCard();
        deckDisplay.showAs("back");

        deckDisplay.x = 32;
        deckDisplay.y = FlxG.height - 32 - deckDisplay.height;
        add(deckDisplay);

        discardDisplay = new DisplayCard();
        discardDisplay.showAs("discard");
        discardDisplay.x = FlxG.width - discardDisplay.width - 32;
        discardDisplay.y = FlxG.height - 32 - discardDisplay.height;
        add(discardDisplay);

        // add the hand display

        handDisplay = new HandDisplay(this);
        add(handDisplay);

        showCard = new DisplayCard();
        showCard.x = deckDisplay.x;
        showCard.y = deckDisplay.y;
        add(showCard);
        showCard.visible = false;

        tmpCards = new Array<DisplayCard>();
        var t:DisplayCard;
        for (i in 0...10)
        {
            t = new DisplayCard();
            t.x = discardDisplay.x;
            t.y = discardDisplay.y;

            tmpCards.push(t);
            add(t);
            t.visible = false;
        }

        cardsToGive = 5;

        digDirs = [];

        // add the UI

        hud = new FlxGroup();
        add(hud);

        scoreText = new GameText(0, 8, "$0", "gold");
        scoreText.screenCenter(FlxAxes.X);
        hud.add(scoreText);

        depthText = new GameText(0, scoreText.y + scoreText.height + 8, "Depth: 0");
        depthText.screenCenter(FlxAxes.X);
        hud.add(depthText);

        energyBar = new FlxBar(32, 32, FlxBarFillDirection.BOTTOM_TO_TOP, 48, 240, this, "energy", 0, maxEnergy, true);
        energyBar.createColoredFilledBar(FlxColor.CYAN, true, FlxColor.WHITE);
        energyBar.createColoredEmptyBar(FlxColor.CYAN.getDarkened(.6), true, FlxColor.WHITE);
        energyBar.scrollFactor.set();

        hud.add(energyBar);

        var eIcon:FlxSprite = new FlxSprite(0, 0, AssetPaths.energy__png);
        eIcon.x = energyBar.x + (energyBar.width / 2) - (eIcon.width / 2);
        eIcon.y = energyBar.y + energyBar.height - (eIcon.height * .33);
        eIcon.scrollFactor.set();
        add(eIcon);

        healthBar = new FlxBar(112, 32, FlxBarFillDirection.BOTTOM_TO_TOP, 48, 240, this, "health", 0, maxHealth, true);
        healthBar.createColoredFilledBar(FlxColor.RED, true, FlxColor.WHITE);
        healthBar.createColoredEmptyBar(FlxColor.RED.getDarkened(.6), true, FlxColor.WHITE);

        healthBar.scrollFactor.set();

        hud.add(healthBar);

        var hIcon:FlxSprite = new FlxSprite(0, 0, AssetPaths.health__png);
        hIcon.x = healthBar.x + (healthBar.width / 2) - (hIcon.width / 2);
        hIcon.y = healthBar.y + healthBar.height - (hIcon.height * .33);
        hIcon.scrollFactor.set();
        add(hIcon);

        magList = [];
        treasureTweens = [];

        FlxG.camera.fade(FlxColor.WHITE, .66, true, () ->
        {
            paused = false;
        });

        super.create();
    }

    private function initializeInput():Void
    {
        left = new FlxActionDigital();
        right = new FlxActionDigital();
        action = new FlxActionDigital();

        if (inputs == null)
        {
            inputs = FlxG.inputs.add(new FlxActionManager());
        }

        inputs.addActions([left, right, action]);

        left.addKey(A, PRESSED);
        left.addKey(LEFT, PRESSED);
        left.addGamepad(DPAD_LEFT, PRESSED);
        left.addGamepad(LEFT_STICK_DIGITAL_LEFT, PRESSED);

        right.addKey(D, PRESSED);
        right.addKey(RIGHT, PRESSED);
        right.addGamepad(DPAD_RIGHT, PRESSED);
        right.addGamepad(LEFT_STICK_DIGITAL_RIGHT, PRESSED);

        action.addKey(ENTER, PRESSED);
        action.addKey(SPACE, PRESSED);
        action.addKey(X, PRESSED);
        action.addGamepad(A, PRESSED);
        action.addGamepad(B, PRESSED);
        action.addGamepad(X, PRESSED);
        action.addGamepad(Y, PRESSED);
    }

    private function initializeDeck():Void
    {
        deckDefinitions = [];
        var deckText:String = Assets.getText(AssetPaths.deckDefinitions__json);
        var defs:DynamicAccess<DynamicAccess<Dynamic>> = Json.parse(deckText);
        var tmpDeck:Map<String, Int>;
        for (k => v in defs)
        {
            tmpDeck = [];
            for (k2 => v2 in v)
            {
                tmpDeck.set(k2, v2);
            }
            deckDefinitions.set(k, tmpDeck);
        }

        deck = [];
        hand = [];
        discard = [];
        tmpDeck = deckDefinitions.get("starting");
        for (k => v in tmpDeck)
            for (i in 0...v)
                deck.push(new Card(cardDefinitons.get(k)));

        FlxG.random.shuffle(deck);
    }

    private function loadCardDefs():Void
    {
        cardDefinitons = [];
        var defText:String = Assets.getText(AssetPaths.cardDefinitions__json);
        var defs:DynamicAccess<Dynamic> = Json.parse(defText);
        for (k => v in defs)
        {
            cardDefinitons.set(k, {
                name: v.name,
                image: v.image,
                type: Std.string(v.type),
                effect: v.effect
            });
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
#if debug
        // if (paused && action.triggered)
        //     paused = false;
#end

        if (paused)
            return;

        if (wait > 0)
            wait -= elapsed;

        if (health <= 0 || energy <= 0)
        {
            FlxG.sound.music.stop();
            openSubState(new GameOver(score));
            return;
        }

        if (!playerMoving && !handDisplay.anyTweening && !showCard.visible && !world.shifting && wait <= 0)
        {
            if (magneting)
            {
                if (magList.length <= 0)
                    magneting = false;
                return;
            }
            else if (shocking)
            {
                return;
            }
            else if (emptyBlockBelow())
            {
                playerJumpDown();
            }
            else if (digDirs.length > 0)
            {
                var dir:String = digDirs.shift();
                // we're digging

                var l:Int = getPlayerLayer();
                var c:Int = Std.int(player.x / World.TILE_SIZE);

                l++;
                switch (dir)
                {
                    case "down":

                    case "left":
                        c--;
                    case "right":
                        c++;
                }

                if (hitBlock(c, l))
                {
                    // we can move into that block!
                    playerJumpDown(dir);
                }
                else
                {
                    wait = .25;
                }
                return;
            }
            else if (cardsToGive > 0)
            {
                if (deck.length <= 0)
                {
                    // out of cards
                    energy--;
                    reShuffle();
                }
                else
                {
                    cardsToGive--;
                    flipShowCard();
                }
                return;
            }
            else if (cardsToGive == 0 && !playerControl && digDirs.length <= 0)
                playerControl = true;
        }

        if (playerControl)
        {
            if (moveCooldown > 0)
                moveCooldown -= elapsed;
        }
    }

    public function playerJumpDown(Dir:String = ""):Void
    {
        playerMoving = true;
        world.shiftUp();
        playerTween = FlxTween.tween(player, {
            x: Dir == "left" ? player.x - World.TILE_SIZE : Dir == "right" ? player.x + World.TILE_SIZE : player.x
        }, .33, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.sineInOut,
            startDelay: .2,
            onStart: (_) ->
            {
                player.animation.play("jump");
                FlxG.sound.play(AssetPaths.jump__wav, .2);
            },
            onComplete: (_) ->
            {
                depthText.text = "Depth: " + Std.string(world.depth);
                depthText.screenCenter(FlxAxes.X);
                // check the contents of this space!
                // could be an enemy or treasure

                checkNewTile();

                playerMoving = false;
            }
        });
    }

    public function checkNewTile():Void
    {
        var layer:Int = getPlayerLayer();
        var column:Int = Std.int(player.x / World.TILE_SIZE);
        var eCol:Int;
        var eLayer:Int;
        for (e in enemies)
        {
            if (e.alive)
            {
                eCol = getEnemyColumn(e);
                eLayer = getEnemyLayer(e);
                if (eCol == column && eLayer == layer)
                {
                    health -= e.damage * (Std.int(world.depth / 40) + 1);
                    player.animation.play("hurt");
                    FlxG.sound.play(AssetPaths.hurt__wav, .2);
                    if (e.squishable)
                        e.squish();
                    else
                        e.hit();
                }
            }
        }

        for (t in treasure)
        {
            if (t.alive)
            {
                if (t.column == column && t.parent.y == player.y)
                {
                    getTreasure(t);
                }
            }
        }
    }

    public function getTreasure(T:Treasure):Void
    {
        FlxG.sound.play(AssetPaths.pickup__wav, .2);
        if (T.treasureType == "healthpickup")
        {
            health = Std.int(Math.min(health + 1, maxHealth));
        }
        else if (T.treasureType == "energypickup")
        {
            energy = Std.int(Math.min(energy + 1, maxEnergy));
        }
        else
        {
            // maybe animate treasure?
            score += switch (T.treasureType)
                {
                    case "coinBronze": 1;
                    case "coinSilver": 5;
                    case "coinGold": 10;
                    case "gem1": 25;
                    case "gem2": 50;
                    case "gem3": 100;
                    case "gem4": 200;

                    default: 0;
                }
            scoreText.text = "$" + Std.string(score);
            scoreText.screenCenter(FlxAxes.X);
        }
        T.kill();
    }

    public function getEnemyColumn(E:Enemy):Int
    {
        return Std.int(E.xbounds.x / World.TILE_SIZE);
    }

    public function getEnemyLayer(E:Enemy):Int
    {
        for (i in 0...world.layers.length)
        {
            if (world.layers[i].y == E.parent.y)
                return i;
        }
        return -1;
    }

    public function getPlayerLayer():Int
    {
        for (i in 0...world.layers.length)
        {
            if (world.layers[i].y == player.y)
                return i;
        }
        return -1;
    }

    public function emptyBlockBelow():Bool
    {
        var layer:Int = getPlayerLayer();
        var column:Int = Std.int(player.x / World.TILE_SIZE);
        return world.layers[layer + 1].getTileByIndex(column) == 0;
    }

    public function isEmptyBlock(C:Int, L:Int):Bool
    {
        return world.layers[L].getTileByIndex(C) == 0;
    }

    public function hitBlock(Column:Int, Layer:Int):Bool
    {
        var broken:Bool = false;
        var tileID:Int = world.layers[Layer].getTileByIndex(Column);

        switch (tileID)
        {
            case 2 | 4 | 5 | 7 | 8 | 9:
                world.layers[Layer].setTileByIndex(Column, tileID + 1, true);
            case 0:
                broken = true;
            default:
                world.layers[Layer].setTileByIndex(Column, 0, true);
                explode(Column * World.TILE_SIZE, (Layer - 1) * World.TILE_SIZE);
                broken = true;
        }
        return broken;
    }

    public function explode(X:Float, Y:Float):Void
    {
        var explosion:BlockParticles = explosions.recycle(BlockParticles, BlockParticles.new);
        explosion.spawn(X, Y);
        FlxG.sound.play(AssetPaths.drill__wav, .2);
    }

    public function reShuffle():Void
    {
        for (i in 0...discard.length)
            deck.push(discard.pop());
        FlxG.random.shuffle(deck);
        discardDisplay.showAs("discard");
        FlxG.sound.play(AssetPaths.shuffle__wav, .2);
        for (i in 0...tmpCards.length)
        {
            tmpCards[i].showAs("back");
            tmpCards[i].x = discardDisplay.x;
            tmpCards[i].y = discardDisplay.y;
            tmpCards[i].visible = true;
            FlxTween.tween(tmpCards[i], {x: deckDisplay.x}, .66, {
                type: FlxTweenType.ONESHOT,
                ease: FlxEase.sineInOut,
                startDelay: (.02 * i) + .15,
                onComplete: (_) ->
                {
                    tmpCards[i].visible = false;
                },
                onUpdate: (_) ->
                {
                    tmpCards[i].y = deckDisplay.y - (300 - Math.abs(((tmpCards[i].x - deckDisplay.x) / (discardDisplay.x - deckDisplay.x) * 600) - 300));
                }
            });
        }

        showCard.showAs("back");
        showCard.x = discardDisplay.x;
        showCard.y = discardDisplay.y;
        showCard.visible = true;
        showCardTween = FlxTween.tween(showCard, {x: deckDisplay.x}, .66, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.sineInOut,
            startDelay: (.02 * tmpCards.length) + .15,
            onComplete: (_) ->
            {
                showCard.visible = false;
                deckDisplay.showAs("back");
            },
            onUpdate: (_) ->
            {
                showCard.y = deckDisplay.y - (300 - Math.abs(((showCard.x - deckDisplay.x) / (discardDisplay.x - deckDisplay.x) * 600) - 300));
            }
        });
    }

    public function flipShowCard():Void
    {
        showCard.showAs("back");
        showCard.x = deckDisplay.x;
        showCard.y = deckDisplay.y;
        showCard.visible = true;
        hand.push(deck.shift());
        if (deck.length <= 0)
            deckDisplay.showAs("discard");

        showCardTween = FlxTween.tween(showCard, {x: (FlxG.width / 2) - (showCard.width / 2), y: (FlxG.height * .75) - (showCard.width / 2)}, .2, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.backOut,
            startDelay: .1,
            onComplete: (_) ->
            {
                FlxG.sound.play(AssetPaths.draw_card__wav, .2);
                showCardTween = FlxTween.tween(showCard, {"scale.x": 0,}, .1, {
                    type: FlxTweenType.ONESHOT,
                    ease: FlxEase.circOut,
                    onComplete: (_) ->
                    {
                        showCard.showAs(hand[hand.length - 1].image);
                        showCardTween = FlxTween.tween(showCard, {"scale.x": 1}, .1, {
                            type: FlxTweenType.ONESHOT,
                            ease: FlxEase.circIn,
                            onComplete: (_) ->
                            {
                                showCardTween = FlxTween.tween(showCard, {y: FlxG.height - 140}, .25, {
                                    type: FlxTweenType.ONESHOT,
                                    ease: FlxEase.backIn,
                                    startDelay: .2,
                                    onComplete: (_) ->
                                    {
                                        showCard.visible = false;
                                        showCard.x = deckDisplay.x;
                                        showCard.y = deckDisplay.y;

                                        handDisplay.addCard(hand[hand.length - 1]);
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });
    }

    public function useCard(Id:Int):Void
    {
        var newHand:Array<Card> = [];
        var newDisHand:Array<DisplayCard> = [];
        var playedCard:Card;

        playedCard = hand[Id];

        // trace(Id, playedCard.image);

        for (i in 0...hand.length)
        {
            if (i != Id)
            {
                newHand.push(hand[i]);
                newDisHand.push(handDisplay.cards[i]);
            }
        }

        showCard.x = handDisplay.cards[Id].x;
        showCard.y = handDisplay.cards[Id].y;

        // trace(Id, playedCard.image);

        showCard.showAs(playedCard.image);
        handDisplay.cards[Id].kill();
        handDisplay.cards = newDisHand;

        discard.push(playedCard);
        hand = newHand.copy();

        showCard.visible = true;
        showCardTween = FlxTween.tween(showCard, {x: (FlxG.width / 2) - (showCard.width / 2), y: (FlxG.height / 2) - (showCard.height / 2)}, .25, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.backOut,
            onComplete: (_) ->
            {
                handDisplay.sortHand();
                showCardTween = FlxTween.tween(showCard, {x: discardDisplay.x, y: discardDisplay.y}, .25, {
                    type: FlxTweenType.ONESHOT,
                    ease: FlxEase.backIn,
                    startDelay: 1,
                    onComplete: (_) ->
                    {
                        showCard.visible = false;
                        discardDisplay.visible = true;
                        discardDisplay.showAs(playedCard.image);
                        handDisplay.sortHand();
                        doCardEffect(playedCard.effect);
                    }
                });
            }
        });
    }

    public function dig(Dir:String, Amount:Int):Void
    {
        for (i in 0...Amount)
        {
            digDirs.push(Dir);
        }
    }

    public function doShock():Void
    {
        player.animation.play("down");

        FlxG.sound.play(AssetPaths.shock__wav, .2);

        shocking = true;
        shock.x = player.x + (player.width / 2) - (shock.width / 2);
        shock.y = player.y + World.TILE_SIZE;
        shock.alpha = 0;
        shock.visible = true;
        shockTween = FlxTween.tween(shock, {alpha: 1}, .1, {
            type: FlxTweenType.ONESHOT,
            ease: FlxEase.circInOut,
            onComplete: (_) ->
            {
                shockTween = FlxTween.tween(shock, {alpha: .5}, .1, {
                    type: FlxTweenType.ONESHOT,
                    ease: FlxEase.circInOut,
                    onComplete: (_) ->
                    {
                        var layer:Int = getPlayerLayer() + 1;
                        var column:Int = Std.int(player.x / World.TILE_SIZE) - 1;
                        var eCol:Int;
                        var eLayer:Int;
                        for (e in enemies)
                        {
                            if (e.alive)
                            {
                                eCol = getEnemyColumn(e);
                                eLayer = getEnemyLayer(e);
                                if ((eCol >= column && eCol <= column + 2) && (eLayer >= layer && eLayer <= layer + 2))
                                {
                                    e.hit();
                                    world.addHealth(eCol, eLayer);
                                }
                            }
                        }

                        shockTween = FlxTween.tween(shock, {alpha: 1}, .1, {
                            type: FlxTweenType.ONESHOT,
                            ease: FlxEase.circInOut,
                            onComplete: (_) ->
                            {
                                shockTween = FlxTween.tween(shock, {alpha: 0}, .1, {
                                    type: FlxTweenType.ONESHOT,
                                    ease: FlxEase.circInOut,
                                    onComplete: (_) ->
                                    {
                                        shock.visible = false;
                                        shocking = false;
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });
    }

    public function magnet():Void
    {
        // find each treasure/pickup that is within 2 tiles of the player
        magneting = true;
        magList = [];
        treasureTweens = [];
        var column:Int = Std.int(player.x / World.TILE_SIZE);

        for (t in treasure)
        {
            if (t.alive)
            {
                if (t.column >= column - 2
                    && t.column <= column + 2
                    && t.parent.y >= player.y - (World.TILE_SIZE * 2)
                    && t.parent.y <= player.y + (World.TILE_SIZE * 2))
                {
                    magList.push(t);
                    t.magneted = true;
                    // move them all towards the player
                    treasureTweens.push(FlxTween.tween(t, {x: player.x, y: player.y},
                        (Std.int(FlxMath.distanceBetween(t, player) / World.TILE_SIZE) + 1) * .2, {
                        type: FlxTweenType.ONESHOT,
                        ease: FlxEase.cubeIn,
                        onComplete: (_) ->
                        {
                            magList.remove(t);
                            // when they are in the same tile as the player, pick them up
                            getTreasure(t);
                        }
                    }));
                }
            }
        }
    }

    public function doCardEffect(CardEffect:String):Void
    {
        // effects: down #, left #, right #

        var parser:Parser = new Parser();
        var program = parser.parseString(CardEffect);
        var interp:Interp = new Interp();

        interp.variables.set("dig", dig);
        interp.variables.set("shock", doShock);
        interp.variables.set("magnet", magnet);

        interp.execute(program);

        cardsToGive++;
    }
}
