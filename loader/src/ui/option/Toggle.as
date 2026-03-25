package ui.option {

	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import util.HelperSetting;

	public class Toggle extends Option {

		public function Toggle(key:String, defaultValue:int, label:String, info:String, toggleLabels:Array = null, onChange:Function = null, onFrameChange:Function = null, onOverlayStateChange:Function = null) {
			super(key, label, info, onChange, onFrameChange, onOverlayStateChange);

			this.toggleLabels = toggleLabels;
			this.index = this.key != null ? HelperSetting.getInt(this.key, defaultValue) : defaultValue;

			syncState();

			this.buttonLeft.addEventListener(MouseEvent.CLICK, onLeft);
			this.buttonRight.addEventListener(MouseEvent.CLICK, onRight);
		}

		public var stateTxt:TextField;
		public var buttonLeft:SimpleButton;
		public var buttonRight:SimpleButton;

		private var toggleLabels:Array;
		private var index:int = 0;

		public function getIndex():int {
			return index;
		}

		public function setIndex(i:int):void {
			this.index = i % this.toggleLabels.length;

			syncState();
		}

		private function syncState():void {
			this.stateTxt.text = this.toggleLabels[this.index];
		}

		private function onLeft(e:MouseEvent):void {
			this.index = (this.index - 1 + this.toggleLabels.length) % this.toggleLabels.length;

			HelperSetting.setInt(this.key, this.index);

			syncState();

			if (onChange != null) {
				onChange(this);
			}
		}

		private function onRight(e:MouseEvent):void {
			this.index = (this.index + 1) % this.toggleLabels.length;

			HelperSetting.setInt(this.key, this.index);

			syncState();

			if (onChange != null) {
				onChange(this);
			}
		}

	}
}