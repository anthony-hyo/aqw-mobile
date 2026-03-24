package ui.option {

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class Check extends Option {

		public function Check(key:String = "", name:String = "", info:String = "", onChange:Function = null) {
			super(key, name, info, onChange);

			syncState();

			this.checkMark.mouseEnabled = false;
			
			this.checkBackground.addEventListener(MouseEvent.CLICK, onToggle);
		}
		
		public var checkMark:Sprite;
		public var checkBackground:Sprite;

		private function syncState():void {
			this.checkMark.visible = this._state;
		}

		private function onToggle(e:MouseEvent):void {
			setState(!this._state);
			syncState();
		}

	}
}