package ui.option {
	
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class Menu extends Sprite {
		public function Menu(buttonLabel:String, options:Vector.<Option>) {
			this.buttonTxt.text = buttonLabel;
			this.options = options;

			this.buttonTxt.mouseEnabled = false;

			this.button.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}

		public var button:SimpleButton;
		public var buttonTxt:TextField;

		public var options:Vector.<Option> = null;

		private function onClick(e:MouseEvent):void {
			Pocket.SINGLETON.overlay.selectMenu(this)
		}

	}
}
