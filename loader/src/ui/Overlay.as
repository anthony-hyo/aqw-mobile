package ui {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import ui.input.GamePad;

	import util.HelperScroll;

	public class Overlay extends MovieClip {

		public function Overlay(pocket:Pocket) {
			this.pocket = pocket;

			addFrameScript(
				0, initFrame,
				1, panelFrame
			);

			this.pocket.addChild(this);

			addChild(notifications);

			this.gamePad = GamePad(addChild(new GamePad(this.pocket)));

			initLog();
		}

		public var showPanelBtn:SimpleButton;
		public var hidePanelBtn:SimpleButton;

		public var content:Sprite;
		public var contentMask:DisplayObject;
		public var contentScroll:Scroll;

		private var gamePad:GamePad;

		public var notifications:Sprite = new Sprite();

		private var pocket:Pocket;
		private var logField:TextField = new TextField();

		private function initFrame():void {
			this.showPanelBtn.addEventListener(MouseEvent.CLICK, onShowPanel);

			stop();
		}

		private function panelFrame():void {
			this.hidePanelBtn.addEventListener(MouseEvent.CLICK, onHidePanel);

			addOption("show_joystick", "Show Joystick", "Display joystick on screen", onShowJoystick);
			addOption("edit_layout", "Edit Layout", "Drag to reposition UI elements", onEditLayout);
			addOption("reset_layout", "Reset Layout", "Restore default positions", onResetLayout);

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

		public function log(msg:String):void {
			const timestamp:String = new Date().toTimeString().substr(0, 8);

			trace("[" + timestamp + "] " + msg);

			logField.appendText("[" + timestamp + "] " + msg + "\n");
			logField.scrollV = logField.maxScrollV;
		}

		public function logError(msg:String):void {
			logField.visible = true;

			log("ERROR: " + msg);
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

		private function onShowJoystick(state:Boolean):void {
			gamePad.toggleUI();
		}

		private function onEditLayout(state:Boolean):void {
			gamePad.toggleEditLayout();
		}

		private function onResetLayout(state:Boolean):void {
			gamePad.resetLayout();
		}

		private function addOption(key:String, label:String, info:String = "", onChange:Function = null):void {
			const option:Option = Option(this.content.addChild(new Option(key, label, info, onChange)));
			option.x = 3.75;
			option.y = (option.height + 2) * (this.content.numChildren - 1);
		}

		private function initLog():void {
			logField.width = 920;
			logField.height = 200;
			logField.x = 20;
			logField.y = 330;
			logField.multiline = true;
			logField.wordWrap = true;
			logField.selectable = true;
			logField.background = true;
			logField.backgroundColor = 0x111111;
			logField.border = true;
			logField.borderColor = 0x444444;
			logField.visible = false;

			addChild(logField);
		}

	}

}