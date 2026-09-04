package {

	import data.Release;
	import data.Version;

	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;

	import game.Core;
	import game.Network;

	import load.handlers.BackgroundLoad;
	import load.handlers.GameLoad;
	import load.handlers.UpdateLoad;
	import load.handlers.VersionLoad;

	import ui.GameUI;
	import ui.Overlay;

	import util.HelperLoader;

	//noinspection JSUnresolvedReference
	POCKET::IS_DESKTOP
	{
		import discord.DiscordRichPresence;
	}

	public class Pocket extends Sprite {

		public static var IS_GRAPHIC_ANIMATION_MONSTER_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_HELM_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_ARMOR_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_CAPE_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_HAIR_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_MISC_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_PET_OFF:Boolean = false;
		public static var IS_GRAPHIC_ANIMATION_WEAPON_OFF:Boolean = false;

		public static var IS_GRAPHIC_FILTER_OFF:Boolean = false;

		private static var _SINGLETON:Pocket;

		public static function get SINGLETON():Pocket {
			return _SINGLETON;
		}

		MovieClip.prototype.removeAllChildren = function ():void {
			var i:int = this.numChildren - 1;

			while (i >= 0) {
				this.removeChildAt(i);
				i--;
			}
		};

		public function Pocket() {
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;

			stage.color = 0x000000;

			this.versionTxt.text = "Version " + Config.APP_VERSION;

			this.overlay.debug.log("Init");

			check();

			_SINGLETON = this;
		}

		public var loadingTxt:TextField;
		public var versionTxt:TextField;
		public var loadingErrorTxt:TextField;
		public var background:MovieClip;

		public var overlay:Overlay = new Overlay(this);
		public var gameUI:GameUI = new GameUI(this);

		public var game:MovieClip;

		public const gameCore:Core = new Core(this);

		//noinspection JSUnresolvedReference
		POCKET::IS_DESKTOP
		{
			public const discordRichPresence:DiscordRichPresence = new DiscordRichPresence(this);
		}

		public var networkCore:Network;

		private const backgroundLoad:BackgroundLoad = new BackgroundLoad(this);
		private const gameLoader:GameLoad = new GameLoad(this);
		private const updateLoad:UpdateLoad = new UpdateLoad(this);
		private const versionLoad:VersionLoad = new VersionLoad(this);

		public var version:Version;
		public var release:Release;

		public const load:Function = HelperLoader.load;

		public function check():void {
			switch (HelperLoader.COUNT) {
				case 0:
					this.versionLoad.start();
					break;
				case 1:
					this.backgroundLoad.start();
					break;
				case 2:
					this.updateLoad.start();
					break;
				case 3:
					this.gameLoader.start();
					break;
				case 4:
					break;
			}
		}

		public function advance():void {
			HelperLoader.COUNT++;
			check();
		}

	}
}
