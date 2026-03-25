package ui {

	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class Debug extends Sprite {

		public var logTxt:TextField;

		public function Debug(pocket:Pocket) {
			this.pocket = pocket;

			this.x = 30;
			this.y = 330;

			this.closeBtn.addEventListener(MouseEvent.CLICK, onClose, false, 0, true);
		}

		private var pocket:Pocket;
		public var closeBtn:SimpleButton;

		private function onClose(e:MouseEvent):void {
			if (this.parent && this.parent.contains(this)) {
				this.parent.removeChild(this);
			}
		}

		public function log(msg:String):void {
			const stack:String = new Error().getStackTrace();

			if (stack) {
				const lines:Array = stack.split("\n");

				if (lines.length > 2) {
					const match:Array = lines[2].match(/at\s+([\w.:$\/]+)/);

					var callerName:String = match ? match[1] : "unknown";

					if (callerName.indexOf("::") != -1) {
						callerName = callerName.split("::")[1];
					}

					if (callerName.indexOf("/") != -1) {
						callerName = callerName.split("/")[0];
					}
				}
			}

			const timestamp:String = new Date().toTimeString().substr(0, 8);
			const entry:String = "[" + timestamp + "] [" + callerName + "] " + msg;

			trace(entry);

			this.logTxt.appendText(entry + "\n");
			this.logTxt.scrollV = this.logTxt.maxScrollV;
		}

		public function logError(msg:String):void {
			if (parent == null) {
				this.pocket.overlay.addChild(this);
			}

			log("ERROR: " + msg);
		}

	}

}