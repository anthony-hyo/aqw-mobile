package core {

	public class Game {

		public function Game(pocket:Pocket) {
			this.pocket = pocket;
		}

		private var pocket:Pocket;

		public function onFrameChange(frame: String) {
			switch (frame) {
				case "Game":
					break;
			}
		}

	}

}