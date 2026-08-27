package game {

	import flash.events.Event;

	public class World {

		private static const TICK_DISCORD_RPC:int = 150; // ~5s at 30 FPS | 5s × 30 = 150

		public function World(pocket:Pocket) {
			this.pocket = pocket;

			POCKET::IS_DESKTOP
			{
				this.pocket.addEventListener(Event.ENTER_FRAME, this.onEnterFrame, false, 0, true);
			}
		}

		private var pocket:Pocket;

		private var _tickDiscordRPC:int = 0;

		public function setWorldFilters(filters:Array):void {
			if (this.pocket.game && this.pocket.game.world) {
				this.pocket.game.world.map.filters = filters;
				this.pocket.game.world.CHARS.filters = filters;
			}
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

	}

}