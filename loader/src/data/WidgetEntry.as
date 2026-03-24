package data {
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	public class WidgetEntry {

		public function WidgetEntry(id:String, target:DisplayObject, dx:Number, dy:Number) {
			this.id = id;
			this.target = target;
			this.defaultX = dx;
			this.defaultY = dy;
		}

		public var id:String;
		public var target:DisplayObject;
		public var defaultX:Number;
		public var defaultY:Number;
		public var handle:Sprite;

	}

}