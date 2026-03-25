package {
	import flash.desktop.NativeApplication;

	public class Config {

		public static const GAME_BASE_URL:String = "https://game.aq.com/game/";

		public static const API_VERSION_URL:String = GAME_BASE_URL + "api/data/gameversion";
		public static const API_LOGIN_URL:String = GAME_BASE_URL + "api/login/now";

		public static const GAME_SWF_PATH:String = "app:/gamefiles/Game.swf";

		public static const APP_VERSION:String = getVersion();

		private static function getVersion():String {
			const appDesc:XML = NativeApplication.nativeApplication.applicationDescriptor;
			const ns:Namespace = appDesc.namespace();
			
			return "v" + appDesc.ns::versionNumber;
		}

		public static const GITHUB_RELEASES_URL:String = "https://api.github.com/repos/anthony-hyo/aqw-mobile/releases/latest";

	}

}