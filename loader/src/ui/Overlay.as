package ui {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAspectRatio;
	import flash.display.StageOrientation;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;

	import ui.option.Button;
	import ui.option.Check;
	import ui.option.Option;
	import ui.option.Toggle;
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

		public var options:Vector.<Option>;

		private static const GRAYSCALE:ColorMatrixFilter = new ColorMatrixFilter([
			0.3, 0.59, 0.11, 0, 0,
			0.3, 0.59, 0.11, 0, 0,
			0.3, 0.59, 0.11, 0, 0,
			0,   0,    0,    1, 0
		]);

		private function initFrame():void {
			this.showPanelBtn.addEventListener(MouseEvent.CLICK, onShowPanel);

			this.options = new <Option> [
				new Check(
					HelperSetting.OPTION_SHOW_JOYSTICK,
					true,
					"Show Joystick",
					"Display joystick on screen",
					function (option:Check):void {
						if (pocket.game && pocket.game.currentFrameLabel != "Game") {
							//pocket.game.MsgBox.notify("...");
							return;
						}

						if (option.state) {
							gameUI.showJoystick();
							return;
						}

						gameUI.hideJoystick();
					},
					function (frame:String):void {
						if (!HelperSetting.getBool(HelperSetting.OPTION_SHOW_JOYSTICK)) {
							return;
						}

						if (frame != "Game") {
							gameUI.hideJoystick();
							return;
						}

						gameUI.showJoystick();
					}
				),
				new Check(
					HelperSetting.OPTION_SHOW_SKILL_BAR,
					true,
					"Show Skill Bar",
					"Display skill bar on screen",
					function (option:Check):void {
						if (pocket.game && pocket.game.currentFrameLabel != "Game") {
							//pocket.game.MsgBox.notify("...");
							return;
						}

						if (option.state) {
							gameUI.showSkillBar();
							return;
						}

						gameUI.hideSkillBar();
					},
					function (frame:String):void {
						if (!HelperSetting.getBool(HelperSetting.OPTION_SHOW_SKILL_BAR)) {
							return;
						}

						if (frame != "Game") {
							gameUI.hideSkillBar();
							return;
						}

						gameUI.showSkillBar();
					}
				),
				new Button(
					null,
					"Edit Layout",
					"Drag to reposition UI elements",
					"Edit",
					function (option:Button):void {
						if (pocket.game && pocket.game.currentFrameLabel != "Game") {
							pocket.game.MsgBox.notify("Cannot edit outside the game screen.");
							return;
						}

						setWorldFilters([
							GRAYSCALE
						]);

						onHidePanel(null);

						gameUI.showEditLayout();
					},
					function (frame:String):void {
						gameUI.hideEditLayout();
						
						setWorldFilters([]);
					},
					function (frame:String):void {
						if (frame !== "Panel") {
							return;
						}

						setWorldFilters([]);
						
						gameUI.hideEditLayout();
					}
				),
				new Button(
					null,
					"Reset Layout",
					"Restore default positions",
					"Reset",
					function (option:Button):void {
						pocket.game.MsgBox.notify("Layout successfully restored.");
						gameUI.resetLayout();
					}
				),
				new Toggle(
					HelperSetting.OPTION_LOCK_ORIENTATION,
					0,
					"Screen Orientation",
					"Choose how the screen rotates",
					["Auto", "Portrait", "Left", "Right", "Flipped"],
					function (option:Toggle):void {
						const orientations:Array = [
							StageOrientation.DEFAULT,
							StageOrientation.DEFAULT,
							StageOrientation.ROTATED_LEFT,
							StageOrientation.ROTATED_RIGHT,
							StageOrientation.UPSIDE_DOWN
						];

						if (option.getIndex() == 0) {
							stage.autoOrients = true;
							stage.setAspectRatio(StageAspectRatio.LANDSCAPE); 
							return;
						}
						
						stage.autoOrients = false;
						stage.setAspectRatio(StageAspectRatio.ANY);
						stage.setOrientation(orientations[option.getIndex()]);
					},
					null,
					function (frame:String):void {
						const orientations:Array = [
							StageOrientation.DEFAULT,
							StageOrientation.DEFAULT,
							StageOrientation.ROTATED_LEFT,
							StageOrientation.ROTATED_RIGHT,
							StageOrientation.UPSIDE_DOWN
						];

						const savedIndex:int = HelperSetting.getInt(HelperSetting.OPTION_LOCK_ORIENTATION);

						if (savedIndex == 0) {
							stage.autoOrients = true;
							stage.setAspectRatio(StageAspectRatio.LANDSCAPE);
						} else {
							stage.autoOrients = false;
							stage.setAspectRatio(StageAspectRatio.ANY);
							stage.setOrientation(orientations[savedIndex]);
						}
					}
				),
				new Check(
					null,
					false,
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
				)
			];

			for each (var option:Option in options) {
				if (option.onOverlayStateChange != null) {
					option.onOverlayStateChange('Init');
				}
			}

			this.pocket.overlay.setOverlayButtonTransform();

			stop();
		}

		private function panelFrame():void {
			this.hidePanelBtn.addEventListener(MouseEvent.CLICK, onHidePanel);

			for each (var option:Option in options) {
				this.content.addChild(option);

				option.x = 3.75;
				option.y = (option.height + 2) * (this.content.numChildren - 1);
				
				if (option.onOverlayStateChange != null) {
					option.onOverlayStateChange('Panel');
				}
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

		private function setWorldFilters(filters:Array):void {
			if (this.pocket.game.world) {
				this.pocket.game.world.map.filters = filters;
				this.pocket.game.world.CHARS.filters = filters;
			}
		}

		public function setOverlayButtonTransform():void {
			if (!this.pocket.game) {
				return;
			}
			
			switch (this.pocket.game.currentFrameLabel) {
				case "Game":
					if (this.pocket.overlay.showPanelBtn) {
						this.pocket.overlay.showPanelBtn.width = this.pocket.overlay.showPanelBtn.height = 24;
						this.pocket.overlay.showPanelBtn.x = this.pocket.overlay.showPanelBtn.y = 2;
					}
					break;
				default:
					if (this.pocket.overlay.showPanelBtn) {
						this.pocket.overlay.showPanelBtn.width = this.pocket.overlay.showPanelBtn.height = 37.3;

						this.pocket.overlay.showPanelBtn.x = 7.1;
						this.pocket.overlay.showPanelBtn.y = 264.9;
					}
					break;
			}
		}

	}

}