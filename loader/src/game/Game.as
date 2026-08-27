package game {

	import ui.option.Menu;
	import ui.option.Option;

	public class Game {

		public function Game(pocket:Pocket) {
			this.pocket = pocket;
		}

		public var currentFrame:String = "Game";

		private var pocket:Pocket;

		public function onFrameChange(frame:String):void {
			this.currentFrame = frame;

			for each (var menu:Menu in this.pocket.overlay.menus) {
				for each (var option:Option in menu.options) {
					if (option.onFrameChange != null) {
						option.onFrameChange(frame);
					}
				}
			}

			this.pocket.overlay.setOverlayButtonTransform();
		}

	}

}