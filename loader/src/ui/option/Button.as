package ui.option {

	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class Button extends Option {

		public function Button(key:String = "", name:String = "", info:String = "", buttonLabel:String = "", onChange:Function = null) {
			super(key, name, info, onChange);

			this.buttonTxt.text = buttonLabel;
			this.buttonTxt.mouseEnabled = false;

			this.button.addEventListener(MouseEvent.CLICK, onClick);
		}

		public var button:SimpleButton;
		public var buttonTxt:TextField;

		private function onClick(e:MouseEvent):void {
			if (_onChange != null) {
				_onChange(this);
			}
		}

	}
}
