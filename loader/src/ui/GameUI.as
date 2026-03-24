package ui {
	
	import ui.input.*;
	
	import flash.display.*;
	import flash.events.*;

	import ui.input.SkillBar;
	import ui.controller.LayoutController;
	import ui.controller.WalkController;

	import util.HelperSetting;

	public class GameUI extends Sprite {

		public function GameUI(pocket:Pocket) {
			this.pocket = pocket;

			addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
		}

		private var pocket:Pocket;

		private var joystick:Joystick;
		private var skillBar:SkillBar;

		private var layoutController:LayoutController;
		private var walkController:WalkController;

		public function show():void {
			this.visible = true;
		}

		public function hide():void {
			this.visible = false;
		}

		public function toggleUI():void {
			this.visible = !this.visible;
		}

		public function toggleEditLayout():void {
			this.layoutController.toggleEdit();
		}

		public function resetLayout():void {
			this.layoutController.resetToDefaults();
		}

		private function onAdded(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);

			this.joystick = Joystick(addChild(new Joystick()));
			this.skillBar = SkillBar(addChild(new SkillBar(this.pocket)));

			this.layoutController = new LayoutController();
			this.walkController = new WalkController(this.pocket, this.joystick);

			const joystick_default_x:Number = 73;
			const joystick_default_y:Number = 348;

			this.joystick.x = joystick_default_x;
			this.joystick.y = joystick_default_y;

			const skill_bar_default_x:Number = 706;
			const skill_bar_default_y:Number = 380;

			this.skillBar.x = skill_bar_default_x;
			this.skillBar.y = skill_bar_default_y;

			this.layoutController.register(HelperSetting.LAYOUT_JOYSTICK, this.joystick, joystick_default_x, joystick_default_y);
			this.layoutController.register(HelperSetting.LAYOUT_SKILL_BAR, this.skillBar, skill_bar_default_x, skill_bar_default_y);

			this.layoutController.load();

			this.joystick.addEventListener(MouseEvent.MOUSE_DOWN, onDown, false, 0, true);
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

