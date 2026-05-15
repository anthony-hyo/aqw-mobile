package ui {

	import flash.display.*;

	import ui.controller.LayoutController;
	import ui.controller.walk.KeyboardWalkSimulatorController;
	import ui.controller.walk.MouseWalkSimulatorController;
	import ui.input.Joystick;
	import ui.shortcut.ShortcutButton;

	import util.Helper;
	import util.HelperSetting;

	public class GameUI extends Sprite {

		public function GameUI(pocket:Pocket) {
			this.pocket = pocket;

			this.pocket.addChild(this);
		}

		private var pocket:Pocket;

		public var joystickMouseSimulator:Joystick = null;
		public var joystickKeyboardSimulator:Joystick = null;

		public var layoutController:LayoutController = new LayoutController();

		public var shortcutButtons:Object = {};

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

		public function addShortcutButton(actionName:String):void {
			if (shortcutButtons[actionName] != null) {
				return;
			}

			const layoutKey:String = "shortcut_" + Helper.sanitize(actionName);
			const index:int = countShortcuts();

			const COLS:int = 4;
			const CELL:int = 66;
			const ORIGIN_X:Number = 480;
			const ORIGIN_Y:Number = 245;

			const col:int = index % COLS;
			const row:int = Math.floor(index / COLS);

			const defaultX:Number = ORIGIN_X + col * CELL;
			const defaultY:Number = ORIGIN_Y + row * CELL;

			const btn:ShortcutButton = new ShortcutButton(this.pocket, actionName);
			btn.name = layoutKey;
			btn.x = defaultX;
			btn.y = defaultY;

			this.layoutController.register(layoutKey, btn, defaultX, defaultY, btn.scaleX, btn.scaleY);
			this.layoutController.load();

			shortcutButtons[actionName] = ShortcutButton(addChild(btn));

			persistShortcuts();
		}

		public function removeShortcutButton(actionName:String):void {
			const btn:ShortcutButton = ShortcutButton(shortcutButtons[actionName]);

			if (btn == null) {
				return;
			}

			const layoutKey:String = "shortcut_" + Helper.sanitize(actionName);

			if (btn.parent) {
				removeChild(btn);
			}

			this.layoutController.unregister(layoutKey);
			this.layoutController.load();

			delete shortcutButtons[actionName];

			persistShortcuts();
		}

		public function loadPersistedShortcuts():void {
			const saved:String = HelperSetting.getString(HelperSetting.OPTION_SHORTCUTS);

			if (!saved || saved.length == 0) {
				return;
			}

			var action:String;

			for each (action in saved.split(",")) {
				if (action.length > 0) {
					addShortcutButton(action);
				}
			}
		}

		private function persistShortcuts():void {
			const keys:Array = [];

			var k:String;

			for (k in shortcutButtons) {
				keys.push(k);
			}

			HelperSetting.setString(HelperSetting.OPTION_SHORTCUTS, keys.join(","));
		}

		private function countShortcuts():int {
			var n:int = 0;

			var k:String;

			for (k in shortcutButtons) {
				n++;
			}

			return n;
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

		public function resetShortcuts():void {
			var btn:ShortcutButton;

			for (var actionName:String in shortcutButtons) {
				btn = ShortcutButton(shortcutButtons[actionName]);

				if (btn && btn.parent) {
					removeChild(btn);
				}

				this.layoutController.unregister("shortcut_" + Helper.sanitize(actionName));
			}

			this.layoutController.load();

			this.shortcutButtons = {};

			persistShortcuts();
		}

	}
}

