package ui {

	import flash.display.*;

	import ui.controller.LayoutController;
	import ui.controller.walk.KeyboardWalkSimulatorController;
	import ui.controller.walk.MouseWalkSimulatorController;
	import ui.input.Joystick;

	import util.HelperSetting;

	public class GameUI extends Sprite {

		public function GameUI(pocket:Pocket) {
			this.pocket = pocket;
		}

		private var pocket:Pocket;

		public var joystickMouseSimulator:Joystick;
		public var joystickKeyboardSimulator:Joystick;

		public var layoutController:LayoutController = new LayoutController();

		private function showJoystick(layout:String, joystickName:String, walkControllerClass:Class, xPosition:int, yPosition:int):void {
			var joystick:Joystick = Joystick(this.getChildByName(joystickName));

			if (joystick != null) {
				return;
			}

			joystick = new Joystick(new walkControllerClass(this.pocket));

			joystick.name = joystickName;

			const joystick_default_x:Number = xPosition;
			const joystick_default_y:Number = yPosition;

			joystick.x = joystick_default_x;
			joystick.y = joystick_default_y;

			this.layoutController.register(layout, joystick, joystick_default_x, joystick_default_y, joystick.scaleX, joystick.scaleY);
			this.layoutController.load();

			this[joystickName] = Joystick(addChild(joystick));
		}

		private function hideJoystick(layout:String, joystickName:String):void {
			var joystick:Joystick = Joystick(this.getChildByName(joystickName));

			if (joystick == null) {
				this[joystickName] = null;
				return;
			}

			removeChild(joystick);

			this.layoutController.unregister(layout);
			this.layoutController.load();

			joystick = null;
			this[joystickName] = null;
		}

		public function showJoystickMouseSimulator():void {
			this.showJoystick(HelperSetting.LAYOUT_JOYSTICK_MOUSE, "joystickMouseSimulator", MouseWalkSimulatorController, 73, 348);
		}

		public function hideJoystickMouseSimulator():void {
			this.hideJoystick(HelperSetting.LAYOUT_JOYSTICK_MOUSE, "joystickMouseSimulator");
		}

		public function showJoystickKeyboardSimulator():void {
			this.showJoystick(HelperSetting.LAYOUT_JOYSTICK_KEYBOARD, "joystickKeyboardSimulator", KeyboardWalkSimulatorController, 73 + 100, 348);
		}

		public function hideJoystickKeyboardSimulator():void {
			this.hideJoystick(HelperSetting.LAYOUT_JOYSTICK_KEYBOARD, "joystickKeyboardSimulator");
		}

		public function showSkillBar():void {
			if (!this.pocket.game) {
				return;
			}

			if (this.pocket.game.currentFrameLabel != "Game") {
				return;
			}

			this.pocket.game.ui.mcInterface.actBar.visible = true;
		}

		public function hideSkillBar():void {
			if (!this.pocket.game) {
				return;
			}

			if (this.pocket.game.currentFrameLabel != "Game") {
				return;
			}

			this.pocket.game.ui.mcInterface.actBar.visible = false;
		}

		public function showEditLayout():void {
			this.layoutController.toggleEdit(true);
		}

		public function hideEditLayout():void {
			this.layoutController.toggleEdit(false);
		}

		public function resetLayout():void {
			this.layoutController.resetToDefaults();
		}

	}
}

