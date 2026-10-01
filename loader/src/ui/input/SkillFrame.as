package ui.input {

	import flash.display.Sprite;
	import flash.text.TextField;

	public class SkillFrame extends Sprite {

		public var numberTxt:TextField;

		public function setNumber(n:int):void {
			if (this.numberTxt != null) {
				this.numberTxt.text = String(n);
			}
		}

	}
}
