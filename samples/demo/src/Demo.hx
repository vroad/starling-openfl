package;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.display3D.Context3DRenderMode;
import openfl.errors.Error;
import openfl.geom.Rectangle;
import openfl.system.Capabilities;
import openfl.system.System;
import openfl.display.StageScaleMode;
import openfl.utils.ByteArray;

import haxe.Timer;

import openfl.Assets;
import openfl.Vector;

import starling.core.Starling;
import starling.display.Stage;
import starling.events.Event;
import starling.text.BitmapFont;
import starling.text.TextField;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import starling.assets.AssetManager;
import starling.utils.Max;
import starling.utils.RectangleUtil;
import starling.utils.StringUtil;

import utils.ProgressBar;

class Demo extends Sprite
{
    private var _starling:Starling;
    private var _background:Bitmap;
    private var _progressBar:ProgressBar;
	private var _assets:AssetManager;

    public function new()
    {
        super();
        if (stage != null) start();
        else addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onAddedToStage(event:Dynamic):Void
    {
        removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
        start();
    }

    private function start():Void
    {
        // We develop the game in a *fixed* coordinate system of 320x480. The game might
        // then run on a device with a different resolution; for that case, we zoom the
        // viewPort to the optimal size for any display and load the optimal textures.

        Starling.multitouchEnabled = true; // for Multitouch Scene

        _starling = new Starling(Game, stage, null, null, Context3DRenderMode.AUTO, "auto");
        _starling.stage.stageWidth = Constants.GameWidth;
        _starling.stage.stageHeight = Constants.GameHeight;
        _starling.enableErrorChecking = Capabilities.isDebugger;
        _starling.skipUnchangedFrames = true;
        _starling.simulateMultitouch = true;
        _starling.addEventListener(Event.ROOT_CREATED, function():Void
        {
            loadAssets(startGame);
        });
        
        this.stage.addEventListener(Event.RESIZE, onResize, false, Max.INT_MAX_VALUE, true);

        _starling.start();
        initElements();
    }

    private function loadAssets(onComplete:Void->Void):Void
    {
        _assets = new AssetManager();

        _assets.verbose = Capabilities.isDebugger;

		#if html5
		_assets.enqueue([
			"/assets/textures/1x/background.jpg",
			"/assets/textures/1x/atlas.png",
			"/assets/textures/1x/atlas.xml",
			"/assets/textures/1x/compressed_texture.atf",
			"/assets/fonts/1x/desyrel.png",
			"/assets/fonts/1x/desyrel.fnt",
			"/assets/audio/wing_flap.ogg"
		]);
		_assets.loadQueue(onComplete);
		#else
		Timer.delay(function()
        {
            var atlasTexture:Texture = Texture.fromBitmapData(Assets.getBitmapData("assets/textures/1x/atlas.png"), false);
            var atlasXml:Xml = Xml.parse(Assets.getText("assets/textures/1x/atlas.xml")).firstElement();
            var desyrelTexture:Texture = Texture.fromBitmapData(Assets.getBitmapData("assets/fonts/1x/desyrel.png"), false);
            var desyrelXml:Xml = Xml.parse(Assets.getText("assets/fonts/1x/desyrel.fnt")).firstElement();
            var compressedTexture:Texture = Texture.fromAtfData(Assets.getBytes("assets/textures/1x/compressed_texture.atf"));
			var bitmapFont = new BitmapFont(desyrelTexture, desyrelXml);
            TextField.registerCompositor(bitmapFont, bitmapFont.name);
			
			_assets.addAsset("atlas", new TextureAtlas(atlasTexture, atlasXml));
            _assets.addAsset("background", Texture.fromBitmapData(Assets.getBitmapData("assets/textures/1x/background.jpg")));
            #if flash
            _assets.addAsset("wing_flap", Assets.getSound("assets/audio/wing_flap.mp3"));
            #else
            _assets.addAsset("wing_flap", Assets.getSound("assets/audio/wing_flap.ogg"));
            #end
            _assets.addAsset("compressed_texture", compressedTexture);
            
            onComplete();
        }, 0);		
		#end
    }

    private function startGame():Void
    {
        var game:Game = cast(_starling.root, Game);
        game.start(_assets);
        Timer.delay(removeElements, 150); // delay to make 100% sure there's no flickering.
    }

    private function initElements():Void
    {
        // Add background image.

        _background = new Bitmap(Assets.getBitmapData("assets/textures/1x/background.jpg"));
        _background.smoothing = true;
        addChild(_background);

        // While the assets are loaded, we will display a progress bar.

        //_progressBar = new ProgressBar(175, 20);
        //_progressBar.x = (_background.width - _progressBar.width) / 2;
        //_progressBar.y =  _background.height * 0.7;
        //addChild(_progressBar);
    }

    private function removeElements():Void
    {
        if (_background != null)
        {
            removeChild(_background);
            _background = null;
        }

        if (_progressBar != null)
        {
            removeChild(_progressBar);
            _progressBar = null;
        }
    }
    
    private function onResize(e:openfl.events.Event):Void
    {
        var viewPort:Rectangle = RectangleUtil.fit(new Rectangle(0, 0, Constants.GameWidth, Constants.GameHeight), new Rectangle(0, 0, stage.stageWidth, stage.stageHeight));
        try
        {
            this._starling.viewPort = viewPort;
        }
        catch(error:Error) {}
    }
}