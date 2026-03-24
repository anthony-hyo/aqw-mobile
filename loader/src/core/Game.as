package core {
	import ui.option.Option;

	public class Game {

		public function Game(pocket:Pocket) {
			this.pocket = pocket;
		}

		private var pocket:Pocket;

		public var currentFrame:String = null;

		public function onFrameChange(frame:String):void {
			this.currentFrame = frame;
			
			for each (var option:Option in this.pocket.overlay.options) {
				if (option.onFrameChange != null) {
					option.onFrameChange(frame);
				}
			}
		}

	}

}