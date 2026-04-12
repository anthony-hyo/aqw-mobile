package core {
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	import ui.option.Option;

	import util.HelperLoader;

	public class Game {

		public function Game(pocket:Pocket) {
			this.pocket = pocket;
		}

		private var pocket:Pocket;

		public function onTravelMapComplete(e:Event):void {
			const jso:Object = JSON.parse(String(e.target.data));

			this.pocket.game.travelMapData = jso;

			pocket.game.WorldMapData = new (this.pocket.game.loaderInfo.applicationDomain.getDefinition('worldMap'))(pocket.game.travelMapData);
			pocket.game.TRAVEL_DATA_READY = true;
			pocket.game.ui.mcPopup.mcMap.removeChildAt(0);

			HelperLoader.load(new Loader(), "app:/gamefiles/world-map.swf", new LoaderContext(false, ApplicationDomain.currentDomain), function (event:Event):void {
				pocket.game.ui.mcPopup.mcMap.addChild(MovieClip(Loader(event.target.loader).content));
			});
		}

		public function onBoLComplete(e:Event):void{
			const jso:Object = JSON.parse(String(e.target.data));

			pocket.game.world.bookData = jso;
			pocket.game.BOOK_DATA_READY = jso;

			pocket.game.ui.mcPopup.mcBook.removeChildAt(0);
			
			if (pocket.game.bolContent){
				if (pocket.game.newInstance){
					pocket.game.newInstance = false;
					pocket.game.bolContent.gotoAndStop("NavMenu");
				}

				pocket.game.ui.mcPopup.mcBook.addChild(pocket.game.bolContent);
				return;
			}

			HelperLoader.load(new Loader(), "app:/gamefiles/book-of-lore.swf", new LoaderContext(false, ApplicationDomain.currentDomain), function (event:Event):void {
				pocket.game.bolContent = Loader(event.target.loader).content;
				
				pocket.game.ui.mcPopup.mcBook.addChild(MovieClip(pocket.game.bolContent));
			});
		}
		
		public function onFrameChange(frame:String):void {
			for each (var option:Option in this.pocket.overlay.options) {
				if (option.onFrameChange != null) {
					option.onFrameChange(frame);
				}
			}

			this.pocket.overlay.setOverlayButtonTransform();
		}

	}

}