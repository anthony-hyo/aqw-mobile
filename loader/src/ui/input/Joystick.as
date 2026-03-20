package ui.input {

	import flash.display.Sprite;
	import flash.geom.Point;

	public class Joystick extends Sprite {

		public static const RADIUS:Number = 72;
		public static const KNOB_RADIUS:Number = 28;
		public static const LIMIT:Number = RADIUS - KNOB_RADIUS * 0.4;

		public static const DEFAULT_X:Number = 73;
		public static const DEFAULT_Y:Number = 348;

		public var knob:Sprite;

		public var dirX:Number = 0;
		public var dirY:Number = 0;

		public function move(stageX:Number, stageY:Number):void {
			const local:Point = globalToLocal(new Point(stageX, stageY));

			var dx:Number = local.x;
			var dy:Number = local.y;

			const dist:Number = Math.sqrt(dx * dx + dy * dy);

			if (dist > LIMIT) {
				dx = dx / dist * LIMIT;
				dy = dy / dist * LIMIT;
			}

			knob.x = dx;
			knob.y = dy;

			dirX = dx / LIMIT;
			dirY = dy / LIMIT;
		}

		public function snapHome():void {
			knob.x = 0;
			knob.y = 0;

			dirX = 0;
			dirY = 0;
		}

		public function hitTest(stageX:Number, stageY:Number):Boolean {
			const local:Point = globalToLocal(new Point(stageX, stageY));
			return Math.sqrt(local.x * local.x + local.y * local.y) <= RADIUS + 20;
		}

	}
}
