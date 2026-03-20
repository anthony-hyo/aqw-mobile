package util {

	import flash.net.SharedObject;

	public class HelperSetting {

		private static const SAVE_KEY:String = "aqw_pocket_settings";
		
		private static var _so:SharedObject;

		private static function get so():SharedObject {
			if (!_so) {
				_so = SharedObject.getLocal(SAVE_KEY);
			}
			
			return _so;
		}

		public static function _get(key:String, defaultValue:Object = null):Object {
			return so.data.hasOwnProperty(key) ? so.data[key] : defaultValue;
		}

		public static function _set(key:String, value:Object):void {
			so.data[key] = value;
			so.flush();
		}

		public static function getBool(key:String, defaultValue:Boolean = false):Boolean {
			return Boolean(_get(key, defaultValue));
		}

	}
}