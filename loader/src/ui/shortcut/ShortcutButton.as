package ui.shortcut {

	import data.Action;

	import flash.display.SimpleButton;
	import flash.display.Sprite;
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
			this.shortcutTxt.tabEnabled = false;

			this.mouseChildren = true;
			this.mouseEnabled = false;

			this.shortcutBtn.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}

		public var shortcutBtn:SimpleButton;
		public var shortcutTxt:TextField;

		private var pocket:Pocket;
		private var actionName:String;

		private function onClick(e:MouseEvent):void {
			if (!this.pocket.game) {
				return;
			}

			for each (var action:Action in ShortcutPicker.ACTIONS) {
				if (action.name == this.actionName) {
					if (action.onClick != null) {
						action.onClick(this.pocket);
						return;
					}
					break;
				}
			}

			this.pocket.game.triggerGameAction(this.actionName);
		}

	}
}