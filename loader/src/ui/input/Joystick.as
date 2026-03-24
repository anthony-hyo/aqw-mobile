package ui.input {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class Joystick extends Sprite {

		public function Joystick() {
			addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
		}

		public var knob:Sprite;
		public var dirX:Number = 0;
		public var dirY:Number = 0;

		private var _limit:Number;

		public function move(stageX:Number, stageY:Number):void {
			const local:Point = globalToLocal(new Point(stageX, stageY));

			var dx:Number = local.x;
			var dy:Number = local.y;

			const dist:Number = Math.sqrt(dx * dx + dy * dy);

			if (dist > this._limit) {
				dx = dx / dist * this._limit;
				dy = dy / dist * this._limit;
			}

			this.knob.x = dx;
			this.knob.y = dy;

			this.dirX = dx / this._limit;
			this.dirY = dy / this._limit;
		}

		public function snapHome():void {
			this.knob.x = 0;
			this.knob.y = 0;

			this.dirX = 0;
			this.dirY = 0;
		}

		private function onAdded(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);

			this._limit = (this.width >> 1) - (this.knob.width >> 1) * 0.4;
		}

	}
}
