package ui {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAspectRatio;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import controller.walk.MouseWalkSimulatorController;

	import ui.option.Button;
	import ui.option.Check;
	import ui.option.Menu;
	import ui.option.Option;
	import ui.option.Toggle;
	import ui.shortcut.ShortcutPicker;
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
		}

		public var showPanelBtn:SimpleButton;
		public var hidePanelBtn:SimpleButton;

		public var reportBugBtn:SimpleButton;
		public var updateBtn:SimpleButton;
		public var discordBtn:SimpleButton;

		public var contentMenu:Sprite;

		public var contentOptions:Sprite;
		public var contentMask:DisplayObject;
		public var contentScroll:Scroll;

		public var debug:Debug = new Debug();
		public var notifications:Sprite;

		private var pocket:Pocket;
		private var scrollHelper:HelperScroll;

		public var menus:Vector.<Menu> = new <Menu> [
			new Menu("General", new <Option>[
				new Toggle(
					HelperSetting.OPTION_LOCK_ORIENTATION,
					0,
					"Screen Orientation",
					"Choose how the screen rotates",
					POCKET::IS_MOBILE,
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
				new Check(
					HelperSetting.OPTION_DISCORD_RPC,
					true,
					"Discord RPC",
					"Enable Discord Rich Presence",
					POCKET::IS_DESKTOP,
					function (option:Check):void {
						//noinspection JSUnresolvedReference
						POCKET::IS_DESKTOP {
							const pocket:Pocket = Pocket.SINGLETON;

							if (option.state) {
								pocket.discordRichPresence.enable();
								return;
							}

							pocket.discordRichPresence.disable();
						}
					}
				),
				new Button(
					null,
					"Hide Pocket",
					"Hide the Pocket overlay",
					"Hide Pocket",
					function (option:Button):void {
						const pocket:Pocket = Pocket.SINGLETON;

						pocket.gameUI.parent.removeChild(pocket.gameUI);
						pocket.overlay.parent.removeChild(pocket.overlay);
					}
				),
				new Check(
					null,
					false,
					"Show Debug",
					"Display debug on screen",
					true,
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
			]),
			new Menu("Graphics", new <Option>[
				new Check(
					HelperSetting.OPTION_ANIMATION_MONSTER,
					false,
					"Disable Monster Animations",
					"Freeze monster animations to improve FPS in battle. (May slow down loading)",
					true,
					function (option:Check):void {
						Pocket.IS_GRAPHIC_ANIMATION_MONSTER_OFF = option.state;
					},
					function (frame:String):void {
						Pocket.IS_GRAPHIC_ANIMATION_MONSTER_OFF = HelperSetting.getBool(HelperSetting.OPTION_ANIMATION_MONSTER);
					}
				),
				new Check(
					HelperSetting.OPTION_ANIMATION_HELM,
					false,
					"Disable Helm Animations",
					"Freeze animations. (May slow down loading)",
					true,
					function (option:Check):void {
						Pocket.IS_GRAPHIC_ANIMATION_HELM_OFF = option.state;
					},
					function (frame:String):void {
						Pocket.IS_GRAPHIC_ANIMATION_HELM_OFF = HelperSetting.getBool(HelperSetting.OPTION_ANIMATION_HELM);
					}
				),
				new Check(
					HelperSetting.OPTION_ANIMATION_ARMOR,
					false,
					"Disable Armor Animations",
					"Freeze animations. (May slow down loading)",
					true,
					function (option:Check):void {
						Pocket.IS_GRAPHIC_ANIMATION_ARMOR_OFF = option.state;
					},
					function (frame:String):void {
						Pocket.IS_GRAPHIC_ANIMATION_ARMOR_OFF = HelperSetting.getBool(HelperSetting.OPTION_ANIMATION_ARMOR);
					}
				),
				new Check(
					HelperSetting.OPTION_ANIMATION_CAPE,
					false,
					"Disable Cape Animations",
					"Freeze animations. (May slow down loading)",
					true,
					function (option:Check):void {
						Pocket.IS_GRAPHIC_ANIMATION_CAPE_OFF = option.state;
					},
					function (frame:String):void {
						Pocket.IS_GRAPHIC_ANIMATION_CAPE_OFF = HelperSetting.getBool(HelperSetting.OPTION_ANIMATION_CAPE);
					}
				),
				new Check(
					HelperSetting.OPTION_ANIMATION_HAIR,
					false,
					"Disable Hair Animations",
					"Freeze animations. (May slow down loading)",
					true,
					function (option:Check):void {
						Pocket.IS_GRAPHIC_ANIMATION_HAIR_OFF = option.state;
					},
					function (frame:String):void {
						Pocket.IS_GRAPHIC_ANIMATION_HAIR_OFF = HelperSetting.getBool(HelperSetting.OPTION_ANIMATION_HAIR);
					}
				),
				new Check(
					HelperSetting.OPTION_ANIMATION_WEAPON,
					false,
					"Disable Weapon Animations",
					"Freeze animations. (May slow down loading)",
					true,
					function (option:Check):void {
						Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF = option.state;
					},
					function (frame:String):void {
						Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF = HelperSetting.getBool(HelperSetting.OPTION_ANIMATION_WEAPON);
					}
				),
				new Check(
					HelperSetting.OPTION_ANIMATION_MISC,
					false,
					"Disable Grounds Animations",
					"Freeze animations. (May slow down loading)",
					true,
					function (option:Check):void {
						Pocket.IS_GRAPHIC_ANIMATION_MISC_OFF = option.state;
					},
					function (frame:String):void {
						Pocket.IS_GRAPHIC_ANIMATION_MISC_OFF = HelperSetting.getBool(HelperSetting.OPTION_ANIMATION_MISC);
					}
				),
				new Check(
					HelperSetting.OPTION_ANIMATION_PET,
					false,
					"Disable Pet Animations",
					"Freeze animations. (May slow down loading)",
					true,
					function (option:Check):void {
						Pocket.IS_GRAPHIC_ANIMATION_PET_OFF = option.state;
					},
					function (frame:String):void {
						Pocket.IS_GRAPHIC_ANIMATION_PET_OFF = HelperSetting.getBool(HelperSetting.OPTION_ANIMATION_PET);
					}
				),
				new Check(
					HelperSetting.OPTION_FILTER,
					false,
					"Disable Filters",
					"Remove heavy glows and drop-shadows. (May slow down loading)",
					true,
					function (option:Check):void {
						const pocket:Pocket = Pocket.SINGLETON;

						Pocket.IS_GRAPHIC_FILTER_OFF = option.state;

						if (pocket.game) {
							pocket.game.MsgBox.notify("Filter setting saved. Join a new map/Relog to take effect.");
						}
					},
					function (frame:String):void {
						Pocket.IS_GRAPHIC_FILTER_OFF = HelperSetting.getBool(HelperSetting.OPTION_FILTER);
					}
				)
			]),
			new Menu("Controls", new <Option>[
				new Check(
					HelperSetting.OPTION_SHOW_JOYSTICK_MOUSE,
					true,
					"Show Joystick",
					"Display joystick on screen",
					true,
					function (option:Check):void {
						const pocket:Pocket = Pocket.SINGLETON;

						if (!pocket.game || pocket.gameCore.currentFrame != "Game") {
							return;
						}

						if (option.state) {
							pocket.gameUI.showJoystickMouseSimulator();
							return;
						}

						pocket.gameUI.hideJoystickMouseSimulator();
					},
					function (frame:String):void {
						const pocket:Pocket = Pocket.SINGLETON;

						if (!HelperSetting.getBool(HelperSetting.OPTION_SHOW_JOYSTICK_MOUSE)) {
							return;
						}

						if (frame != "Game") {
							pocket.gameUI.hideJoystickMouseSimulator();
							return;
						}

						pocket.gameUI.showJoystickMouseSimulator();
					}
				),
				new Check(
					HelperSetting.OPTION_SHOW_JOYSTICK_KEYBOARD,
					false,
					"Show Arrow keys",
					"Keyboard arrow key simulator",
					true,
					function (option:Check):void {
						const pocket:Pocket = Pocket.SINGLETON;

						if (!pocket.game || pocket.gameCore.currentFrame != "Game") {
							return;
						}

						if (option.state) {
							pocket.gameUI.showJoystickKeyboardSimulator();
							return;
						}

						pocket.gameUI.hideJoystickKeyboardSimulator();
					},
					function (frame:String):void {
						const pocket:Pocket = Pocket.SINGLETON;

						if (!HelperSetting.getBool(HelperSetting.OPTION_SHOW_JOYSTICK_KEYBOARD)) {
							return;
						}

						if (frame != "Game") {
							pocket.gameUI.hideJoystickKeyboardSimulator();
							return;
						}

						pocket.gameUI.showJoystickKeyboardSimulator();
					}
				),
				new Check(
					HelperSetting.OPTION_SHOW_SKILL_BAR,
					true,
					"Show Skill Bar",
					"Display skill bar on screen",
					true,
					function (option:Check):void {
						const pocket:Pocket = Pocket.SINGLETON;

						if (!pocket.game || pocket.gameCore.currentFrame != "Game") {
							return;
						}

						if (option.state) {
							pocket.gameUI.showSkillBar();
							return;
						}

						pocket.gameUI.hideSkillBar();
					},
					function (frame:String):void {
						const pocket:Pocket = Pocket.SINGLETON;

						if (!HelperSetting.getBool(HelperSetting.OPTION_SHOW_SKILL_BAR)) {
							return;
						}

						if (frame != "Game") {
							pocket.gameUI.hideSkillBar();
							return;
						}

						pocket.gameUI.showSkillBar();
					}
				),
				new Check(
					HelperSetting.OPTION_JOYSTICK_DASH,
					false,
					"Joystick Dash",
					"Enable dashing using joystick",
					true,
					function (option:Check):void {
						MouseWalkSimulatorController.IS_DASHING_ON = option.state;
					},
					function (frame:String):void {
						MouseWalkSimulatorController.IS_DASHING_ON = HelperSetting.getBool(HelperSetting.OPTION_JOYSTICK_DASH);
					}
				)
			]),
			new Menu("Shortcuts", new <Option>[
				new Button(
					null,
					"Add Shortcut",
					"Place an action button on screen",
					"Add",
					function (option:Button):void {
						const pocket:Pocket = Pocket.SINGLETON;

						if (!pocket.game || pocket.gameCore.currentFrame != "Game") {
							if (pocket.game) {
								pocket.game.MsgBox.notify("Only available in-game.");
							}
							return;
						}

						pocket.overlay.onHidePanel(null);

						const shortcutPicker:DisplayObject = pocket.game.stage.getChildByName("ShortcutPicker");

						if (shortcutPicker) {
							pocket.game.stage.removeChild(shortcutPicker);
						}

						pocket.game.stage.addChild(
							new ShortcutPicker(pocket, function (actionName:String):void {
								pocket.gameUI.addShortcutButton(actionName);
							})
						);
					}
				),
				new Button(
					null,
					"Remove Shortcut",
					"Remove a shortcut button from screen",
					"Remove",
					function (option:Button):void {
						const pocket:Pocket = Pocket.SINGLETON;

						if (!pocket.game || pocket.gameCore.currentFrame != "Game") {
							return;
						}

						pocket.overlay.onHidePanel(null);

						const shortcutPicker:DisplayObject = pocket.game.stage.getChildByName("ShortcutPicker");

						if (shortcutPicker) {
							pocket.game.stage.removeChild(shortcutPicker);
						}

						pocket.game.stage.addChild(
							new ShortcutPicker(pocket, function (actionName:String):void {
								pocket.gameUI.removeShortcutButton(actionName);
							})
						);
					}
				),
				new Button(
					null,
					"Reset Shortcuts",
					"Remove all shortcut buttons from screen",
					"Reset",
					function (option:Button):void {
						const pocket:Pocket = Pocket.SINGLETON;

						pocket.gameUI.resetShortcuts();

						if (pocket.game) {
							pocket.game.MsgBox.notify("Shortcuts cleared.");
						}
					}
				)
			]),
			new Menu("Layout", new <Option>[
				new Check(
					HelperSetting.OPTION_SNAP_TO_GRID,
					true,
					"Snap To Grid",
					"Show an alignment grid while editing layout",
					true
				),
				new Button(
					null,
					"Edit Layout",
					"Drag to reposition UI elements",
					"Edit",
					function (option:Button):void {
						const pocket:Pocket = Pocket.SINGLETON;

						if (!pocket.game || pocket.gameCore.currentFrame != "Game") {
							if (pocket.game) {
								pocket.game.MsgBox.notify("Cannot edit outside the game screen.");
							}
							return;
						}

						pocket.worldCore.setWorldFilters([
							Helper.GRAYSCALE
						]);

						pocket.overlay.onHidePanel(null);

						pocket.gameUI.showEditLayout();
					},
					function (frame:String):void {
						const pocket:Pocket = Pocket.SINGLETON;

						pocket.gameUI.hideEditLayout();
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

						pocket.gameUI.resetLayout();
					}
				)
			])
		];

		private function initFrame():void {
			this.showPanelBtn.addEventListener(MouseEvent.CLICK, onShowPanel);

			for each (var menu:Menu in menus) {
				for each (var option:Option in menu.options) {
					if (option.onOverlayStateChange != null) {
						option.onOverlayStateChange("Init");
					}
				}
			}

			this.pocket.overlay.setOverlayButtonTransform();

			this.pocket.gameUI.loadPersistedShortcuts();

			stop();
		}

		private function panelFrame():void {
			this.visible = false;

			this.contentMenu.removeChildren();

			this.hidePanelBtn.addEventListener(MouseEvent.CLICK, onHidePanel);

			var heightTotal:uint = 0;

			for each (var menu:Menu in menus) {
				this.contentMenu.addChild(menu);

				menu.y = heightTotal;

				heightTotal += menu.height + 10;

				for each (var option:Option in menu.options) {
					if (option.onOverlayStateChange != null) {
						option.onOverlayStateChange("Panel");
					}
				}
			}

			Pocket.SINGLETON.overlay.selectMenu(menus[0]);

			this.reportBugBtn.addEventListener(MouseEvent.CLICK, onReportBug);
			this.updateBtn.addEventListener(MouseEvent.CLICK, onUpdate);
			this.discordBtn.addEventListener(MouseEvent.CLICK, onDiscord);

			this.visible = true;

			stop();
		}

		public function selectMenu(menu:Menu):void {
			this.contentOptions.removeChildren();

			var heightTotal:uint = 0;

			for each (var option:Option in menu.options) {
				if (!option.visible) {
					continue;
				}

				this.contentOptions.addChild(option);

				option.x = 17;
				option.y = heightTotal + 17;

				heightTotal += option.height + 5;
			}

			if (this.scrollHelper) {
				this.scrollHelper.dispose();
			}

			this.scrollHelper = new HelperScroll(
				this.contentScroll,
				this.contentOptions,
				this.contentMask
			);
		}

		private function onShowPanel(mouseEvent:MouseEvent):void {
			gotoAndStop("Panel");
		}

		private function onHidePanel(mouseEvent:MouseEvent):void {
			gotoAndStop("Init");
		}

		private function onReportBug(e:MouseEvent):void {
			navigateToURL(new URLRequest("https://github.com/anthony-hyo/aqw-mobile/issues"), "_blank");
		}

		private function onUpdate(e:MouseEvent):void {
			navigateToURL(new URLRequest("https://github.com/anthony-hyo/aqw-mobile/releases/latest"), "_blank");
		}

		private function onDiscord(e:MouseEvent):void {
			navigateToURL(new URLRequest("https://discord.gg/EXS5qM35ff"), "_blank");
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
			
			switch (this.pocket.gameCore.currentFrame) {
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
