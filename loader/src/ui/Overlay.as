package ui {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAspectRatio;
	import flash.events.MouseEvent;

	import ui.option.Button;
	import ui.option.Check;
	import ui.option.Divide;
	import ui.option.Option;
	import ui.option.Toggle;
	import ui.util.Scroll;

	import util.Helper;

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

		public var options:Vector.<Option> = new <Option> [
			new Check(
				HelperSetting.OPTION_SHOW_JOYSTICK,
				true,
				"Show Joystick",
				"Display joystick on screen",
				function (option:Check):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (!pocket.game || pocket.game.currentFrameLabel != "Game") {
						return;
					}

					if (option.state) {
						pocket.overlay.gameUI.showJoystick();
						return;
					}

					pocket.overlay.gameUI.hideJoystick();
				},
				function (frame:String):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (!HelperSetting.getBool(HelperSetting.OPTION_SHOW_JOYSTICK)) {
						return;
					}

					if (frame != "Game") {
						pocket.overlay.gameUI.hideJoystick();
						return;
					}

					pocket.overlay.gameUI.showJoystick();
				}
			),
			new Check(
				HelperSetting.OPTION_SHOW_SKILL_BAR,
				true,
				"Show Skill Bar",
				"Display skill bar on screen",
				function (option:Check):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (!pocket.game || pocket.game.currentFrameLabel != "Game") {
						return;
					}

					if (option.state) {
						pocket.overlay.gameUI.showSkillBar();
						return;
					}

					pocket.overlay.gameUI.hideSkillBar();
				},
				function (frame:String):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (!HelperSetting.getBool(HelperSetting.OPTION_SHOW_SKILL_BAR)) {
						return;
					}

					if (frame != "Game") {
						pocket.overlay.gameUI.hideSkillBar();
						return;
					}

					pocket.overlay.gameUI.showSkillBar();
				}
			),
			new Divide(),
			new Button(
				null,
				"Edit Layout",
				"Drag to reposition UI elements",
				"Edit",
				function (option:Button):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (!pocket.game || pocket.game.currentFrameLabel != "Game") {
						if (pocket.game) {
							pocket.game.MsgBox.notify("Cannot edit outside the game screen.");
						}
						return;
					}

					pocket.worldCore.setWorldFilters([
						Helper.GRAYSCALE
					]);

					pocket.overlay.onHidePanel(null);

					pocket.overlay.gameUI.showEditLayout();
				},
				function (frame:String):void {
					const pocket:Pocket = Pocket.SINGLETON;

					pocket.overlay.gameUI.hideEditLayout();

					pocket.worldCore.setWorldFilters([]);
				},
				function (frame:String):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (frame !== "Panel") {
						return;
					}

					pocket.worldCore.setWorldFilters([]);

					pocket.overlay.gameUI.hideEditLayout();
				}
			),
			new Button(
				null,
				"Reset Layout",
				"Restore default positions",
				"Reset",
				function (option:Button):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (pocket.game) {
						pocket.game.MsgBox.notify("Layout successfully restored.");
					}

					pocket.overlay.gameUI.resetLayout();
				}
			),
			new Toggle(
				HelperSetting.OPTION_LOCK_ORIENTATION,
				0,
				"Screen Orientation",
				"Choose how the screen rotates",
				["Landscape", "Portrait", "Landscape Left", "Landscape Right", "Portrait Flipped"],
				function (option:Toggle):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (option.getIndex() == 0) {
						stage.autoOrients = true;
						stage.setAspectRatio(StageAspectRatio.LANDSCAPE);
						return;
					}

					stage.autoOrients = false;
					stage.setAspectRatio(StageAspectRatio.ANY);
					stage.setOrientation(Helper.ORIENTATIONS[option.getIndex()]);
				},
				null,
				function (frame:String):void {
					const pocket:Pocket = Pocket.SINGLETON;

					const savedIndex:int = HelperSetting.getInt(HelperSetting.OPTION_LOCK_ORIENTATION);

					if (savedIndex == 0) {
						stage.autoOrients = true;
						stage.setAspectRatio(StageAspectRatio.LANDSCAPE);
					} else {
						stage.autoOrients = false;
						stage.setAspectRatio(StageAspectRatio.ANY);
						stage.setOrientation(Helper.ORIENTATIONS[savedIndex]);
					}
				}
			),
			new Divide(),
			new Check(
				HelperSetting.OPTION_RASTERIZER,
				false,
				"Rasterizer",
				"<font color='#FF0000'>Experimental</font>: May improve FPS, but can crash the game",
				function (option:Check):void {
					const pocket:Pocket = Pocket.SINGLETON;
					
					Pocket.IS_RASTERIZER_ON = option.state;

					if (pocket.game) {
						pocket.game.MsgBox.notify("Please relog to apply changes.");

						if (pocket.game.ui) {
							const modal: MovieClip = new (pocket.game.loaderInfo.applicationDomain.getDefinition('ModalMC'))();

							pocket.game.ui.ModalStack.addChild(modal);

							modal.init({
								strBody: "<font color='#FF0000'>Experimental</font>: Rasterizer has been " + (option.state ? "enabled" : "disabled") + ". You must relog for this setting to take effect.\n\nNote: Enabling the Rasterizer may improve FPS in complex scenes, but can increase memory usage and cause lag or crashes on low-end devices.",
								glow: "red,medium",
								callback: null,
								btns: "mono"
							});
						}
					}
				},
				function (frame:String):void {
					Pocket.IS_RASTERIZER_ON = HelperSetting.getBool(HelperSetting.OPTION_RASTERIZER);
				}
			),
			new Toggle(
				HelperSetting.OPTION_RASTERIZER_LEVELS,
				0,
				"Rasterizer Level",
				"<font color='#FF0000'>Experimental</font>: Increase memory usage",
				["Normal (1x)", "High (1.5x)", "Ultra (2x)", "Extreme (3x)", "Low (0.5x)", "Potato (0.1x)"],
				function (option:Toggle):void {
					const pocket:Pocket = Pocket.SINGLETON;

					Pocket.RASTERIZER_QUALITY_LEVEL = Helper.RASTERIZER_LEVELS[option.getIndex()];
				},
				null,
				function (frame:String):void {
					const pocket:Pocket = Pocket.SINGLETON;

					const savedIndex:int = HelperSetting.getInt(HelperSetting.OPTION_RASTERIZER_LEVELS);

					Pocket.RASTERIZER_QUALITY_LEVEL = Helper.RASTERIZER_LEVELS[savedIndex];

					trace(Pocket.RASTERIZER_QUALITY_LEVEL);
				}
			),
			new Check(
				null,
				false,
				"Show Debug",
				"Display debug on screen",
				function (option:Check):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (option.state) {
						if (pocket.overlay.debug.parent == null) {
							pocket.overlay.addChild(pocket.overlay.debug);
						}
						return;
					}

					if (pocket.overlay.debug.parent && contains(pocket.overlay.debug)) {
						pocket.overlay.removeChild(pocket.overlay.debug);
					}
				}
			)
		];

		private function initFrame():void {
			this.showPanelBtn.addEventListener(MouseEvent.CLICK, onShowPanel);

			for each (var option:Option in options) {
				if (option.onOverlayStateChange != null) {
					option.onOverlayStateChange("Init");
				}
			}

			this.pocket.overlay.setOverlayButtonTransform();

			stop();
		}

		private function panelFrame():void {
			this.visible = false;

			this.hidePanelBtn.addEventListener(MouseEvent.CLICK, onHidePanel);

			var heightTotal:uint = 0;

			for each (var option:Option in options) {
				this.content.addChild(option);

				option.x = 3.75;
				option.y = heightTotal + 2;

				heightTotal += option.height;

				if (option.onOverlayStateChange != null) {
					option.onOverlayStateChange("Panel");
				}
			}

			new HelperScroll(
				this.contentScroll,
				this.content,
				this.contentMask
			);

			this.visible = true;

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