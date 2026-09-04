package util {

	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.system.LoaderContext;

	public class HelperLoader {

		public static var COUNT:uint = 0;

		public static function prepareContext(ctx:LoaderContext):void {
			ctx.checkPolicyFile = false;
			ctx.allowCodeImport = true;
		}

		public static function buildRequest(url:String):URLRequest {
			const request:URLRequest = new URLRequest(url);

			request.requestHeaders.push(new URLRequestHeader("Accept", "*/*"));
			request.requestHeaders.push(new URLRequestHeader("Accept-Language", "en-US,en;q=0.9"));
			request.requestHeaders.push(new URLRequestHeader("artixmode", "launcher"));
			request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/x-www-form-urlencoded"));
			request.requestHeaders.push(new URLRequestHeader("Origin", "https://game.aq.com"));
			request.requestHeaders.push(new URLRequestHeader("Referer", "https://game.aq.com/game/gamefiles/Game3098r25.swf?ver=R0047"));
			request.requestHeaders.push(new URLRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Safari/537.36"));
			request.requestHeaders.push(new URLRequestHeader("X-Requested-With", "ShockwaveFlash/32.0.0.371"));

			return request;
		}

		public static function progressPercent(e:ProgressEvent):int {
			return int((e.currentTarget.bytesLoaded / e.currentTarget.bytesTotal) * 100);
		}

	}
}