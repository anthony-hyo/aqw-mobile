package game {

	import flash.events.Event;

	import ui.option.Menu;
	import ui.option.Option;

	public class Core {

		POCKET::IS_DESKTOP {
			private static const TICK_DISCORD_RPC:int = 150; // ~5s at 30 FPS | 5s × 30 = 150
		}

		public function Core(pocket:Pocket) {
			this.pocket = pocket;
			this.itemPagination = new ItemPagination(this.pocket);

			POCKET::IS_DESKTOP {
				this.pocket.addEventListener(Event.ENTER_FRAME, this.onEnterFrame, false, 0, true);
			}
		}

		private var pocket:Pocket;

		public var itemPagination:ItemPagination;

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

	}

}