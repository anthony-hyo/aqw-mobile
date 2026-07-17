package game {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;

	public class World {

		private static const TICK_MAX:int = 30;
		private static const TICK_DEPTH_SORT:int = 2;
		private static const TICK_SPECIAL_DEPTH:int = 6;
		private static const TICK_COMBAT_QUEUE:int = 2;
		private static const TICK_BOOST:int = 150; // ~5s at 30 FPS | 5s × 30 = 150
		private static const TICK_DISCORD_RPC:int = 150;

		private static const arrQuality:Array = ["LOW", "MEDIUM", "HIGH"];

		public function World(pocket:Pocket) {
			this.pocket = pocket;
		}

		private var pocket:Pocket;

		private var _tickDepthSort:int = 0;
		private var _tickSpecialDepth:int = 0;
		private var _tickCombatQueue:int = 0;
		private var _tickBoost:int = 0;
		private var _tickDiscordRPC:int = 0;

		private var fpsTS:Number = 0;
		private var fpsQualityCounter:int = 0;
		private var fpsArrayQuality:Array = [];

		private var tickSum:Number = 0;
		private var tickList:Array = [];

		private var combatDisplayTime:uint;

		public function setWorldFilters(filters:Array):void {
			if (this.pocket.game && this.pocket.game.world) {
				this.pocket.game.world.map.filters = filters;
				this.pocket.game.world.CHARS.filters = filters;
			}
		}

		public function onZManagerEnterFrame(event:Event):void {
			// High priority
			calculateFPS();

			// High priority
			if (++_tickDepthSort >= TICK_DEPTH_SORT) {
				_tickDepthSort = 0;
				sortCharactersByDepth();
			}

			// Low priority
			if (++_tickSpecialDepth >= TICK_SPECIAL_DEPTH) {
				_tickSpecialDepth = 0;
				enforceSpecialMapDepth();
			}

			// Low priority
			if (++_tickBoost >= TICK_BOOST) {
				_tickBoost = 0;
				checkAndRenewBoosts();
			}

			POCKET::IS_DESKTOP {
				// Low priority
				if (++_tickDiscordRPC >= TICK_DISCORD_RPC) {
					_tickDiscordRPC = 0;
					this.pocket.discordRichPresence.refreshPresence();
				}
			}

			// High priority
			if (++_tickCombatQueue >= TICK_COMBAT_QUEUE) {
				_tickCombatQueue = 0;
				processCombatDisplayQueue();
			}
		}

		private function calculateFPS():void {
			if (fpsTS != 0) {
				const fpsTime:int = new Date().getTime() - fpsTS;

				var removed:Number = 0;

				if (tickList.length == TICK_MAX) {
					removed = tickList.shift();
				}

				tickList.push(fpsTime);
				tickSum = (tickSum + fpsTime) - removed;

				var tickFinal:Number = 1000 / (tickSum / tickList.length);

				if (this.pocket.game.ui && this.pocket.game.ui.mcFPS.visible) {
					this.pocket.game.ui.mcFPS.txtFPS.text = tickFinal.toPrecision(3);
				}

				if (++fpsQualityCounter % TICK_MAX == 0 && tickList.length == TICK_MAX && this.pocket.game.userPreference.data.quality == "AUTO") {
					fpsArrayQuality.push(tickFinal);

					if (fpsArrayQuality.length == 5) {
						var quality:Number = 0;

						for (var i:int = 0; i < fpsArrayQuality.length; i++) {
							quality += fpsArrayQuality[i];
						}

						const qualityFinal:Number = quality / fpsArrayQuality.length;
						const qualityIndex:int = arrQuality.indexOf(this.pocket.game.stage.quality);

						if (qualityFinal < 12 && qualityIndex > 0) {
							this.pocket.game.stage.quality = arrQuality[(qualityIndex - 1)];
						}

						if (qualityFinal >= 12 && qualityIndex < 2) {
							this.pocket.game.stage.quality = arrQuality[(qualityIndex + 1)];
						}

						fpsArrayQuality = [];
					}
				}
			}

			fpsTS = new Date().getTime();
		}

		private function sortCharactersByDepth():void {
			var entries:Array = [];

			var displayObject:DisplayObject;

			for (var i:int = 0; i < this.pocket.game.world.CHARS.numChildren; i++) {
				displayObject = this.pocket.game.world.CHARS.getChildAt(i);

				entries.push({
					dio: displayObject,
					oy: displayObject.y
				});

				displayObject = null;
			}

			entries.sortOn("oy", Array.NUMERIC);

			var child:MovieClip;
			var currentIndex:int;

			for (var j:int = 0; j < entries.length; j++) {
				child = entries[j].dio;
				currentIndex = this.pocket.game.world.CHARS.getChildIndex(child);

				if (currentIndex != j) {
					this.pocket.game.world.CHARS.swapChildrenAt(currentIndex, j);
				}

				child = null;
			}

			entries = null;
		}

		private function enforceSpecialMapDepth():void {
			if (this.pocket.game.world.strFrame != "Enter") {
				return;
			}

			switch (this.pocket.game.world.strMapName) {
				case "trickortreat":
					bringToFront("mcPlayerNPCTrickOrTreat");
					break;
				case "caroling":
					bringToFront("mcPlayerNPCCaroling");
					break;
			}
		}

		private function bringToFront(npcName:String):void {
			const target:DisplayObject = this.pocket.game.world.CHARS.getChildByName(npcName);

			if (target) {
				this.pocket.game.world.CHARS.setChildIndex(target, this.pocket.game.world.CHARS.numChildren - 1);
				return;
			}

			try {
				const firstMonster:Array = this.pocket.game.world.getMonsters(1)[0].pMC;

				if (firstMonster) {
					this.pocket.game.world.CHARS.setChildIndex(firstMonster, this.pocket.game.world.CHARS.numChildren - 1);
				}
			} catch (e:Error) {
			}
		}

		private function checkAndRenewBoosts():void {
			if (this.pocket.game.stage == null) {
				this.pocket.game.world.killTimers();
				this.pocket.game.world.killListeners();
				return;
			}

			if (this.pocket.game.ui == null || this.pocket.game.ui.mcPortrait == null) {
				return;
			}

			if (this.pocket.game.world.myAvatar == null || this.pocket.game.world.myAvatar.objData == null) {
				return;
			}

			const now:Number = new Date().getTime();
			const portrait:MovieClip = this.pocket.game.ui.mcPortrait;

			checkBoost(now, portrait.iconBoostXP, "iBoostXP", "xpboost");
			checkBoost(now, portrait.iconBoostG, "iBoostG", "gboost");
			checkBoost(now, portrait.iconBoostRep, "iBoostRep", "repboost");
			checkBoost(now, portrait.iconBoostCP, "iBoostCP", "cpboost");
		}

		private function checkBoost(now:Number, icon:*, boostKey:String, boostType:String):void {
			if (icon == null || this.pocket.game.world.myAvatar.objData[boostKey] == null) {
				return;
			}

			const expiresAt:Number = icon.boostTS + icon[boostKey] * 1000;

			if (expiresAt < now + 1000) {
				this.pocket.game.sfc.sendXtMessage("zm", "serverUseItem", ["-", boostType], "str", -1);
			}
		}

		private function processCombatDisplayQueue():void {
			if (!combatDisplayTime) {
				combatDisplayTime = new Date().time;
			}

			const now:uint = new Date().time;

			if (now - combatDisplayTime < 250) {
				return;
			}

			var didDisplay:Boolean = false;

			if (this.pocket.game.world.ActionResults.length > 0) {
				this.pocket.game.world.showActionImpact(this.pocket.game.world.ActionResults.shift());

				didDisplay = true;
			}

			if (this.pocket.game.world.ActionResultsAura.length > 0) {
				this.pocket.game.world.showAuraImpact(this.pocket.game.world.ActionResultsAura.shift());

				didDisplay = true;
			}

			if (this.pocket.game.world.ActionResultsMon.length > 0) {
				this.pocket.game.world.showActionImpact(this.pocket.game.world.ActionResultsMon.shift());

				didDisplay = true;
			}

			if (didDisplay) {
				combatDisplayTime = new Date().time;
			}
		}

	}

}