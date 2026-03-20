package {

	import core.Game;
	import core.Network;
	import core.World;

	import data.Release;
	import data.Version;

	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;

	import load.handlers.BackgroundLoad;
	import load.handlers.GameLoad;
	import load.handlers.UpdateLoad;
	import load.handlers.VersionLoad;

	import ui.Overlay;

	import util.HelperLoader;

	public class Pocket extends Sprite {

		MovieClip.prototype.removeAllChildren = function ():void {
			var i:int = this.numChildren - 1;

			while (i >= 0) {
				this.removeChildAt(i);
				i--;
			}
		};

		public function Pocket() {
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;

			this.versionTxt.text = "Version " + Config.APP_VERSION;

			overlay.log("Init");

			check();
		}

		public var loadingTxt:TextField;
		public var versionTxt:TextField;

		public var overlay:Overlay = new Overlay(this);

		public var game:MovieClip;

		public const gameCore:Game = new Game(this);
		public const networkCore:Network = new Network(this);
		public const worldCore:World = new World(this);

		private const backgroundLoad:BackgroundLoad = new BackgroundLoad(this);
		private const gameLoader:GameLoad = new GameLoad(this);
		private const updateLoad:UpdateLoad = new UpdateLoad(this);
		private const versionLoad:VersionLoad = new VersionLoad(this);

		public var version:Version;
		public var release:Release;

		public const queueLoadViaBytes:Function = HelperLoader.load;

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
