package ui.option {

	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class Toggle extends Option {

		public function Toggle(key:String = "", label:String = "", info:String = "", onChange:Function = null) {
			super(key, label, info, onChange);

			syncState();

			buttonLeft.addEventListener(MouseEvent.CLICK, onToggle);
			buttonRight.addEventListener(MouseEvent.CLICK, onToggle);
		}
		public var stateTxt:TextField;
		public var buttonLeft:SimpleButton;
		public var buttonRight:SimpleButton;

		private function syncState():void {
			stateTxt.text = _state ? "ON" : "OFF";
		}

		private function onToggle(e:MouseEvent):void {
			setState(!_state);
			syncState();
		}

	}
}