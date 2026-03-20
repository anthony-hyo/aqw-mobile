package ui {

	import flash.display.*;
	import flash.events.*;
	import flash.text.*;

	public class Notification extends Sprite {

		public function Notification(message:String) {
			this.messageTxt.htmlText = message;

			this.closeBtn.addEventListener(MouseEvent.CLICK, onClose, false, 0, true);
		}

		public var messageTxt:TextField;
		public var closeBtn:SimpleButton;

		private function onClose(e:MouseEvent):void {
			if (this.parent) {
				this.parent.removeChild(this);
			}
		}

	}
}
