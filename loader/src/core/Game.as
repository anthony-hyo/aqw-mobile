package core {
	import ui.option.Option;

	public class Game {

		public function Game(pocket:Pocket) {
			this.pocket = pocket;
		}

		private var pocket:Pocket;

		public function onFrameChange(frame:String):void {
			for each (var option:Option in this.pocket.overlay.options) {
				if (option.onFrameChange != null) {
					option.onFrameChange(frame);
				}
			}

			this.pocket.overlay.setOverlayButtonTransform();
		}

	}

}