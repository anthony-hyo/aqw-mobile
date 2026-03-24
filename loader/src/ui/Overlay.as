package ui {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	import ui.option.Button;
	import ui.option.Check;
	import ui.option.Option;
	import ui.util.Scroll;

	import util.HelperScroll;
	import util.HelperSetting;

	public class Overlay extends MovieClip {

		public function Overlay(pocket:Pocket) {
			this.pocket = pocket;

			addFrameScript(
				0, initFrame,
				1, panelFrame
			);

			this.pocket.addChild(this);

			this.notifications = Sprite(addChild(new Sprite()));
			this.gameUI = GameUI(addChild(new GameUI(this.pocket)));
		}

		public var showPanelBtn:SimpleButton;
		public var hidePanelBtn:SimpleButton;

		public var content:Sprite;
		public var contentMask:DisplayObject;
		public var contentScroll:Scroll;

		public var debug:Debug = new Debug(this.pocket);
		public var gameUI:GameUI;
		public var notifications:Sprite;

		private var pocket:Pocket;

		private function initFrame():void {
			this.showPanelBtn.addEventListener(MouseEvent.CLICK, onShowPanel);

			stop();
		}

		private function panelFrame():void {
			this.hidePanelBtn.addEventListener(MouseEvent.CLICK, onHidePanel);

			const options:Vector.<Option> = new <Option> [
				new Check(
					HelperSetting.OPTION_ENABLE_DEBUG,
					"Show Debug",
					"Display debug on screen",
					function (option:Check):void {
						if (option.state) {
							addChild(debug);
							return;
						}

						if (debug.parent && contains(debug)) {
							removeChild(debug);
						}
					}
				),
				new Check(
					HelperSetting.OPTION_SHOW_JOYSTICK,
					"Show Joystick",
					"Display joystick on screen",
					function (option:Check):void {
						gameUI.toggleUI();
					}
				),
				new Check(
					HelperSetting.OPTION_EDIT_LAYOUT,
					"Edit Layout",
					"Drag to reposition UI elements",
					function (option:Check):void {
						gameUI.toggleEditLayout();
					}
				),
				new Button(
					HelperSetting.OPTION_RESET_LAYOUT,
					"Reset Layout",
					"Restore default positions",
					"RESET",
					function (option:Button):void {
						gameUI.resetLayout();
					}
				)
			];

			for each (var option:Option in options) {
				this.content.addChild(option);

				option.x = 3.75;
				option.y = (option.height + 2) * (this.content.numChildren - 1);
			}

			new HelperScroll(
				this.contentScroll,
				this.content,
				this.contentMask
			);

			stop();
		}

		private function onShowPanel(mouseEvent:MouseEvent):void {
			gotoAndStop("Panel");
		}

		private function onHidePanel(mouseEvent:MouseEvent):void {
			gotoAndStop("Init");
		}

		public function notification(message:String):void {
			const index:uint = this.notifications.numChildren;
			const notification:Notification = Notification(this.notifications.addChild(new Notification(message)));

			if (index == 0) {
				this.notifications.x = stage.stageWidth - notification.width - 10;
				this.notifications.y = 10;
			}

			notification.y = index * (notification.height + 10);
		}

	}

}