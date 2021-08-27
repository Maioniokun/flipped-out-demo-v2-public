package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

using StringTools;

class Startup extends MusicBeatState
{

    var splash:FlxSprite;
    //var dummy:FlxSprite;
    var loadingText:FlxText;

    var songsCached:Bool = Main.skipsound;
    var songs:Array<String> =   ["Tutorial", "Triggered", "Slaughter"];
                                
    //List of character graphics and some other stuff.
    //Just in case it want to do something with it later.
    var charactersCached:Bool = Main.skipcharacters;
    var characters:Array<String> =   ["BOYFRIEND", "BF_Carry", "flippy/FLIPPY_onslaught"];

    var graphicsCached:Bool = Main.skipgraphics;
    var graphics:Array<String> =    ["logoBumpin", "titleBG", "gfDanceTitle", "titleEnter",
                                    "stageback", "stagefront", "stagecurtains",];

    var cacheStart:Bool = false;

	override function create()
	{

        FlxG.mouse.visible = false;
        FlxG.sound.muteKeys = null;

        splash = new FlxSprite(0, 0);
        splash.frames = FlxAtlasFrames.fromSparrow('assets/images/fpsPlus/rozeSplash.png', 'assets/images/fpsPlus/rozeSplash.xml');
        splash.animation.addByPrefix('start', 'Splash Start', 24, false);
        splash.animation.addByPrefix('end', 'Splash End', 24, false);
        splash.visible = false;
        add(splash);
        splash.animation.play("start");
        splash.updateHitbox();

        loadingText = new FlxText(5, FlxG.height - 30, 0, "", 24);
        loadingText.setFormat("assets/fonts/vcr.ttf", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(loadingText);
        
        super.create();

    }

    override function update(elapsed) 
    {
        
        if(splash.animation.curAnim.finished && splash.animation.curAnim.name == "start" && !cacheStart){
            preload(); 
            cacheStart = true;
        }
        if(splash.animation.curAnim.finished && splash.animation.curAnim.name == "end"){
            FlxG.switchState(new TitleVidState());
            
        }

        if(songsCached && charactersCached && graphicsCached && !(splash.animation.curAnim.name == "end")){
            
            splash.animation.play("end");
            splash.updateHitbox();
            splash.screenCenter();

            new FlxTimer().start(0.3, function(tmr:FlxTimer)
            {
                loadingText.text = "Done!";
            });

            //FlxG.sound.play("assets/sounds/loadComplete.ogg");
        }
        
        super.update(elapsed);

    }

    function preload(){

        loadingText.text = "Preloading Assets...";

        if(!songsCached){
            sys.thread.Thread.create(() -> {
                preloadMusic();
            });
        }

        if(!charactersCached){
            sys.thread.Thread.create(() -> {
                preloadCharacters();
            });
        }

        if(!graphicsCached){
            sys.thread.Thread.create(() -> {
                preloadGraphics();
            });
        }

    }

    function preloadMusic(){
        for(x in songs){
            FlxG.sound.cache("assets/music/" + x + "_Inst.ogg");
            trace("Chached " + x);
        }
        loadingText.text = "Songs cached...";
        songsCached = true;
    }

    function preloadCharacters(){
        for(x in characters){
            ImageCache.add("assets/images/" + x + ".png");
            trace("Chached " + x);
        }
        loadingText.text = "Characters cached...";
        charactersCached = true;
    }

    function preloadGraphics(){
        for(x in graphics){
            ImageCache.add("assets/images/" + x + ".png");
            trace("Chached " + x);
        }
        loadingText.text = "Graphics cached...";
        graphicsCached = true;
    }

}
