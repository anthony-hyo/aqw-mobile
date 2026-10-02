package game {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getTimer;

	import ui.option.Menu;
	import ui.option.Option;

	public class Core {

		POCKET::IS_DESKTOP {
			private static const TICK_DISCORD_RPC:int = 150; // ~5s at 30 FPS | 5s × 30 = 150
		}

		public function Core(pocket:Pocket) {
			this.pocket = pocket;
			this.itemPagination = new ItemPagination(this.pocket);
			this.itemFavorite = new ItemFavorite(this.pocket);

			POCKET::IS_DESKTOP {
				this.pocket.addEventListener(Event.ENTER_FRAME, this.onEnterFrame, false, 0, true);
			}
		}

		private var pocket:Pocket;

		public var itemPagination:ItemPagination;
		public var itemFavorite:ItemFavorite;

		POCKET::IS_DESKTOP {
			private var _tickDiscordRPC:int = 0;
		}

		public var currentFrame:String = "Game";

		public function setWorldFilters(filters:Array):void {
			if (this.pocket.game && this.pocket.game.world) {
				this.pocket.game.world.map.filters = filters;
				this.pocket.game.world.CHARS.filters = filters;
			}
		}

		/**
		 * Called by Game & Pocket
		 * @param frame
		 */
		public function onFrameChange(frame:String):void {
			this.currentFrame = frame;

			for each (var menu:Menu in this.pocket.overlay.menus) {
				for each (var option:Option in menu.options) {
					if (option.onFrameChange != null) {
						option.onFrameChange(frame);
					}
				}
			}

			/*if (frame == "Game" && this.pocket.game.ui.mcInterface.mcMenu) {
				// Experiment: reposition/scale the game's menu bar for testing.
				const mcMenu:* = this.pocket.game.ui.mcInterface.mcMenu;

				mcMenu.x = 625.2;
				mcMenu.y = -487.45;

				const rightEdge:Number = mcMenu.x + mcMenu.width;

				mcMenu.scaleX = mcMenu.scaleY = 1.2;

				mcMenu.x = rightEdge - mcMenu.width;
			}*/

			this.pocket.overlay.setOverlayButtonTransform();

			this.pocket.game.setChildIndex(this.pocket.overlay, this.pocket.game.numChildren - 1);
			this.pocket.game.setChildIndex(this.pocket.gameUI, this.pocket.game.numChildren - 1);
		}

		public function onEnterFrame(event:Event):void {
			POCKET::IS_DESKTOP {
				// Low priority
				if (++_tickDiscordRPC >= TICK_DISCORD_RPC) {
					_tickDiscordRPC = 0;
					this.pocket.discordRichPresence.refreshPresence();
				}
			}
		}

		public function coolDownAct(actData:Object, overrideCD:int = -1, overrideTS:Number = -1):void {
			const world:* = this.pocket.game.world;
			const actBar:* = this.pocket.game.ui.mcInterface.actBar;
			const useOverride:Boolean = overrideCD != -1;
			const showCD:Boolean = !useOverride && this.pocket.game.litePreference.data.bSkillCD;

			const icons:Array = world.getActIcons(actData);
			const iconCT:* = world.iconCT;
			const len:int = icons.length;

			var iconFlareClass:Class;

			if (!useOverride) {
				iconFlareClass = world.getClass("iconFlare") as Class;
			}

			var iconMC:MovieClip;
			var iconBitmap:Bitmap;
			var actMaskClass:Class;
			var maskMC:MovieClip;

			for (var i:int = 0; i < len; i++) {
				iconMC = icons[i];

				if (iconMC.icon2 == null) {
					const bmpData:BitmapData = new BitmapData(50, 50, true, 0);

					// Infinity style masks the icon; draw it unmasked so the cooldown copy isn't blank.
					const styleMask:DisplayObject = iconMC.mask;
					iconMC.mask = null;
					bmpData.draw(iconMC, null, iconCT);
					iconMC.mask = styleMask;

					iconBitmap = actBar.addChild(new Bitmap(bmpData));
					iconMC.icon2 = iconBitmap;

					if (useOverride) {
						iconBitmap.transform = iconMC.transform;

						iconMC.ts = overrideTS;
						iconMC.cd = overrideCD;
					} else {
						const flare:DisplayObject = actBar.addChild(new iconFlareClass());
						iconBitmap.transform = flare.transform = iconMC.transform;

						iconMC.ts = actData.ts;
						iconMC.cd = actData.cd;
					}

					iconMC.tsg = getTimer();

					if (actMaskClass == null) {
						actMaskClass = world.getClass("ActMask") as Class;
					}

					maskMC = actBar.addChild(new actMaskClass()) as MovieClip;
					maskMC.scaleX = 0.33;
					maskMC.scaleY = 0.33;

					maskMC.x = int(iconBitmap.x + iconBitmap.width * 0.5 - maskMC.width * 0.5);
					maskMC.y = int(iconBitmap.y + iconBitmap.height * 0.5 - maskMC.height * 0.5);

					for (var j:int = 0; j < 4; j++) {
						maskMC["e" + j + "oy"] = maskMC["e" + j].y;
					}

					iconBitmap.mask = maskMC;
				} else {
					iconBitmap = iconMC.icon2;
					maskMC = MovieClip(iconBitmap.mask);

					if (useOverride) {
						iconMC.ts = overrideTS;
						iconMC.cd = overrideCD;
					} else {
						iconMC.ts = actData.ts;
						iconMC.cd = actData.cd;
					}

					iconMC.tsg = getTimer();
				}

				if (showCD) {
					switch (actData.ref) {
						case "aa":
							iconMC.ref = "txtCD0";
							break;
						case "i1":
							iconMC.ref = "txtCD5";
							break;
						default:
							iconMC.ref = "txtCD" + actData.ref.slice(1);
					}

					const cdText:* = actBar.getChildByName(iconMC.ref);
					actBar.setChildIndex(cdText, actBar.numChildren - 1);
					cdText.text = String(Number(iconMC.cd * 0.001).toFixed(1));
					cdText.visible = true;
				}

				maskMC.e0.stop();
				maskMC.e1.stop();
				maskMC.e2.stop();
				maskMC.e3.stop();

				iconMC.removeEventListener(Event.ENTER_FRAME, world.countDownAct);
				iconMC.addEventListener(Event.ENTER_FRAME, world.countDownAct, false, 0, true);
			}
		}

		public function countDownAct(e:Event):void {
			const iconMC:MovieClip = MovieClip(e.target);
			const icon2:Bitmap = iconMC.icon2;

			const world:* = this.pocket.game.world;

			if (icon2 == null || icon2.mask == null) {
				iconMC.removeEventListener(Event.ENTER_FRAME, world.countDownAct);
				return;
			}

			const actBar:* = this.pocket.game.ui.mcInterface.actBar;

			const now:int = getTimer();
			var cd:Number;

			if (world.myAvatar != null && world.myAvatar.dataLeaf != null && world.myAvatar.dataLeaf.sta != null) {
				cd = Math.round(iconMC.cd * (1 - Math.min(Math.max(world.myAvatar.dataLeaf.sta.$tha, -1), 0.5)));
			} else {
				cd = iconMC.cd;
			}

			const progress:Number = (now - iconMC.tsg) / cd;
			const wedgeIndex:int = Math.floor(progress * 4);
			const wedgeFrame:int = int((progress * 360) % 90) + 1;

			if (iconMC.actObj.lock) {
				return;
			}

			if (progress < 0.99) {
				if (iconMC.ref) {
					actBar.getChildByName(iconMC.ref).text = String(Number((1 - progress) * (cd / 1000)).toFixed(1));
				}

				for (var w:int = 0; w < 4; w++) {
					if (w < wedgeIndex) {
						icon2.mask[("e" + w)].y = -300;
					} else {
						icon2.mask[("e" + w)].y = icon2.mask[("e" + w) + "oy"];

						if (w > wedgeIndex) {
							icon2.mask[("e" + w)].gotoAndStop(0);
						}
					}
				}

				MovieClip(icon2.mask[("e" + wedgeIndex)]).gotoAndStop(wedgeFrame);
			} else {
				if (iconMC.ref) {
					actBar.getChildByName(iconMC.ref).visible = false;
				}

				const oldMask:DisplayObject = icon2.mask;
				icon2.mask = null;
				oldMask.parent.removeChild(oldMask);

				iconMC.removeEventListener(Event.ENTER_FRAME, world.countDownAct);

				icon2.parent.removeChild(icon2);
				icon2.bitmapData.dispose();

				iconMC.icon2 = null;
			}
		}

	}

}