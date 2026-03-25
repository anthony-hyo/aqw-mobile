package util {

	import flash.net.SharedObject;

	public class HelperSetting {

		private static const SAVE_KEY:String = "aqw_pocket_settings";

		public static const OPTION_SHOW_JOYSTICK:String = "option_show_joystick";
		public static const OPTION_SHOW_SKILL_BAR:String = "option_show_skill_bar";
		public static const OPTION_LOCK_ORIENTATION:String = "option_lock_orientation";

		public static const LAYOUT_JOYSTICK:String = "layout_joystick";
		public static const LAYOUT_SKILL_BAR:String = "layout_skill_bar";

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

		public static function _delete(key:String):void {
			delete so.data[key];
			so.flush();
		}

		public static function getBool(key:String, defaultValue:Boolean = false):Boolean {
			return Boolean(_get(key, defaultValue));
		}

		public static function setBool(key:String, value:Boolean):void {
			_set(key, value);
		}

		public static function getInt(key:String, defaultValue:int = 0):int {
			return int(_get(key, defaultValue));
		}

		public static function setInt(key:String, value:int):void {
			_set(key, value);
		}

	}
}