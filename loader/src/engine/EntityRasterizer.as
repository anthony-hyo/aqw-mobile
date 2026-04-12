package engine {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;

	public class EntityRasterizer extends Rasterizer {

		public function EntityRasterizer(entity:*) {
			if (!Pocket.IS_RASTERIZER_ON) {
				return
			}

			const source:MovieClip = entity.mcChar;

			_partsToMonitor = new <DisplayObject>[
				source
			];

			entity.addChild(this);

			this.addEventListener(Event.ENTER_FRAME, onTick, false, 0, true);
		}

	}

}