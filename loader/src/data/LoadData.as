package data {
	import flash.display.Loader;
	import flash.system.LoaderContext;

	import util.Helper;

	public class LoadData {
		
		public var kind:String;
		public var key:String;

		public var loader:Loader;
		public var context:LoaderContext;
		
		public var url:String;
		
		public var onComplete:Function;
		public var onProgress:Function;
		public var onError:Function;
		public var onHTTPError:Function;
		
		public function LoadData(kind:String, key:String, loader:Loader, context:LoaderContext, url:String, onComplete:Function, onProgress:Function = null, onError:Function = null, onHTTPError:Function = null) {
			this.kind = kind;
			this.key = key;
			
			this.loader = loader;
			this.context = context;
			
			this.url = Helper.trimUrl(url);
			
			this.onComplete = onComplete;
			this.onProgress = onProgress;
			this.onError = onError;
			this.onHTTPError = onHTTPError;
		}

	}
}