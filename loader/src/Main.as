package {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.display.Loader;
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.ByteArray;

	[SWF(width="960", height="550", frameRate="600", backgroundColor="#000")]
	public dynamic class Main extends MovieClip {

		private static const GAME_BASE_URL:String = "https://game.aq.com/game/";

		private static const API_VERSION_URL:String = GAME_BASE_URL + "api/data/gameversion";
		private static const API_LOGIN_URL:String = GAME_BASE_URL + "api/login/now";
		private static const TITLE_BASE_URL:String = GAME_BASE_URL + "gamefiles/title/";

		private static const GAME_SWF_PATH:String = "app:/gamefiles/Game.swf";
		private static const MAPS_PREFIX:String = "maps/http";

		private static const STATE_BACKGROUND:int = 0;
		private static const STATE_GAME:int = 1;
		private static const STATE_READY:int = 2;

		private var loading:TextField;
		private var logField:TextField;

		private var backgroundDomain:ApplicationDomain = new ApplicationDomain();
		private var backgroundContext:LoaderContext;

		private var clientDomain:ApplicationDomain = new ApplicationDomain();
		private var clientContext:LoaderContext;

		private var gameMovieClip:MovieClip;
		private var titleFile:String;
		private var backgroundFile:String;
		private var loadState:int = STATE_BACKGROUND;

		public function Main() {
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;

			const fmt:TextFormat = new TextFormat();
			fmt.font = "_sans";
			fmt.size = 16;
			fmt.color = 0xFFFFFF;
			fmt.bold = true;

			loading = new TextField();
			loading.defaultTextFormat = fmt;
			loading.width = 400;
			loading.height = 30;
			loading.x = (960 - 400) / 2;
			loading.y = (550 - 30) / 2;
			loading.selectable = false;
			loading.text = "Loading...";
			addChild(loading);

			const logFmt:TextFormat = new TextFormat();
			logFmt.font = "_typewriter";
			logFmt.size = 11;
			logFmt.color = 0xCCCCCC;

			logField = new TextField();
			logField.defaultTextFormat = logFmt;
			logField.width = 920;
			logField.height = 200;
			logField.x = 20;
			logField.y = 330;
			logField.multiline = true;
			logField.wordWrap = true;
			logField.selectable = true; 
			logField.background = true;
			logField.backgroundColor = 0x111111;
			logField.border = true;
			logField.borderColor = 0x444444;
			logField.visible = false;
			addChild(logField);

			log("Init");

			fetchJSON(API_VERSION_URL, onVersionComplete);
		}

		private function log(msg:String):void {
			var timestamp:String = new Date().toTimeString().substr(0, 8);
			logField.appendText("[" + timestamp + "] " + msg + "\n");
			logField.scrollV = logField.maxScrollV;
		}

		private function showError(msg:String):void {
			loading.text = "Error — see log below";
			logField.visible = true;
			log("ERROR: " + msg);
		}

		public function loadMapViaBytes(url:String, context:LoaderContext, onComplete:Function, onProgress:Function = null, onError:Function = null):void {
			url = sanitizeMapUrl(url);
			prepareContext(context);

			loadBinary(url,
				function (bytes:ByteArray):void {
					const ldr:Loader = new Loader();

					if (gameMovieClip != null && gameMovieClip.world != null) {
						gameMovieClip.world.ldr_map = ldr;
					}

					ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
					ldr.loadBytes(bytes, context);
				},
				onProgress,
				onError
			);
		}

		public function queueLoadViaBytes(ldr:Loader, url:String, context:LoaderContext):void {
			prepareContext(context);

			loadBinary(url,
				function (bytes:ByteArray):void {
					ldr.loadBytes(bytes, context);
				},
				null,
				function (e:IOErrorEvent):void {
					ldr.contentLoaderInfo.dispatchEvent(e);
				}
			);
		}

		private function advance():void {
			switch (loadState) {
				case STATE_BACKGROUND:
					loadBackground();
					break;
				case STATE_GAME:
					loadGame();
					break;
				case STATE_READY:
					attachGame();
					break;
			}
		}

		private function loadBackground():void {
			log("Loading background: " + TITLE_BASE_URL + backgroundFile);

			loading.text = "Loading Background...";

			loadSwf(
				TITLE_BASE_URL + backgroundFile,
				backgroundContext,
				onBackgroundComplete,
				onBackgroundProgress,
				function (e:IOErrorEvent):void {
					log("Background load failed, skipping: " + e.text);
					loading.text = "Loading Game...";
					loadState = STATE_GAME;
					advance();
				}
			);
		}

		private function loadGame():void {
			log("Loading game client: " + GAME_SWF_PATH);

			loading.text = "Loading Game...";

			loadSwf(
				GAME_SWF_PATH,
				clientContext,
				onGameComplete,
				onGameProgress,
				function (e:IOErrorEvent):void {
					showError("Failed to load game client: " + e.text);
				}
			);
		}

		private function attachGame():void {
			log("Attaching game...");

			gameMovieClip = MovieClip(stage.addChild(gameMovieClip));

			const params:Object = gameMovieClip.params;

			params.sTitle = titleFile;
			params.isWeb = false;
			params.sURL = GAME_BASE_URL;
			params.sBG = backgroundFile;
			params.isEU = false;
			params.doSignup = false;
			params.loginURL = API_LOGIN_URL;
			params.test = false;

			const rootParams:Object = root.loaderInfo.parameters;

			for (var key:String in rootParams) {
				params[key] = rootParams[key];
			}

			gameMovieClip.failedServers = {mobile: this};

			stage.setChildIndex(gameMovieClip, 0);
			stage.removeChild(DisplayObject(this));
		}

		private function onVersionComplete(e:Event):void {
			try {
				const data:Object = JSON.parse(URLLoader(e.target).data);
				titleFile = data.sTitle;
				backgroundFile = data.sBG;
				log("Version fetched — title: " + titleFile + ", bg: " + backgroundFile);
				advance();
			} catch (err:Error) {
				showError("Failed to parse version response: " + err.message);
			}
		}

		private function onBackgroundComplete(e:Event):void {
			log("Background loaded");

			try {
				const TitleScreenClass:Class = backgroundDomain.getDefinition("TitleScreen") as Class;
				const titleScreen:DisplayObject = new TitleScreenClass();

				titleScreen.x = 0;
				titleScreen.y = 0;

				addChildAt(titleScreen, 1);
			} catch (err:Error) {
				log("TitleScreen class not found, skipping: " + err.message);
			}

			loadState = STATE_GAME;
			advance();
		}

		private function onBackgroundProgress(e:ProgressEvent):void {
			loading.text = "Loading Background " + progressPercent(e) + "%";
		}

		private function onGameComplete(e:Event):void {
			log("Game client loaded");

			gameMovieClip = MovieClip(Loader(e.target.loader).content);
			loadState = STATE_READY;
			advance();
		}

		private function onGameProgress(e:ProgressEvent):void {
			loading.text = "Loading Game " + progressPercent(e) + "%";
		}

		private static function createLoaderContext():LoaderContext {
			const ctx:LoaderContext = new LoaderContext(false, new ApplicationDomain());
			ctx.allowCodeImport = true;
			return ctx;
		}

		private static function prepareContext(ctx:LoaderContext):void {
			ctx.checkPolicyFile = false;
			ctx.allowCodeImport = true;
		}

		private static function sanitizeMapUrl(url:String):String {
			return (url.indexOf(MAPS_PREFIX) == 0) ? url.substring(5) : url;
		}

		private static function progressPercent(e:ProgressEvent):int {
			return int((e.currentTarget.bytesLoaded / e.currentTarget.bytesTotal) * 100);
		}

		private static function loadBinary(url:String, onBytes:Function, onProgress:Function = null, onError:Function = null):void {
			const ul:URLLoader = new URLLoader();

			ul.dataFormat = URLLoaderDataFormat.BINARY;

			ul.addEventListener(Event.COMPLETE, function (e:Event):void {
				onBytes(URLLoader(e.target).data as ByteArray);
			});

			if (onProgress != null) {
				ul.addEventListener(ProgressEvent.PROGRESS, onProgress);
			}

			if (onError != null) {
				ul.addEventListener(IOErrorEvent.IO_ERROR, onError);
			}

			ul.load(new URLRequest(url));
		}

		private static function loadSwf(url:String, context:LoaderContext, onComplete:Function, onProgress:Function = null, onError:Function = null):void {
			loadBinary(url,
				function (bytes:ByteArray):void {
					const ldr:Loader = new Loader();
					ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);

					if (onError != null) {
						ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError);
					}

					ldr.loadBytes(bytes, context);
				},
				onProgress,
				onError
			);
		}

		private static function fetchJSON(url:String, onComplete:Function):void {
			const ul:URLLoader = new URLLoader();
			ul.addEventListener(Event.COMPLETE, onComplete);
			ul.load(new URLRequest(url));
		}
	}
}