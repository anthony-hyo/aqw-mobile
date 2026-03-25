package ui {

	import flash.display.*;
	import flash.events.*;

	import ui.controller.LayoutController;
	import ui.controller.WalkController;
	import ui.input.*;

	import util.HelperSetting;

	public class GameUI extends Sprite {

		public function GameUI(pocket:Pocket) {
			this.pocket = pocket;
		}

		private var pocket:Pocket;

		private var joystick:Joystick;

		public var layoutController:LayoutController = new LayoutController();
		private var walkController:WalkController;

		public function showJoystick():void {
			if (this.joystick && contains(this.joystick)) {
				return;
			}

			this.joystick = Joystick(addChild(new Joystick()));

			this.walkController = new WalkController(this.pocket, this.joystick);

			const joystick_default_x:Number = 73;
			const joystick_default_y:Number = 348;

			this.joystick.x = joystick_default_x;
			this.joystick.y = joystick_default_y;

			this.layoutController.register(HelperSetting.LAYOUT_JOYSTICK, this.joystick, joystick_default_x, joystick_default_y, this.joystick.scaleX, this.joystick.scaleY);
			this.layoutController.load();

			this.joystick.addEventListener(MouseEvent.MOUSE_DOWN, onDown, false, 0, true);
		}

		public function hideJoystick():void {
			if (this.joystick && contains(this.joystick)) {
				removeChild(this.joystick);
			}

			this.joystick = null;
		}

		public function showSkillBar():void {
			if (this.pocket.game && this.pocket.game.currentFrameLabel != "Game") {
				return;
			}

			this.pocket.game.ui.mcInterface.actBar.visible = true;
		}

		public function hideSkillBar():void {
			if (this.pocket.game && this.pocket.game.currentFrameLabel != "Game") {
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

		private function onAdded(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);

		}

		private function onDown(e:MouseEvent):void {
			if (!this.visible || this.layoutController.editMode) {
				return;
			}

			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp, false, 0, true);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);

			this.joystick.move(e.stageX, e.stageY);
		}

		private function onMove(e:MouseEvent):void {
			if (this.joystick.dirX != 0 || this.joystick.dirY != 0) {
				this.joystick.move(e.stageX, e.stageY);
			}
		}

		private function onUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

			if (this.joystick.dirX == 0 && this.joystick.dirY == 0) {
				return;
			}

			this.joystick.snapHome();

			this.walkController.stop();
		}

		private function onEnterFrame(e:Event):void {
			this.walkController.update();
		}

	}
}

