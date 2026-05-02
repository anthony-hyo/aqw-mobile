package ui.input {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import ui.controller.LayoutController;
	import ui.controller.walk.WalkController;

	public class Joystick extends Sprite {

		public function Joystick(walkController:WalkController) {
			addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);

			this.walkController = walkController;
		}

		public var knob:Sprite;
		public var dirX:Number = 0;
		public var dirY:Number = 0;

		private var _limit:Number;

		private var walkController:WalkController;

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

			addEventListener(MouseEvent.MOUSE_DOWN, onDown, false, 0, true);

			this._limit = (this.width >> 1) - (this.knob.width >> 1) * 0.4;
		}

		private function onDown(e:MouseEvent):void {
			if (!this.visible || LayoutController.editMode) {
				return;
			}

			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp, false, 0, true);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);

			this.move(e.stageX, e.stageY);
		}

		private function onMove(e:MouseEvent):void {
			if (this.dirX != 0 || this.dirY != 0) {
				this.move(e.stageX, e.stageY);
			}
		}

		private function onUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

			if (this.dirX == 0 && this.dirY == 0) {
				return;
			}

			this.snapHome();

			this.walkController.stop();
		}

		private function onEnterFrame(e:Event):void {
			this.walkController.update();
		}

	}
}
