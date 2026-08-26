package ui.util {

	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class BasicButton extends Sprite {
		public function BasicButton(buttonLabel:String) {
			this.buttonTxt.text = buttonLabel;

			this.buttonTxt.mouseEnabled = false;
		}

		public var button:SimpleButton;
		public var buttonTxt:TextField;

	}
}
