package util {

	import flash.net.SharedObject;

	public class HelperSetting {

		private static const SAVE_KEY:String = "aqw_pocket_settings";

		public static const OPTION_ENABLE_DEBUG:String = "option_show_debug";
		public static const OPTION_SHOW_JOYSTICK:String = "option_show_joystick";
		public static const OPTION_EDIT_LAYOUT:String = "option_edit_layout";
		public static const OPTION_RESET_LAYOUT:String = "option_reset_layout";
		public static const OPTION_ENABLE_ROTATION:String = "option_enable_rotation";
		
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

	}
}