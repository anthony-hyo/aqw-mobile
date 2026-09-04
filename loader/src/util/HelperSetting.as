package util {

	import flash.net.SharedObject;

	public class HelperSetting {

		private static const SAVE_KEY:String = "aqw_pocket_settings";

		public static const OPTION_SHOW_JOYSTICK_MOUSE:String = "option_show_joystick";
		public static const OPTION_SHOW_JOYSTICK_KEYBOARD:String = "option_show_joystick_keyboard";
		
		public static const OPTION_JOYSTICK_DASH:String = "option_joystick_dash";

		public static const OPTION_SHOW_SKILL_BAR:String = "option_show_skill_bar";
		public static const OPTION_SNAP_TO_GRID:String = "option_snap_to_grid";
		public static const OPTION_FPS:String = "option_fps";
		public static const OPTION_LANGUAGE:String = "option_language";
		public static const OPTION_LOCK_ORIENTATION:String = "option_lock_orientation";
		public static const OPTION_DISCORD_RPC:String = "option_discord_rpc";

		public static const OPTION_SHORTCUTS:String = "shortcut_buttons";

		public static const OPTION_RASTERIZER:String = "option_rasterizer";
		public static const OPTION_RASTERIZER_LEVELS:String = "option_rasterizer_levels";

		public static const OPTION_ANIMATION_MONSTER:String = "option_animation_monster";
		public static const OPTION_ANIMATION_HELM:String = "option_animation_helm";
		public static const OPTION_ANIMATION_ARMOR:String = "option_animation_armor";
		public static const OPTION_ANIMATION_CAPE:String = "option_animation_cape";
		public static const OPTION_ANIMATION_HAIR:String = "option_animation_hair";
		public static const OPTION_ANIMATION_PET:String = "option_animation_pet";
		public static const OPTION_ANIMATION_MISC:String = "option_animation_misc";
		public static const OPTION_ANIMATION_WEAPON:String = "option_animation_weapon";
		public static const OPTION_ANIMATION_MAP:String = "option_animation_map";

		public static const OPTION_FILTER:String = "option_filter";

		public static const LAYOUT_JOYSTICK_MOUSE:String = "layout_joystick";
		public static const LAYOUT_JOYSTICK_KEYBOARD:String = "layout_joystick_keyboard";

		public static const LAYOUT_SKILL_BAR:String = "layout_skill_bar";

		private static var _so:SharedObject;

		private static function get so():SharedObject {
			if (!_so) {
				_so = SharedObject.getLocal(SAVE_KEY);
			}

			return _so;
		}

		public static function _get(key:String, defaultValue:Object = null):Object {
			if (so.data.hasOwnProperty(key)) {
				return so.data[key];
			}

			_set(key, defaultValue);

			return defaultValue;
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

		public static function getString(key:String, defaultValue:String = ""):String {
			return String(_get(key, defaultValue));
		}

		public static function setString(key:String, value:String):void {
			_set(key, value);
		}

	}
}