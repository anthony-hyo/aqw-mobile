package util {

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	public class HelperLoader {

		public static var COUNT:uint = 0;

		private static const CATEGORY_MAP:Array = [
			{
				pattern: "mon/", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_MONSTER_OFF;
				}
			},
			{
				pattern: "hairs", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_HAIR_OFF;
				}
			},
			{
				pattern: "classes", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_ARMOR_OFF;
				}
			},
			{
				pattern: "helms", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_HELM_OFF;
				}
			},
			{
				pattern: "capes", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_CAPE_OFF;
				}
			},
			{
				pattern: "grounds", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_MISC_OFF;
				}
			},
			{
				pattern: "pets", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_PET_OFF;
				}
			},
			{
				pattern: "items", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
				}
			}
		];

		public static function load(ldr:Loader, url:String, context:LoaderContext, onComplete:Function = null, onProgress:Function = null, onError:Function = null, onHTTPError:Function = null):void {
			prepareContext(context);

			url = Helper.trimUrl(url);

			loadBinary(url,
				function (bytes:ByteArray):void {
					const categoryCheck:Function = resolveCategoryCheck(url);

					const animationOn:Boolean = categoryCheck != null && categoryCheck();
					const filterOn:Boolean = categoryCheck != null && Pocket.IS_GRAPHIC_FILTER_OFF;

					const finishLoad:Function = function (finalBytes:ByteArray):void {
						if (onComplete != null) {
							ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
						}

						if (onHTTPError != null) {
							ldr.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPError);
						}

						ldr.loadBytes(finalBytes, context);
					};

					if (animationOn || filterOn) {
						SWFWorkerClient.instance.process(bytes, animationOn, filterOn, finishLoad);
					} else {
						finishLoad(bytes);
					}
				},
				onProgress,
				function (e:IOErrorEvent):void {
					if (onError != null) {
						onError(e);
						return;
					}
					ldr.dispatchEvent(e);
				}
			);
		}

		private static function resolveCategoryCheck(url:String):Function {
			const lowerUrl:String = url.toLowerCase();

			var entry:Object;

			for each (entry in CATEGORY_MAP) {
				if (lowerUrl.indexOf(entry.pattern) > -1) {
					return entry.check as Function;
				}
			}

			return null;
		}

		private static function loadBinary(url:String, onBytes:Function, onProgress:Function = null, onError:Function = null):void {
			const urlLoader:URLLoader = new URLLoader();

			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;

			urlLoader.addEventListener(Event.COMPLETE, function (e:Event):void {
				onBytes(URLLoader(e.target).data as ByteArray);
			});

			if (onProgress != null) {
				urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			}

			if (onError != null) {
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			}

			const request:URLRequest = new URLRequest(url);

			request.requestHeaders.push(new URLRequestHeader("Accept", "*/*"));
			request.requestHeaders.push(new URLRequestHeader("Accept-Language", "pt-BR"));
			request.requestHeaders.push(new URLRequestHeader("artixmode", "launcher"));
			request.requestHeaders.push(new URLRequestHeader("Content-Type", "application/x-www-form-urlencoded"));
			request.requestHeaders.push(new URLRequestHeader("Origin", "https://game.aq.com"));
			request.requestHeaders.push(new URLRequestHeader("Referer", "https://game.aq.com/game/gamefiles/Game3098r25.swf?ver=R0047"));
			request.requestHeaders.push(new URLRequestHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Safari/537.36"));
			request.requestHeaders.push(new URLRequestHeader("X-Requested-With", "ShockwaveFlash/32.0.0.371"));

			urlLoader.load(request);
		}

		private static function prepareContext(ctx:LoaderContext):void {
			ctx.checkPolicyFile = false;
			ctx.allowCodeImport = true;
		}

		public static function progressPercent(e:ProgressEvent):int {
			return int((e.currentTarget.bytesLoaded / e.currentTarget.bytesTotal) * 100);
		}

	}
}