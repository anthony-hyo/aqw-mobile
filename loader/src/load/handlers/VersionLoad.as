package load.handlers {

	import data.Version;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	import load.Load;

	import util.HelperLoader;

	public class VersionLoad extends Load {

		public function VersionLoad(pocket:Pocket) {
			super(pocket);
		}

		override public function start():void {
			this.url = Config.API_VERSION_URL;

			super.start();
		}

		override protected function load():void {
			const urlLoader:URLLoader = new URLLoader(new URLRequest(this.url));

			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;

			urlLoader.addEventListener(Event.COMPLETE, this.onCompleted);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onError);
		}

		override protected function onCompleted(event:Event):void {
			try {
				this.pocket.version = new Version(JSON.parse(URLLoader(event.target).data));

				this.pocket.overlay.log("Version fetched");
				this.pocket.overlay.log("File: " + this.pocket.version.sFile);
				this.pocket.overlay.log("Title: " + this.pocket.version.sTitle);
				this.pocket.overlay.log("Background: " + this.pocket.version.sBG);
				this.pocket.overlay.log("Version: " + this.pocket.version.sVersion);

				this.pocket.advance();
			} catch (err:Error) {
				this.pocket.overlay.logError("Failed to parse version response: " + err.message);
			}
		}

		override protected function onProgress(progressEvent:ProgressEvent):void {
			this.pocket.loadingTxt.text = "API " + HelperLoader.progressPercent(progressEvent) + "%";
		}

		override protected function onError(error:IOErrorEvent):void {
			this.pocket.loadingTxt.text = "Version load failed: " + error.text;
			this.pocket.overlay.logError("Version load failed: " + error.text);

			//this.pocket.advance();
		}

	}
}