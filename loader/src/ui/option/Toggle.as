package ui.option {

	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import util.HelperSetting;

	public class Toggle extends Option {

		public function Toggle(key:String = "", label:String = "", info:String = "", toggleLabels:Array = null, onChange:Function = null, onFrameChange:Function = null, onOverlayStateChange:Function = null) {
			super(key, label, info, onChange, onFrameChange, onOverlayStateChange);

			this.toggleLabels = toggleLabels;
			this.index = HelperSetting.getInt(key);

			syncState();

			buttonLeft.addEventListener(MouseEvent.CLICK, onLeft);
			buttonRight.addEventListener(MouseEvent.CLICK, onRight);
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
			index = i % toggleLabels.length;
			
			syncState();
		}

		private function syncState():void {
			stateTxt.text = toggleLabels[index];
		}

		private function onLeft(e:MouseEvent):void {
			index = (index - 1 + toggleLabels.length) % toggleLabels.length;
			
			HelperSetting.setInt(key, index);

			syncState();

			if (onChange != null) {
				onChange(this);
			}
		}

		private function onRight(e:MouseEvent):void {
			index = (index + 1) % toggleLabels.length;
			
			HelperSetting.setInt(key, index);

			syncState();

			if (onChange != null) {
				onChange(this);
			}
		}

	}
}