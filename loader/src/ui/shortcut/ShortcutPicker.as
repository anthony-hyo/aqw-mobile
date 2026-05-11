package ui.shortcut {

	import data.Action;

	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;

	import ui.util.Scroll;

	import util.HelperScroll;

	public class ShortcutPicker extends Sprite {

		public static const ACTIONS:Vector.<Action> = new <Action>[
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

					while (mons.length > 1 && !(mons[rnd]) && !mons[rnd].pMC && mons[rnd].dataLeaf.intState == 0 && pocket.game.world.myAvatar.target == mons[rnd]) {
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
			new Action("Cancel Target", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				if (pocket.game.cancelTargetTimer.running) {
					return;
				}

				if (pocket.game.world.autoActionTimer != null && pocket.game.world.autoActionTimer.running) {
					pocket.game.world.cancelAutoAttack();
					pocket.game.world.myAvatar.pMC.mcChar.gotoAndStop("Idle");
				}

				if (pocket.game.world.myAvatar.target != null) {
					pocket.game.world.setTarget(null);
				}

				if (!pocket.game.cancelTargetTimer.hasEventListener(TimerEvent.TIMER)) {
					pocket.game.cancelTargetTimer.addEventListener(TimerEvent.TIMER, pocket.game.hasCanceledAlready, false, 0, true);
				}

				const _local_7:int = parseInt(pocket.game.world.getActionByRef(pocket.game.world.actionMap[0]).cd);

				pocket.game.cancelTargetTimer.delay = _local_7 < 2000 ? 2000 : _local_7;
				pocket.game.cancelTargetTimer.start();
			}),
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
			new Action("Jump", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				pocket.game.world.myAvatar.pMC.mcChar.gotoAndPlay("Jump");
			}),
			new Action("Rest", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				pocket.game.world.rest();
			}),
			new Action("Inventory", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.ui) {
					return;
				}

				pocket.game.ui.mcInterface.mcMenu.toggleInventory();
			}),
			new Action("Character Panel", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				pocket.game.toggleCharpanel("overview");
			}),
			new Action("Quest Log", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				pocket.game.world.toggleQuestLog();
			}),
			new Action("Bank", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				pocket.game.world.toggleBank();
			}),
			new Action("Friends List", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.ui) {
					return;
				}

				if (pocket.game.ui.mcOFrame.isOpen) {
					pocket.game.ui.mcOFrame.fClose();
				} else {
					pocket.game.world.showFriendsList();
				}
			}),
			new Action("Options", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.ui) {
					return;
				}

				if (pocket.game.ui.mcPopup.currentLabel == "Option") {
					pocket.game.ui.mcPopup.onClose();
				} else {
					pocket.game.ui.mcPopup.fOpen("Option");
				}
			}),
			new Action("Area List", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.ui) {
					return;
				}

				if (!pocket.game.ui.mcOFrame.isOpen) {
					pocket.game.world.sendWhoRequest();
				} else {
					pocket.game.ui.mcOFrame.fClose();
				}
			}),
			new Action("Stats Overview", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				pocket.game.toggleStatspanel();
			}),
			new Action("Battle Analyzer", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.optionHandler) {
					return;
				}

				pocket.game.optionHandler.cmd(pocket.game, "Battle Analyzer");
			}),
			new Action("Battle Analyzer Toggle", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.ui || !pocket.game.bAnalyzer) {
					return;
				}

				pocket.game.bAnalyzer.toggle();
			}),
			new Action("Custom Drops UI", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.ui || !pocket.game.ui.mcPortrait.iconDrops || pocket.game.ui.mcPortrait.iconDrops.visible) {
					return;
				}

				pocket.game.ui.mcPortrait.iconDrops.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
			}),
			new Action("Decline All Drops", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.optionHandler) {
					return;
				}

				pocket.game.optionHandler.cmd(pocket.game, "Decline All Drops");
			}),
			new Action("Player HP Bar", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				pocket.game.world.toggleHPBar();
			}),
			new Action("Hide Monsters", function (pocket:Pocket):void {
				if (!pocket.game) {
					return;
				}

				pocket.game.world.toggleMonsters();
			}),
			new Action("Hide Players", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.optionHandler) {
					return;
				}

				pocket.game.optionHandler.cmd(pocket.game, "Hide Players");
			}),
			new Action("Hide UI", function (pocket:Pocket):void {
				if (!pocket.game || !pocket.game.optionHandler) {
					return;
				}

				pocket.game.optionHandler.cmd(pocket.game, "Hide UI");
			}),

			new Action("Friendships UI"),
			new Action("Outfits"),
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

		public var closeBtn:SimpleButton

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