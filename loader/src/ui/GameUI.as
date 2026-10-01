package ui {

	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Rectangle;

	import controller.LayoutController;
	import controller.walk.KeyboardWalkSimulatorController;
	import controller.walk.MouseWalkSimulatorController;
	import game.SkillInfinity;
	import ui.input.Joystick;
	import ui.input.SkillFrame;
	import ui.input.SkillMask;
	import ui.shortcut.ShortcutButton;

	import util.Helper;
	import util.HelperSetting;

	public class GameUI extends Sprite {

		public function GameUI(pocket:Pocket) {
			this.pocket = pocket;

			this.pocket.addChild(this);

			this.mouseChildren = true;
			this.mouseEnabled = false;
		}

		private var pocket:Pocket;

		public var joystickMouseSimulator:Joystick = null;
		public var joystickKeyboardSimulator:Joystick = null;

		public var layoutController:LayoutController = new LayoutController();

		public var shortcutButtons:Object = {};

		public var skillsInfinity:Vector.<SkillInfinity> = new <SkillInfinity>[];

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

			if (this.pocket.gameCore.currentFrame != "Game") {
				return;
			}

			this.pocket.game.ui.mcInterface.actBar.visible = true;
		}

		public function hideSkillBar():void {
			if (!this.pocket.game) {
				return;
			}

			if (this.pocket.gameCore.currentFrame != "Game") {
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

		public function hideEditLayout(event:Event = null):void {
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

		public function applySkillBarStyle():void {
			if (!this.pocket.game) {
				return;
			}

			const style:int = HelperSetting.getInt(HelperSetting.OPTION_SKILL_BAR_STYLE, HelperSetting.SKILL_BAR_STYLE_CLASSIC);
			const actBar:Sprite = this.pocket.game.ui.mcInterface.actBar;

			var icon:Sprite;

			for (var i:int = 1; i <= 6; i++) {
				icon = Sprite(actBar.getChildByName("i" + i));

				if (style == HelperSetting.SKILL_BAR_STYLE_INFINITY && icon != null) {
					addSkillDecor(actBar, icon, i);
				} else {
					removeSkillDecor(actBar, i);
				}
			}
		}

		private function findSkill(id:int):SkillInfinity {
			for each (var skill:SkillInfinity in this.skillsInfinity) {
				if (skill.id == id) {
					return skill;
				}
			}

			return null;
		}

		private function addSkillDecor(actBar:Sprite, icon:Sprite, id:int):void {
			var skill:SkillInfinity = findSkill(id);

			if (skill == null) {
				const frame:SkillFrame = new SkillFrame();
				const skillMask:SkillMask = new SkillMask();

				skillMask.visible = false;

				actBar.addChild(frame);
				actBar.addChild(skillMask);

				frame.setNumber(id);

				skill = new SkillInfinity(id, frame, skillMask);

				this.skillsInfinity.push(skill);
			}

			icon.mask = skill.mask;

			const bounds:Rectangle = icon.getBounds(actBar);
			const cx:Number = bounds.x + (bounds.width >> 1);
			const cy:Number = bounds.y + (bounds.height >> 1);
			const size:Number = Math.max(bounds.width, bounds.height);

			fitToCenter(skill.mask, cx, cy, size);
			fitToCenter(skill.frame, cx, cy, size);
		}

		private function fitToCenter(target:DisplayObject, cx:Number, cy:Number, size:Number):void {
			target.scaleX = 1;
			target.scaleY = 1;

			const localBounds:Rectangle = target.getBounds(target);
			const nativeSize:Number = Math.max(localBounds.width, localBounds.height);
			const scale:Number = nativeSize > 0 ? size / nativeSize : 1;

			target.scaleX = scale;
			target.scaleY = scale;

			const centerLocalX:Number = localBounds.x + (localBounds.width >> 1);
			const centerLocalY:Number = localBounds.y + (localBounds.height >> 1);

			target.x = cx - centerLocalX * scale;
			target.y = cy - centerLocalY * scale;
		}

		private function removeSkillDecor(actBar:Sprite, id:int):void {
			const skill:SkillInfinity = findSkill(id);

			if (skill == null) {
				return;
			}

			if (skill.frame.parent) {
				actBar.removeChild(skill.frame);
			}

			const icon:Sprite = Sprite(actBar.getChildByName("i" + id));

			if (icon != null && icon.mask == skill.mask) {
				icon.mask = null;
			}

			if (skill.mask.parent) {
				actBar.removeChild(skill.mask);
			}

			this.skillsInfinity.removeAt(this.skillsInfinity.indexOf(skill));
		}

	}
}