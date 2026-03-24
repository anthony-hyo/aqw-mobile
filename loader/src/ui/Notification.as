package ui {

	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

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
