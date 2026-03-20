package load.handlers {

	import data.Release;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	import load.Load;

	import util.HelperLoader;

	public class UpdateLoad extends Load {

		public function UpdateLoad(pocket:Pocket) {
			super(pocket);
		}

		override public function start():void {
			this.url = Config.GITHUB_RELEASES_URL;

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
				this.pocket.release = new Release(JSON.parse(URLLoader(event.target).data));

				const latest:String = this.pocket.release.tag_name;
				const current:String = Config.APP_VERSION;

				this.pocket.overlay.log("Update check — latest: " + latest + "  current: " + current);

				if (latest != current) {
					this.pocket.overlay.notification("Update available <font color='#f0c040'>" + latest + "</font> <a href='" + this.pocket.release.html_url + "'><font color='#6ec6ff'><u>DOWNLOAD</u></font></a>");

					this.pocket.overlay.log("New release available: " + latest + " (" + this.pocket.release.html_url + ")");
				} else {
					this.pocket.overlay.log("App is up to date.");
				}
			} catch (error:Error) {
				this.pocket.overlay.logError("Failed to parse release response: " + error.message);
			}

			this.pocket.advance();
		}

		override protected function onProgress(progressEvent:ProgressEvent):void {
			this.pocket.loadingTxt.text = "Checking for updates… " + HelperLoader.progressPercent(progressEvent) + "%";
		}

		override protected function onError(error:IOErrorEvent):void {
			this.pocket.overlay.logError("Update check failed: " + error.text);

			this.pocket.advance();
		}

	}
}