package load {

	import flash.display.Loader;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	import util.HelperLoader;

	public class Load {

		public function Load(pocket:Pocket) {
			this.pocket = pocket;

			this.context.allowCodeImport = true;
		}

		public var domain:ApplicationDomain = new ApplicationDomain();
		public var context:LoaderContext = new LoaderContext(false, domain);

		protected var pocket:Pocket = null;
		protected var url:String = "";

		public function start():void {
			this.load();
		}

		protected function load():void {
			HelperLoader.load(new Loader(), this.url, this.context, this.onCompleted, this.onProgress, this.onError);
		}

		protected function onCompleted(event:Event):void {
			throw new IllegalOperationError("Must override onCompleted Function");
		}

		protected function onProgress(event:ProgressEvent):void {
			throw new IllegalOperationError("Must override onProgress Function");
		}

		protected function onError(error:IOErrorEvent):void {
			throw new IllegalOperationError("Must override onError Function");
		}

	}
}