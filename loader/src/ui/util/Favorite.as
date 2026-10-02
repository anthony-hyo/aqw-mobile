package ui.util {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;

	public class Favorite extends MovieClip {

		public var btnFavorite:SimpleButton;

		public var fData:Object = {};

		private var normalState:DisplayObject;
		private var hoverState:DisplayObject;

		public function Favorite() {
			this.normalState = this.btnFavorite.upState;
			this.hoverState = this.btnFavorite.overState;

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

			this.btnFavorite.upState = fData.favorited ? this.hoverState : this.normalState;
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