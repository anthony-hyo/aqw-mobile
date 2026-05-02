package ui.controller.walk {

	import flash.errors.IllegalOperationError;

	import ui.input.Joystick;

	public class WalkController {

		protected static const SEND_EVERY_N_FRAMES:int = 5;
		protected static const MOVE_SPEED_MULTIPLIER:Number = 8;

		public function WalkController(pocket:Pocket) {
			this.pocket = pocket;
		}

		protected var pocket:Pocket;

		protected var frameTick:int = 0;

		public function update():void {
			throw new IllegalOperationError("Must override update Function");
		}

		public function stop():void {
			throw new IllegalOperationError("Must override stop Function");
		}

	}
}

