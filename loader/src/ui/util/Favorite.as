package ui.util {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class Favorite extends MovieClip {

		private static const ALPHA_ACTIVE:Number = 1;
		private static const ALPHA_INACTIVE:Number = 0.35;

		public var fData:Object = {};

		public function Favorite() {
			this.buttonMode = true;
			this.useHandCursor = true;
			//this.mouseChildren = false;

			this.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}

		public function fOpen(fData:Object):void {
			this.fData = fData;
			refresh();
		}

		public function update(fData:Object):void {
			this.fData = fData;
			refresh();
		}

		public function fClose():void {
			this.fData = null;

			if (this.parent) {
				this.parent.removeChild(this);
			}
		}

		private function refresh():void {
			if (fData == null) {
				return;
			}

			this.alpha = fData.favorited ? ALPHA_ACTIVE : ALPHA_INACTIVE;
		}

		private function onClick(e:MouseEvent):void {
			if (fData == null || fData.onToggle == null) {
				return;
			}

			fData.favorited = fData.onToggle();

			refresh();
		}

	}

}
