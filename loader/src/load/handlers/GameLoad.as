package load.handlers {

	import core.Network;

	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;

	import load.Load;

	import util.HelperLoader;

	public class GameLoad extends Load {

		public function GameLoad(pocket:Pocket) {
			super(pocket);
		}

		override public function start():void {
			this.pocket.overlay.debug.log("Loading game");

			this.pocket.loadingTxt.text = "Loading Game...";

			this.url = "app:/gamefiles/game.swf";

			super.start();
		}

		override protected function onCompleted(event:Event):void {
			this.pocket.overlay.debug.log("Game client loaded");

			this.pocket.removeChild(this.pocket.overlay);

			this.pocket.game = MovieClip(this.pocket.stage.addChild(MovieClip(Loader(event.target.loader).content)));

			this.pocket.game.addChild(this.pocket.overlay);

			this.pocket.game.params.sTitle = this.pocket.version.sTitle;
			this.pocket.game.params.isWeb = false;
			this.pocket.game.params.sURL = Config.GAME_BASE_URL;
			this.pocket.game.params.sBG = this.pocket.version.sBG;
			this.pocket.game.params.isEU = false;
			this.pocket.game.params.doSignup = false;
			this.pocket.game.params.loginURL = Config.API_LOGIN_URL;
			this.pocket.game.params.test = false;

			this.pocket.stage.setChildIndex(this.pocket.game, 0);

			this.pocket.stage.removeChild(this.pocket);

			this.pocket.game.pocket = this.pocket;
			this.pocket.networkCore = new Network(this.pocket);

			this.pocket.advance();
		}

		override protected function onProgress(progressEvent:ProgressEvent):void {
			this.pocket.loadingTxt.text = "Loading Game " + HelperLoader.progressPercent(progressEvent) + "%";
		}

		override protected function onError(error:IOErrorEvent):void {
			this.pocket.overlay.debug.logError("Game load failed: " + error.text);

			//this.pocket.advance();
		}

	}
}