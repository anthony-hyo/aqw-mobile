package ui.shortcut {

	import data.Action;

	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;

	import ui.option.Check;
	import ui.option.Option;
	import ui.util.Scroll;

	import util.HelperScroll;
	import util.HelperSetting;

	public class ShortcutPicker extends Sprite {

		public static const ACTIONS:Vector.<Action> = new <Action>[
			new Action("Fix Lag", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				pocket.game.stopAllMovieClips();
			}),

			new Action("Hide Monsters"),
			new Action("Hide Players"),
			new Action("Hide UI"),
			
			new Action("Auto Attack", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				const icon:* = pocket.game.ui.mcInterface.actBar.getChildByName("i1");

				if (icon != null && icon.actObj != null) {
					if (icon.actObj.auto) {
						pocket.game.world.approachTarget();
					} else {
						pocket.game.world.testAction(icon.actObj);
					}
				}
			}),
			new Action("Skill 2", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.ui || !pocket.game.ui.mcInterface || !pocket.game.ui.mcInterface.actBar) {
					return;
				}

				const icon:* = pocket.game.ui.mcInterface.actBar.getChildByName("i2");

				if (icon != null && icon.actObj != null) {
					if (icon.actObj.auto) {
						pocket.game.world.approachTarget();
					} else {
						pocket.game.world.testAction(icon.actObj);
					}
				}
			}),
			new Action("Skill 3", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.ui || !pocket.game.ui.mcInterface || !pocket.game.ui.mcInterface.actBar) {
					return;
				}

				const icon:* = pocket.game.ui.mcInterface.actBar.getChildByName("i3");
				if (icon != null && icon.actObj != null) {
					if (icon.actObj.auto) {
						pocket.game.world.approachTarget();
					} else {
						pocket.game.world.testAction(icon.actObj);
					}
				}
			}),
			new Action("Skill 4", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.ui || !pocket.game.ui.mcInterface || !pocket.game.ui.mcInterface.actBar) {
					return;
				}

				const icon:* = pocket.game.ui.mcInterface.actBar.getChildByName("i4");
				if (icon != null && icon.actObj != null) {
					if (icon.actObj.auto) {
						pocket.game.world.approachTarget();
					} else {
						pocket.game.world.testAction(icon.actObj);
					}
				}
			}),
			new Action("Skill 5", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.ui || !pocket.game.ui.mcInterface || !pocket.game.ui.mcInterface.actBar) {
					return;
				}

				const icon:* = pocket.game.ui.mcInterface.actBar.getChildByName("i5");
				if (icon != null && icon.actObj != null) {
					if (icon.actObj.auto) {
						pocket.game.world.approachTarget();
					} else {
						pocket.game.world.testAction(icon.actObj);
					}
				}
			}),
			new Action("Skill 6", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.ui || !pocket.game.ui.mcInterface || !pocket.game.ui.mcInterface.actBar) {
					return;
				}

				const icon:* = pocket.game.ui.mcInterface.actBar.getChildByName("i6");
				if (icon != null && icon.actObj != null) {
					if (icon.actObj.auto) {
						pocket.game.world.approachTarget();
					} else {
						pocket.game.world.testAction(icon.actObj);
					}
				}
			}),
			
			new Action("Target Random Monster", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				const mons:Array = pocket.game.world.getMonstersByCell(pocket.game.world.strFrame);

				if (mons.length > 0) {
					var rnd:uint = uint(Math.round(Math.random() * (mons.length - 1)));

					while (mons.length > 1 && !mons[rnd] && !mons[rnd].pMC && mons[rnd].dataLeaf.intState == 0 && pocket.game.world.myAvatar.target == mons[rnd]) {
						if (pocket.game.world.strFrame != pocket.game.world.strFrame) {
							break;
						}

						rnd = uint(Math.round(Math.random() * (mons.length - 1)));
					}

					if (pocket.game.world.strFrame == pocket.game.world.strFrame && mons[rnd] && mons[rnd].pMC && mons[rnd].dataLeaf.strFrame == pocket.game.world.strFrame && mons[rnd].dataLeaf.intState != 0) {
						pocket.game.world.setTarget(mons[rnd]);
					}
				}
			}),
			new Action("Cancel Target"),

			new Action("Rest"),
			new Action("Dash", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.world) {
					return;
				}

				const pnm:String = pocket.game.world.myAvatar.pnm;

				if (!pocket.game.world.uoTree[pnm].sta.$dsh) {
					pocket.game.world.uoTree[pnm].sta.$dsh = 100;
				}

				if (pocket.game.world.myAvatar.dataLeaf.intSP >= pocket.game.world.uoTree[pnm].sta.$dsh) {
					pocket.game.pDash = true;
				}
			}),
			new Action("Jump"),
			new Action("Player HP Bar"),
			
			new Action("Focus Chat", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				pocket.game.stage.focus = null;
				pocket.game.dispatchEvent(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, false, 13, 13));
			}),
			
			new Action("Inventory"),
			new Action("Bank"),
			new Action("Outfits"),

			new Action("Quest Log"),
			
			new Action("Character Panel"),
			new Action("Stats Overview"),
			new Action("Battle Analyzer"),
			new Action("Battle Analyzer Toggle"),
			
			new Action("Friends List"),
			new Action("Friendships UI"),
			new Action("Area List"),
			
			new Action("Options"),
			
			new Action("Custom Drops UI"),
			new Action("Decline All Drops"),

			new Action("Toggle World", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.world || !pocket.game.world.map) {
					return;
				}

				pocket.game.world.map.visible = !pocket.game.world.map.visible;
			}),
			new Action("Toggle Joystick", function (pocket:Pocket):void {
				if (!pocket.game || pocket.game.currentFrameLabel != "Game") {
					return;
				}

				for each (var option:Option in pocket.overlay.options) {
					if (option.key == HelperSetting.OPTION_SHOW_JOYSTICK_MOUSE) {
						Check(option).onToggle();
						return;
					}
				}
			}),
			new Action("Toggle Skills", function (pocket:Pocket):void {
				if (!pocket.game || pocket.game.currentFrameLabel != "Game") {
					return;
				}

				for each (var option:Option in pocket.overlay.options) {
					if (option.key == HelperSetting.OPTION_SHOW_SKILL_BAR) {
						Check(option).onToggle();
						return;
					}
				}
			}),
			new Action("Toggle Skills Shortcuts", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				var btn:ShortcutButton;
				
				var is_visible: Boolean = null;

				for (var actionName:String in pocket.gameUI.shortcutButtons) {
					switch (actionName) {
						case "Auto Attack":
						case "Skill 2":
						case "Skill 3":
						case "Skill 4":
						case "Skill 5":
						case "Skill 6":
							btn = ShortcutButton(pocket.gameUI.shortcutButtons[actionName]);
							
							if (is_visible === null) {
								is_visible = btn.visible;
							}

							btn.visible = !is_visible;
							break;
					}
				}
			}),
			new Action("Toggle Shortcuts", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				var btn:ShortcutButton;

				for (var actionName:String in pocket.gameUI.shortcutButtons) {
					if (actionName == "Toggle Shortcuts") {
						continue;
					}

					btn = ShortcutButton(pocket.gameUI.shortcutButtons[actionName]);

					btn.visible = !btn.visible;
				}
			}),

			new Action("Travel Menu's Travel"),
			new Action("Camera Tool"),
			new Action("World Camera"),
			new Action("World Camera's Hide")
		];

		public function ShortcutPicker(pocket:Pocket, onPick:Function) {
			this.pocket = pocket;
			this.onPick = onPick;

			this.name = "ShortcutPicker";

			addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
		}

		public var closeBtn:SimpleButton;

		public var content:Sprite;
		public var contentMask:DisplayObject;
		public var contentScroll:Scroll;

		private var pocket:Pocket;
		private var onPick:Function;

		private function buildPanel():void {
			closeBtn.addEventListener(MouseEvent.CLICK, onDismiss);

			var i:int = 0;

			for each (var action:Action in ACTIONS) {
				const shortcutRow:ShortcutRow = new ShortcutRow();

				shortcutRow.name = action.name;

				shortcutRow.shortcutTxt.selectable = false;
				shortcutRow.shortcutTxt.mouseEnabled = false;

				shortcutRow.shortcutTxt.text = action.name;

				shortcutRow.y = i * shortcutRow.height;
				shortcutRow.buttonMode = true;
				shortcutRow.useHandCursor = true;

				shortcutRow.addEventListener(MouseEvent.CLICK, onRowClick);

				content.addChild(shortcutRow);

				i++;
			}

			new HelperScroll(
				contentScroll,
				content,
				contentMask
			);
		}

		private function onRowClick(e:MouseEvent):void {
			onPick(Sprite(e.currentTarget).name);
			//onDismiss();
		}

		private function onDismiss(e:MouseEvent = null):void {
			if (parent) {
				parent.removeChild(this);
			}
		}

		private function onAdded(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			buildPanel();
		}

	}
}