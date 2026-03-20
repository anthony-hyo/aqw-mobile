package core {

	public class Network {

		public function Network(pocket:Pocket) {
			this.pocket = pocket;

			//this.pocket.game.sfc.addEventListener("onExtensionResponse", onExtensionResponseHandler);
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
					switch (event.params.dataObj[0]) {
						case "sAct":
							break;
					}
					break;
			}
		}

	}

}