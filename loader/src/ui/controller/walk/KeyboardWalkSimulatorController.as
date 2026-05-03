package ui.controller.walk {

	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	public class KeyboardWalkSimulatorController extends WalkController {

		private var _lastKeyCode:uint = 0;

		public function KeyboardWalkSimulatorController(pocket:Pocket) {
			super(pocket);
		}

		public override function update():void {
			const dirX:Number = this.pocket.overlay.gameUI.joystickKeyboardSimulator.dirX;
			const dirY:Number = this.pocket.overlay.gameUI.joystickKeyboardSimulator.dirY;

			if (dirX == 0 && dirY == 0) {
				_releaseKey();
				return;
			}

			// atan2 gives angle in radians. Divide the circle into 4 quadrants:
			// [-π/4,  π/4]  → RIGHT
			// [ π/4, 3π/4]  → DOWN
			// [-3π/4,-π/4]  → UP
			// rest          → LEFT
			const angle:Number = Math.atan2(dirY, dirX); // range: -π to π
			const PI4:Number = Math.PI / 4; // 45°

			var keyCode:uint;

			if (angle >= -PI4 && angle < PI4) {
				keyCode = Keyboard.RIGHT;
			} else if (angle >= PI4 && angle < PI4 * 3) {
				keyCode = Keyboard.DOWN;
			} else if (angle >= -PI4 * 3 && angle < -PI4) {
				keyCode = Keyboard.UP;
			} else {
				keyCode = Keyboard.LEFT;
			}

			if (keyCode != this._lastKeyCode) {
				_releaseKey();
				_pressKey(keyCode);
			}
		}

		public override function stop():void {
			_releaseKey();
		}

		private function _pressKey(keyCode:uint):void {
			this._lastKeyCode = keyCode;

			MovieClip(this.pocket.game.mcExtSWF).dispatchEvent(_makeEvent(KeyboardEvent.KEY_DOWN, keyCode));
		}

		private function _releaseKey():void {
			if (this._lastKeyCode == 0) {
				return;
			}
			
			MovieClip(this.pocket.game.mcExtSWF).dispatchEvent(_makeEvent(KeyboardEvent.KEY_UP, this._lastKeyCode));

			this._lastKeyCode = 0;
		}

		private function _makeEvent(ttype:String, keyCode:uint):KeyboardEvent {
			return new KeyboardEvent(ttype, true, false, 0, keyCode);
		}

	}
}