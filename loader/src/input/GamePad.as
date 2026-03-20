package input {

	import flash.display.*;
	import flash.events.*;

	import ui.Layout;
	import ui.SkillBar;

	public class GamePad extends Sprite {

		public function GamePad(pocket:Pocket) {
			this.pocket = pocket;
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}

		private var pocket:Pocket;

		private var padContainer:Sprite;
		private var padVisible:Boolean = true;
		private var joystick:Joystick;

		private var walkCtrl:WalkController;
		private var skillBar:SkillBar;
		private var layout:Layout;

		private function onAdded(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);

			padContainer = new Sprite();

			addChild(padContainer);

			joystick = new Joystick();
			walkCtrl = new WalkController(this.pocket, joystick);
			skillBar = new SkillBar(this.pocket.game);

			joystick.x = Joystick.DEFAULT_X;
			joystick.y = Joystick.DEFAULT_Y;

			skillBar.x = SkillBar.ORIGIN_X;
			skillBar.y = SkillBar.ORIGIN_Y;

			padContainer.addChild(joystick);
			padContainer.addChild(skillBar);

			layout = new Layout();

			layout.register("joystick", joystick, Joystick.DEFAULT_X, Joystick.DEFAULT_Y);
			layout.register("skillbar", skillBar, SkillBar.ORIGIN_X, SkillBar.ORIGIN_Y);

			layout.load();

			stage.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
		}

		public function toggleUI():void {
			padVisible = !padVisible;
			padContainer.visible = padVisible;
		}

		public function toggleEditLayout():void {
			layout.toggleEdit();
		}

		public function resetLayout():void {
			layout.resetToDefaults();
		}

		private function onDown(e:MouseEvent):void {
			if (!padVisible || layout.editMode) {
				return;
			}

			if (joystick.hitTest(e.stageX, e.stageY)) {
				joystick.move(e.stageX, e.stageY);
				stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			}
		}

		private function onMove(e:MouseEvent):void {
			if (joystick.dirX != 0 || joystick.dirY != 0) {
				joystick.move(e.stageX, e.stageY);
			}
		}

		private function onUp(e:MouseEvent):void {
			if (joystick.dirX == 0 && joystick.dirY == 0) {
				return;
			}

			joystick.snapHome();

			stage.removeEventListener(Event.ENTER_FRAME, onEnterFrame);

			walkCtrl.stop();
		}

		private function onEnterFrame(e:Event):void {
			walkCtrl.update();
		}

	}
}

