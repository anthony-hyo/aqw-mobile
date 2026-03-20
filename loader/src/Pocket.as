package {

	import core.World;

	import data.Release;
	import data.Version;

	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	import flash.utils.ByteArray;

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

		public function check():void {
		}

		public function advance():void {
		}

	}
}
