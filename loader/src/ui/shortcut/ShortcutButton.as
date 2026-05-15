package ui.shortcut {

	import data.Action;

	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class ShortcutButton extends Sprite {

		public function ShortcutButton(pocket:Pocket, actionName:String) {
			this.pocket = pocket;
			this.actionName = actionName;

			this.shortcutTxt.text = actionName;

			this.shortcutTxt.wordWrap = true;
			this.shortcutTxt.selectable = false;
			this.shortcutTxt.mouseEnabled = false;

			addEventListener(MouseEvent.CLICK, onClick);
		}

		public var shortcutTxt:TextField;

		private var pocket:Pocket;
		private var actionName:String;

		private function onClick(e:MouseEvent):void {
			if (!this.pocket.game) {
				return;
			}

			for each (var action:Action in ShortcutPicker.ACTIONS) {
				if (action.name == this.actionName && action.onClick != null) {
					action.onClick(this.pocket);
					return;
				}
			}

			if (!this.pocket.game.litePreference) {
				return;
			}

			const keys:Object = this.pocket.game.litePreference.data.keys;

			if (!keys || !(this.actionName in keys)) {
				return;
			}
			
			const keyCodeValue: Object = keys[this.actionName]; //This can be null
			const keyCodeValueTemporary: Number = 999;

			keys[this.actionName] = keyCodeValueTemporary;

			const prevFocus:* = this.pocket.game.stage.focus;
			this.pocket.game.stage.focus = null;

			this.pocket.game.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, keyCodeValueTemporary, keyCodeValueTemporary));
			this.pocket.game.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_UP, true, false, keyCodeValueTemporary, keyCodeValueTemporary));

			this.pocket.game.stage.focus = prevFocus;

			keys[this.actionName] = keyCodeValue;
		}

	}
}