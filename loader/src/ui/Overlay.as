package ui {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAspectRatio;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;

	import ui.controller.walk.MouseWalkSimulatorController;
	import ui.option.Button;
	import ui.option.Check;
	import ui.option.Divide;
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

		public var content:Sprite;
		public var contentMask:DisplayObject;
		public var contentScroll:Scroll;

		public var debug:Debug = new Debug();
		public var notifications:Sprite;

		private var pocket:Pocket;
		private var layoutFile:FileReference;

		public var options:Vector.<Option> = new <Option> [
			new Check(
				HelperSetting.OPTION_SHOW_JOYSTICK_MOUSE,
				true,
				"Show Joystick",
				"Display joystick on screen",
				true,
				function (option:Check):void {
					const pocket:Pocket = Pocket.SINGLETON;

					/*MovieClip(pocket.game.cDropsUI).scaleX = 1.5;
					MovieClip(pocket.game.cDropsUI).scaleY = 1.5;
					MovieClip(pocket.game.cDropsUI).x -= 65;*/

					if (!pocket.game || pocket.game.currentFrameLabel != "Game") {
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

					if (!pocket.game || pocket.game.currentFrameLabel != "Game") {
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

					if (!pocket.game || pocket.game.currentFrameLabel != "Game") {
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
					MouseWalkSimulatorController.IS_DASHING_ON = HelperSetting.getBool(HelperSetting.OPTION_ANIMATION);
				}
			),
			new Divide(),
			new Button(
				null,
				"Add Shortcut",
				"Place an action button on screen",
				"Add",
				function (option:Button):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (!pocket.game || pocket.game.currentFrameLabel != "Game") {
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

					if (!pocket.game || pocket.game.currentFrameLabel != "Game") {
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
			new Divide(),
			new Check(
				HelperSetting.OPTION_SNAP_TO_GRID,
				true,
				"Snap To Grid",
				"Show an alignment grid while editing layout",
				true,
				function (option:Check):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (pocket.gameUI) {
						pocket.gameUI.layoutController.refreshGrid();
					}
				}
			),
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

					pocket.gameUI.showEditLayout();
				},
				function (frame:String):void {
					const pocket:Pocket = Pocket.SINGLETON;

					pocket.gameUI.hideEditLayout();

					pocket.worldCore.setWorldFilters([]);
				},
				function (frame:String):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (frame !== "Panel") {
						return;
					}

					pocket.worldCore.setWorldFilters([]);

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
			),
			new Button(
				null,
				"Save Layout",
				"Save buttons and shortcuts to a file",
				"Save",
				function (option:Button):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (!pocket.game || pocket.game.currentFrameLabel != "Game") {
						if (pocket.game) {
							pocket.game.MsgBox.notify("Only available in-game.");
						}
						return;
					}

					pocket.overlay.saveLayoutFile();
				}
			),
			new Button(
				null,
				"Load Layout",
				"Load buttons and shortcuts from a file",
				"Load",
				function (option:Button):void {
					const pocket:Pocket = Pocket.SINGLETON;

					if (!pocket.game || pocket.game.currentFrameLabel != "Game") {
						if (pocket.game) {
							pocket.game.MsgBox.notify("Only available in-game.");
						}
						return;
					}

					pocket.overlay.loadLayoutFile();
				}
			),
			new Divide(),
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
			new Divide(),
			/*new Check(
				HelperSetting.OPTION_ANIMATION,
				false,
				"Animations",
				"<font color='#FF0000'>Experimental</font>: May improve FPS, but can crash the game",
				function (option:Check):void {
					const pocket:Pocket = Pocket.SINGLETON;

					Pocket.IS_ANIMATION_OFF = option.state;

					if (pocket.game && pocket.game.ui) {
						const modal:MovieClip = new (pocket.game.loaderInfo.applicationDomain.getDefinition("ModalMC"))();

						pocket.game.ui.ModalStack.addChild(modal);

						modal.init({
							strBody: "<font color='#FF0000'>Experimental</font>: Animations has been " + (option.state ? "enabled" : "disabled") + ".\n\nNote: This may improve FPS, but cause crashes.",
							glow: "red,medium",
							callback: null,
							btns: "mono"
						});
					}
				},
				function (frame:String):void {
					Pocket.IS_ANIMATION_OFF = HelperSetting.getBool(HelperSetting.OPTION_ANIMATION);
				}
			),
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
				}
			),*/
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
		];

		private function initFrame():void {
			this.showPanelBtn.addEventListener(MouseEvent.CLICK, onShowPanel);

			for each (var option:Option in options) {
				if (option.onOverlayStateChange != null) {
					option.onOverlayStateChange("Init");
				}
			}

			this.pocket.overlay.setOverlayButtonTransform();

			this.pocket.gameUI.loadPersistedShortcuts();

			stop();
		}

		private function panelFrame():void {
			this.visible = false;

			this.hidePanelBtn.addEventListener(MouseEvent.CLICK, onHidePanel);

			var heightTotal:uint = 0;

			for each (var option:Option in options) {
				if (!option.visible) {
					continue;
				}
				
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

			this.reportBugBtn.addEventListener(MouseEvent.CLICK, onReportBug);
			this.updateBtn.addEventListener(MouseEvent.CLICK, onUpdate);
			this.discordBtn.addEventListener(MouseEvent.CLICK, onDiscord);

			this.visible = true;

			stop();
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

		private function saveLayoutFile():void {
			POCKET::IS_MOBILE {
				saveLayoutFileMobile();
				return;
			}

			POCKET::IS_DESKTOP {
				saveLayoutFileDesktop();
				return;
			}
		}

		private function loadLayoutFile():void {
			POCKET::IS_MOBILE {
				loadLayoutFileMobile();
				return;
			}

			POCKET::IS_DESKTOP {
				loadLayoutFileDesktop();
				return;
			}
		}

		private function saveLayoutFileMobile():void {
			var stream:FileStream;

			try {
				const directory:File = File.documentsDirectory.resolvePath("AQW Pocket");
				directory.createDirectory();

				const file:File = directory.resolvePath(HelperSetting.LAYOUT_FILE_NAME);
				stream = new FileStream();
				stream.open(file, FileMode.WRITE);
				stream.writeUTFBytes(JSON.stringify(this.pocket.gameUI.exportLayoutProfile()));
				stream.close();

				if (this.pocket.game) {
					this.pocket.game.MsgBox.notify("Layout saved to Documents/AQW Pocket.");
				}
			} catch (error:Error) {
				if (stream) {
					stream.close();
				}

				notifyLayoutFileError("Could not save layout file.");
			}
		}

		private function loadLayoutFileMobile():void {
			var stream:FileStream;

			try {
				const file:File = File.documentsDirectory.resolvePath("AQW Pocket/" + HelperSetting.LAYOUT_FILE_NAME);

				if (!file.exists) {
					notifyLayoutFileError("No saved layout file found.");
					return;
				}

				stream = new FileStream();
				stream.open(file, FileMode.READ);

				const profile:Object = JSON.parse(stream.readUTFBytes(stream.bytesAvailable));
				stream.close();

				if (!this.pocket.gameUI.importLayoutProfile(profile)) {
					notifyLayoutFileError("Invalid layout file.");
					return;
				}

				if (this.pocket.game) {
					this.pocket.game.MsgBox.notify("Layout loaded.");
				}
			} catch (error:Error) {
				if (stream) {
					stream.close();
				}

				notifyLayoutFileError("Invalid layout file.");
			}
		}

		private function saveLayoutFileDesktop():void {
			try {
				cleanupLayoutFile();

				this.layoutFile = new FileReference();
				this.layoutFile.addEventListener(Event.COMPLETE, onLayoutSaveComplete, false, 0, true);
				this.layoutFile.addEventListener(Event.CANCEL, onLayoutFileDone, false, 0, true);
				this.layoutFile.addEventListener(IOErrorEvent.IO_ERROR, onLayoutFileError, false, 0, true);
				this.layoutFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLayoutFileError, false, 0, true);
				this.layoutFile.save(JSON.stringify(this.pocket.gameUI.exportLayoutProfile()), HelperSetting.LAYOUT_FILE_NAME);
			} catch (error:Error) {
				notifyLayoutFileError("Could not save layout file.");
			}
		}

		private function loadLayoutFileDesktop():void {
			try {
				cleanupLayoutFile();

				this.layoutFile = new FileReference();
				this.layoutFile.addEventListener(Event.SELECT, onLayoutFileSelected, false, 0, true);
				this.layoutFile.addEventListener(Event.COMPLETE, onLayoutLoadComplete, false, 0, true);
				this.layoutFile.addEventListener(Event.CANCEL, onLayoutFileDone, false, 0, true);
				this.layoutFile.addEventListener(IOErrorEvent.IO_ERROR, onLayoutFileError, false, 0, true);
				this.layoutFile.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLayoutFileError, false, 0, true);
				this.layoutFile.browse([new FileFilter("AQW Pocket Layout (*.json)", "*.json")]);
			} catch (error:Error) {
				notifyLayoutFileError("Could not open layout file.");
			}
		}

		private function onLayoutFileSelected(e:Event):void {
			this.layoutFile.load();
		}

		private function onLayoutSaveComplete(e:Event):void {
			if (this.pocket.game) {
				this.pocket.game.MsgBox.notify("Layout saved.");
			}

			cleanupLayoutFile();
		}

		private function onLayoutLoadComplete(e:Event):void {
			try {
				const bytes:ByteArray = this.layoutFile.data;
				bytes.position = 0;

				const profile:Object = JSON.parse(bytes.readUTFBytes(bytes.length));

				if (!this.pocket.gameUI.importLayoutProfile(profile)) {
					notifyLayoutFileError("Invalid layout file.");
					return;
				}

				if (this.pocket.game) {
					this.pocket.game.MsgBox.notify("Layout loaded.");
				}
			} catch (error:Error) {
				notifyLayoutFileError("Invalid layout file.");
				return;
			}

			cleanupLayoutFile();
		}

		private function onLayoutFileError(e:Event):void {
			notifyLayoutFileError("Layout file failed.");
		}

		private function onLayoutFileDone(e:Event):void {
			cleanupLayoutFile();
		}

		private function notifyLayoutFileError(message:String):void {
			if (this.pocket.game) {
				this.pocket.game.MsgBox.notify(message);
			}

			cleanupLayoutFile();
		}

		private function cleanupLayoutFile():void {
			if (this.layoutFile == null) {
				return;
			}

			this.layoutFile.removeEventListener(Event.SELECT, onLayoutFileSelected);
			this.layoutFile.removeEventListener(Event.COMPLETE, onLayoutSaveComplete);
			this.layoutFile.removeEventListener(Event.COMPLETE, onLayoutLoadComplete);
			this.layoutFile.removeEventListener(Event.CANCEL, onLayoutFileDone);
			this.layoutFile.removeEventListener(IOErrorEvent.IO_ERROR, onLayoutFileError);
			this.layoutFile.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLayoutFileError);

			this.layoutFile = null;
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
