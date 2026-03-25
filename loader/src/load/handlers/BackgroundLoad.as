package load.handlers {

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;

	import load.Load;

	import util.HelperLoader;

	public class BackgroundLoad extends Load {

		public function BackgroundLoad(pocket:Pocket) {
			super(pocket);
		}

		override public function start():void {
			this.pocket.overlay.debug.log("Loading background: " + this.pocket.version.sBG);

			this.pocket.loadingTxt.text = "Loading Background...";

			this.url = Config.GAME_BASE_URL + "gamefiles/title/" + this.pocket.version.sBG;

			super.start();
		}

		override protected function onCompleted(event:Event):void {
			try {
				const TitleScreenClass:Class = this.domain.getDefinition("TitleScreen") as Class;
				const titleScreen:DisplayObject = new TitleScreenClass();

				titleScreen.x = 0;
				titleScreen.y = 0;

				this.pocket.background.removeAllChildren();

				this.pocket.background.addChild(titleScreen);
			} catch (error:Error) {
				this.pocket.overlay.debug.logError("Failed to instantiate background: " + error.message);
			}

			this.pocket.advance();
		}

		override protected function onProgress(progressEvent:ProgressEvent):void {
			this.pocket.loadingTxt.text = "Loading Background " + HelperLoader.progressPercent(progressEvent) + "%";
		}

		override protected function onError(error:IOErrorEvent):void {
			this.pocket.overlay.debug.logError("Background load failed: " + error.text);

			this.pocket.advance();
		}

	}
}