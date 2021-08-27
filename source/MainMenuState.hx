package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxAxes;

using StringTools;

class MainMenuState extends MusicBeatState
{
	
	var curSelected:Int = 1;

	var menuItems:FlxTypedGroup<FlxSprite>;
	
	//var configText:FlxText;
	//var configSelected:Int = 0;
	
	var optionShit:Array<String> = ['freeplay', 'story mode', "options"];

	var bg:FlxSprite;
	var bgf:FlxSprite;
	var flipster:FlxSprite;
	var sidebar:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	public static var finishSlideMove:Bool = false;
	public static var title:Int = 0;

	var versionText:FlxText;
	var keyWarning:FlxText;

	override function create()
	{

		openfl.Lib.current.stage.frameRate = 144;

		if (!FlxG.sound.music.playing)
		{	
			FlxG.sound.playMusic("assets/music/freakyMenu.ogg");
		}

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(-80).loadGraphic('assets/images/splashes/menuBG.png');
		bg.scrollFactor.x = 0.1;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.18));
		bg.updateHitbox();
		bg.screenCenter();
		bg.y += 1000;
		bg.antialiasing = true;
		FlxTween.tween(bg,{y: bg.y - 1000}, 1 ,{ease: FlxEase.expoInOut});

		bgf = new FlxSprite(-80).loadGraphic('assets/images/splashes/menuSpark.png');
		bgf.scrollFactor.x = 0.05;
		bgf.scrollFactor.y = 0;
		bgf.setGraphicSize(Std.int(bgf.width * 0.8));
		bgf.updateHitbox();
		bgf.screenCenter();
		bgf.y += 1000;
		bgf.antialiasing = true;
		FlxTween.tween(bgf,{y: bgf.y - 1000}, 1 ,{ease: FlxEase.expoInOut});

		flipster = new FlxSprite(-80).loadGraphic('assets/images/splashes/menuFlip.png');
		flipster.scrollFactor.x = 0;
		flipster.scrollFactor.y = 0;
		flipster.updateHitbox();
		flipster.screenCenter();
		flipster.y += 1000;
		flipster.antialiasing = true;
		FlxTween.tween(flipster,{y: flipster.y - 1000}, 1 ,{ease: FlxEase.expoInOut});

		sidebar = new FlxSprite(-80).loadGraphic('assets/images/menuBottom.png');
		sidebar.scrollFactor.x = 0;
		sidebar.scrollFactor.y = 0;
		sidebar.setGraphicSize(Std.int(sidebar.width * 1));
		sidebar.updateHitbox();
		sidebar.screenCenter();
		sidebar.y += 400;
		sidebar.antialiasing = true;
		FlxTween.tween(sidebar, {y: sidebar.y - 400}, 1, {ease: FlxEase.expoInOut});
		
		add(bg);

		if (title == 1)
			{
				bg.loadGraphic('assets/images/splashes/menu2BG.png');
				flipster.loadGraphic('assets/images/splashes/menu2Flip.png');
				add(bgf);
			}
		
		add(flipster);

		add(sidebar);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = FlxAtlasFrames.fromSparrow('assets/images/FNF_main_menu_assets.png', 'assets/images/FNF_main_menu_assets.xml');
		var texMod = FlxAtlasFrames.fromSparrow('assets/images/FNF_mod_menu_assets.png', 'assets/images/FNF_mod_menu_assets.xml');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(75, 600);
			if(optionShit[i] == "mod") {
				menuItem.frames = texMod;
			}
			else {
				menuItem.frames = tex;
			}
			
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.scale.set(0.6, 0.6);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.x += ((i * i) * 10) + (i * 400);
			if (i == 1){
				menuItem.screenCenter(FlxAxes.X);
				menuItem.x += 70;
			}
			finishSlideMove = true; 			
		}

		FlxG.camera.follow(camFollow, null, 0.004);

		versionText = new FlxText(5, FlxG.height - 21, 0, Assets.getText('assets/data/version.txt'), 16);
		versionText.scrollFactor.set();
		versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionText);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();
		
		//Offset Stuff
		Config.reload();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
	
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			
			if (controls.LEFT_P)
			{
				FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
				changeItem(1);
			}

			if (controls.RIGHT_P)
			{
				FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.BACKSPACE)
			{
				KeyBinds.resetBinds();
				FlxG.switchState(new MainMenuState());
			}

			if (FlxG.keys.justPressed.SEVEN)
			{
				PlayState.SONG = Song.loadFromJson('tutorial-hard', 'tutorial');
				PlayState.isStoryMode = true;
				PlayState.storyDifficulty = 2;
				PlayState.returnLocation = "main";
				FlxG.switchState(new PlayState());
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleStateNormal());
			}

			if (controls.ACCEPT)
			{
			
				//Config.write(offsetValue, accuracyType, healthValue / 10.0, healthDrainValue / 10.0);
			
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game", "&"]);
					#else
					FlxG.openURL('https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game');
					#end
				}

				else
				{
					selectedSomethin = true;
					FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt);
					
					var daChoice:String = optionShit[curSelected];
					
					switch (daChoice){
						case 'freeplay':
							FlxG.sound.music.stop();
						case 'options':
							FlxG.sound.music.stop();
					}

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxTween.tween(flipster,{y: 1300}, 1 ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
							{
								flipster.kill();
							}});
							FlxTween.tween(bgf,{y: 1300}, 1 ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
							{
								bgf.kill();
							}});
							FlxTween.tween(bg,{y: 1300}, 1 ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
							{
								bg.kill();
							}});
							FlxTween.tween(sidebar, {y: 1300}, 1, {ease: FlxEase.expoInOut});

							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								//var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										PlayState.storyPlaylist = ['Triggered','Slaughter'];
										PlayState.isStoryMode = true;

										var diffic = '-hard';

										PlayState.storyDifficulty = 2;
										PlayState.storyWeek = 0;

										PlayState.returnLocation = "main";
										PlayState.campaignScore = 0;

										PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
										new FlxTimer().start(1, function(tmr:FlxTimer)
										{
											if (FlxG.sound.music != null)
											FlxG.sound.music.stop();
											FlxG.switchState(new PlayState());
										});
										trace("Story Menu Selected");
									case 'freeplay':
										FreeplayState.startingSelection = 0;
										FlxG.switchState(new FreeplayState());
										trace("Freeplay Menu Selected");
									case 'options':
										FlxG.switchState(new ConfigMenu());
										trace("options time");
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

	}

	function changeItem(huh:Int = 0)
	{
		if (finishSlideMove)
			{
				curSelected += huh;
	
				if (curSelected >= menuItems.length)
					curSelected = 0;
				if (curSelected < 0)
					curSelected = menuItems.length - 1;
			}

		curSelected += huh;
		//configSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
 		if (curSelected < 0)
			curSelected = menuItems.length - 1;
			
		/*if (configSelected > 3)
			configSelected = 0;
		if (configSelected < 0)
			configSelected = 3;*/

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishSlideMove)
				{
					spr.animation.play('selected');
					camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				}

			spr.updateHitbox();
		});
	}
}
