package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	public static var startingSelection:Int = 0;
	var selector:FlxText;
	public static var curSelected:Int = 0;
	static var curDifficulty:Int = 2;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var bg:FlxSprite;
	var flipps:FlxSprite;
	var finishSlideMove:Bool = false;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{

		openfl.Lib.current.stage.frameRate = 144;

		curSelected = 0;

		var isDebug:Bool = true;

		if (StoryMenuState.weekUnlocked[0] || isDebug)
			addWeek(['Triggered', 'Slaughter'], 0, ['flippy']);

		// LOAD MUSIC
		/*for(x in songs){
			FlxG.sound.cache('assets/music/' + x.songName + "_Inst" + TitleState.soundExt);
		}*/

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic('assets/images/splashes/normalbg.png');
		add(bg);

		flipps = new FlxSprite().loadGraphic('assets/images/splashes/normalt.png');
		add(flipps);

		var sidebar = new FlxSprite(-80).loadGraphic('assets/images/menuSide.png');
		sidebar.scrollFactor.x = 0;
		sidebar.scrollFactor.y = 0;
		sidebar.setGraphicSize(Std.int(sidebar.width * 1));
		sidebar.updateHitbox();
		sidebar.screenCenter();
		sidebar.x -= 200;
		sidebar.antialiasing = true;
		FlxTween.tween(sidebar, {x: sidebar.x + 200}, 1, {ease: FlxEase.expoInOut});
		add(sidebar);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter, i);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
			FlxTween.tween(songText,{x: 40},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
				{
					finishSlideMove = true;
				}});
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 44, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		add(scoreText);

		changeSelection(startingSelection);
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));
			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;
			FlxG.stage.addChild(texFel);
			// scoreText.textField.htmlText = md;
			trace(md);
		 */

		var versionText = new FlxText(5, FlxG.height - 37, 0, 'Your singing skills are pretty strong!', 16);
		versionText.scrollFactor.set();
		versionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionText);

		var versionText2 = new FlxText(5, FlxG.height - 23, 0, 'Find me in the files for a good time...', 16);
		versionText2.scrollFactor.set();
		versionText2.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionText2);

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();
			FlxG.sound.play('assets/sounds/cancelMenu' + TitleState.soundExt);
			FlxG.switchState(new MainMenuState());
		}

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			startingSelection = curSelected;
			PlayState.returnLocation = "freeplay";
			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			FlxG.switchState(new PlayState());
			if (FlxG.sound.music != null)
				FlxG.sound.music.stop();
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

	flipps.y = 1000;

		if (curSelected == 0)
		{
			bg.loadGraphic('assets/images/splashes/normalbg.png');
			flipps.loadGraphic('assets/images/splashes/normalt.png');
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		else if (curSelected == 1)
		{
			bg.loadGraphic('assets/images/splashes/bloodbg.png');
			flipps.loadGraphic('assets/images/splashes/bloodt.png');
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		else
		{
			bg.loadGraphic('assets/images/menuDesat.png');
			FlxTween.tween(flipps,{y: 0}, 0.25 ,{ease: FlxEase.expoInOut});
		}
		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		FlxG.sound.playMusic('assets/music/' + songs[curSelected].songName + "_Inst" + TitleState.soundExt, 0);
		FlxG.sound.music.fadeIn(1, 0, 0.8);

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}