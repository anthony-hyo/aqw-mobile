package core {
	
	import flash.display.Sprite;

	import util.HelperSetting;

	public class Network {

		public function Network(pocket:Pocket) {
			this.pocket = pocket;
			this.pocket.game.sfc.addEventListener("onExtensionResponse", onExtensionResponseHandler, false, 0, true);
		}

		private var pocket:Pocket;

		private function onExtensionResponseHandler(event:*):void {
			switch (event.params.type) {
				case "str":
					switch (event.params.dataObj[0]) {
						case "whisper":
							break;
					}
					break;
				case "json":
					switch (event.params.dataObj.cmd) {
						case "sAct":
							sAct();
							break;
					}
					break;
			}
		}

		private function sAct():void {
			const actBar:Sprite = this.pocket.game.ui.mcInterface.actBar;

			var icon:Sprite;

			for (var i:int = 0; i < 6; i++) {
				icon = Sprite(actBar.getChildByName("i" + (i + 1)));

				if (icon == null) {
					continue;
				}

				this.pocket.overlay.gameUI.layoutController.register(HelperSetting.LAYOUT_SKILL_BAR + "_i" + (i + 1), icon, icon.x, icon.y, icon.scaleX, icon.scaleY);

			}

			this.pocket.overlay.gameUI.layoutController.load();
		}

	}

}