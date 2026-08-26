package game {

	import ui.option.Menu;
	import ui.option.Option;

	public class Game {

		public function Game(pocket:Pocket) {
			this.pocket = pocket;
		}

		private var pocket:Pocket;

		public function onFrameChange(frame:String):void {
			for each (var menu:Menu in this.pocket.overlay.menus) {
				for each (var option:Option in menu.options) {
					if (option.onFrameChange != null) {
						option.onFrameChange(frame);
					}
				}
			}

			if (!this.pocket.game) {
				return;
			}

			switch (frame) {
				case "Game":
					if (this.pocket.overlay.showPanelBtn) {
						this.pocket.overlay.showPanelBtn.width = this.pocket.overlay.showPanelBtn.height = 24;
						this.pocket.overlay.showPanelBtn.x = this.pocket.overlay.showPanelBtn.y = 2;
					}
					break;
				default:
					if (this.pocket.overlay.showPanelBtn) {
						this.pocket.overlay.showPanelBtn.width = this.pocket.overlay.showPanelBtn.height = 37.3;

						this.pocket.overlay.showPanelBtn.x = 7.1;
						this.pocket.overlay.showPanelBtn.y = 264.9;
					}
					break;
			}
		}

	}

}