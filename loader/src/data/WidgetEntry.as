package data {

	import flash.display.Sprite;

	import ui.util.Handle;

	public class WidgetEntry {

		public function WidgetEntry(id:String, target:Sprite, defaultPositionX:Number, defaultPositionY:Number, defaultScaleX:Number, defaultScaleY:Number) {
			this.id = id;

			this.target = target;

			this.defaultPositionX = defaultPositionX;
			this.defaultPositionY = defaultPositionY;

			this.defaultScaleX = defaultScaleX;
			this.defaultScaleY = defaultScaleY;
		}

		public var id:String;

		public var target:Sprite;

		public var defaultPositionX:Number;
		public var defaultPositionY:Number;

		public var defaultScaleX:Number;
		public var defaultScaleY:Number;

		public var handle:Handle;

	}

}