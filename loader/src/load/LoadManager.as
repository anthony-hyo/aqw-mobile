package load {

	import data.CategoryMap;
	import data.LoadData;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import util.HelperLoader;
	import util.SWFWorkerClient;

	/**
	 * <h4>Manages the loading of SWFs and memory management.</h4><br>
	 * Replaces the game internal loading system.
	 *
	 * <b>This should help with the game lagging if you play
	 * for a long time and load a lot of SWFs which causes memory leaks and crashes.<b>
	 */
	public class LoadManager {

		private static const MAX_CONCURRENT:int = 15;

		private static const KIND_NO_QUEUE:String = "no_queue";

		private static const KIND_STATIC:String = "static";
		private static const KIND_MAP:String = "map";
		private static const KIND_AVATAR:String = "avatar";

		private static const CATEGORY_MAP:Vector.<CategoryMap> = new <CategoryMap> [
			new CategoryMap("gamefiles/mon/", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_MONSTER_OFF;
			}),
			new CategoryMap("gamefiles/hairs", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_HAIR_OFF;
			}),
			new CategoryMap("gamefiles/classes", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_ARMOR_OFF;
			}),
			new CategoryMap("gamefiles/items/helms", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_HELM_OFF;
			}),
			new CategoryMap("gamefiles/items/capes", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_CAPE_OFF;
			}),
			new CategoryMap("gamefiles/items/grounds", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_MISC_OFF;
			}),
			new CategoryMap("gamefiles/items/pets", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_PET_OFF;
			}),
			new CategoryMap("gamefiles/items/swords", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
			}),
			new CategoryMap("gamefiles/items/maces", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
			}),
			new CategoryMap("gamefiles/items/gauntlets", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
			}),
			new CategoryMap("gamefiles/items/daggers", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
			}),
			new CategoryMap("gamefiles/items/polearms", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
			}),
			new CategoryMap("gamefiles/items/guns", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
			}),
			new CategoryMap("gamefiles/items/staves", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
			}),
			new CategoryMap("gamefiles/items/scythes", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
			}),
			new CategoryMap("gamefiles/items/axes", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
			}),
			new CategoryMap("gamefiles/items/bows", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
			}),
			new CategoryMap("gamefiles/items/whips", function ():Boolean {
				return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
			})
		];

		public function LoadManager() {
			HelperLoader.prepareContext(this.loaderContextStatic);
			HelperLoader.prepareContext(this.loaderContextMap);
			HelperLoader.prepareContext(this.loaderContextAvatar);
		}

		public var applicationDomainStatic:ApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
		public var applicationDomainMap:ApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
		public var applicationDomainAvatar:ApplicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);

		private var loaderContextStatic:LoaderContext = new LoaderContext(false, this.applicationDomainStatic);
		private var loaderContextMap:LoaderContext = new LoaderContext(false, this.applicationDomainMap);
		private var loaderContextAvatar:LoaderContext = new LoaderContext(false, this.applicationDomainAvatar);

		private var queue:Vector.<LoadData> = new Vector.<LoadData>();
		private var concurrentCount:int = 0;
		private var loaderStack:Dictionary = new Dictionary();

		/**
		 * Used to load any SWF, this is deprecated and should be avoided if possible.
		 * <b>I don't know what to do with this, still used in some places.</b>
		 *
		 * @param loader
		 * @param url
		 * @param context
		 * @param onComplete
		 * @param onProgress
		 * @param onError
		 * @param onHTTPError
		 */
		public static function load(loader:Loader, url:String, context:LoaderContext, onComplete:Function = null, onProgress:Function = null, onError:Function = null, onHTTPError:Function = null):void {
			Pocket.SINGLETON.loadManager.load(loader, url, context, onComplete, onProgress, onError, onHTTPError);
		}

		public function load(loader:Loader, url:String, context:LoaderContext, onComplete:Function = null, onProgress:Function = null, onError:Function = null, onHTTPError:Function = null):void {
			HelperLoader.prepareContext(context);

			onLoad(new LoadData(KIND_NO_QUEUE, null, loader, context, url, onComplete, onProgress, onError, onHTTPError));
		}

		/**
		 * Used to load static SWFs such as assets, UI, and other resources.
		 * <b>This is separate from others because we don't need clear loaders, those can stay loaded.</b>
		 *
		 * @param url
		 * @param key
		 * @param onComplete
		 * @param onProgress
		 * @param onError
		 */
		public function loadStatic(url:String, key:String, onComplete:Function, onProgress:Function = null, onError:Function = null):void {
			this.queue.push(new LoadData(KIND_STATIC, key, null, this.loaderContextStatic, url, onComplete, onProgress, onError));
			loadNext();
		}

		/**
		 * Used to load map SWF, Monster SWF and other SWFs that are loaded by the map or any entity related to map.
		 * <b>This is separate from others because we need to clear map loaders when changing maps.</b>
		 *
		 * @param url
		 * @param key
		 * @param onComplete
		 * @param onProgress
		 * @param onError
		 */
		public function loadMap(url:String, key:String, onComplete:Function, onProgress:Function = null, onError:Function = null):void {
			this.queue.push(new LoadData(KIND_MAP, key, null, this.loaderContextMap, url, onComplete, onProgress, onError));
			loadNext();
		}

		/**
		 * Used by AvatarMC to load avatar SWFs.
		 * <b>This is separate from other loaders because we want to use a different ApplicationDomain for avatars.</b>
		 *
		 * @param url
		 * @param key
		 * @param onComplete
		 * @param onError
		 */
		public function loadAvatar(url:String, key:String, onComplete:Function, onError:Function = null):void {
			this.queue.push(new LoadData(KIND_AVATAR, key, null, this.loaderContextAvatar, url, onComplete, null, onError));
			loadNext();
		}

		public function clearLoader(key:String):void {
			if (!(key in this.loaderStack)) {
				return;
			}

			Loader(this.loaderStack[key].loader).unloadAndStop();

			delete this.loaderStack[key];
		}

		public function clearLoaderByKind(kind:String):void {
			for (var key:String in this.loaderStack) {
				if (this.loaderStack[key].kind == kind) {
					Loader(this.loaderStack[key].loader).unloadAndStop();
					delete this.loaderStack[key];
				}
			}
		}

		private function resolveCategoryCheck(url:String):Function {
			const lowerUrl:String = url.toLowerCase();
			var entry:Object;

			for each (entry in CATEGORY_MAP) {
				if (lowerUrl.indexOf(entry.pattern) > -1) {
					return entry.check as Function;
				}
			}

			return null;
		}

		/**
		 * Hell.
		 *
		 * @param loadData
		 */
		private function onLoad(loadData:LoadData):void {
			const isQueued:Boolean = loadData.kind != KIND_NO_QUEUE;

			const urlLoader:URLLoader = new URLLoader();

			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;

			urlLoader.addEventListener(Event.COMPLETE, function (event:Event):void {
				const rawBytes:ByteArray = URLLoader(event.target).data as ByteArray;

				const categoryCheck:Function = resolveCategoryCheck(loadData.url);
				const animationOn:Boolean = categoryCheck != null && categoryCheck();
				const filterOn:Boolean = categoryCheck != null && Pocket.IS_GRAPHIC_FILTER_OFF;

				const finishLoad:Function = function (finalBytes:ByteArray):void {
					const byteLoader:Loader = loadData.loader == null ? new Loader() : loadData.loader;

					if (isQueued) {
						byteLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event):void {
							try {
								if (loadData.onComplete != null) {
									loadData.onComplete(e);
								}

								if (loadData.key != null) {
									clearLoader(loadData.key);

									loaderStack[loadData.key] = {
										kind: loadData.kind,
										loader: byteLoader
									};
								}
							} catch (error:Error) {
								Pocket.SINGLETON.overlay.debug.logError("Failed to load: " + error.getStackTrace());
							}

							concurrentCount--;

							loadNext();
						});

						if (loadData.onHTTPError != null) {
							byteLoader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, loadData.onHTTPError);
						}

						byteLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (event:IOErrorEvent):void {
							if (loadData.onError != null) {
								try {
									loadData.onError(event);
								} catch (error:Error) {
									Pocket.SINGLETON.overlay.debug.logError("Failed to load bytes: " + error.getStackTrace());
								}
							}

							concurrentCount--;

							loadNext();
						});
					} else {
						if (loadData.onComplete != null) {
							byteLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadData.onComplete);
						}

						if (loadData.onHTTPError != null) {
							byteLoader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, loadData.onHTTPError);
						}

						byteLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (event:IOErrorEvent):void {
							if (loadData.onError != null) {
								loadData.onError(event);
								return;
							}
							byteLoader.dispatchEvent(event);
						});
					}

					byteLoader.loadBytes(finalBytes, loadData.context);
				};

				if (animationOn || filterOn) {
					SWFWorkerClient.instance.process(rawBytes, animationOn, filterOn, finishLoad);
				} else {
					finishLoad(rawBytes);
				}
			});

			if (loadData.onProgress != null) {
				urlLoader.addEventListener(ProgressEvent.PROGRESS, loadData.onProgress);
			}

			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function (event:IOErrorEvent):void {
				if (loadData.onError != null) {
					if (isQueued) {
						try {
							loadData.onError(event);
						} catch (error:Error) {
							Pocket.SINGLETON.overlay.debug.logError("Failed to load URL: " + error.getStackTrace());
						}
					} else {
						loadData.onError(event);
					}
				} else if (!isQueued && loadData.loader != null) {
					loadData.loader.dispatchEvent(event);
				}

				if (isQueued) {
					concurrentCount--;

					loadNext();
				}
			});

			urlLoader.load(HelperLoader.buildRequest(loadData.url));
		}

		private function loadNext():void {
			if (this.queue.length <= 0 || this.concurrentCount >= MAX_CONCURRENT) {
				return;
			}

			this.concurrentCount++;

			onLoad(this.queue.shift());
		}

	}

}