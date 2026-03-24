package ui.option {

	import flash.display.Sprite;
	import flash.text.TextField;

	import util.HelperSetting;

	public class Option extends Sprite {

		public function Option(key:String = "", name:String = "", info:String = "", onChange:Function = null) {
			this._key = key;
			this._state = HelperSetting.getBool(key);
			this._onChange = onChange;

			this.nameTxt.text = name;
			this.infoTxt.text = info;
		}
		
		public var nameTxt:TextField;
		public var infoTxt:TextField;
		
		protected var _key:String;
		protected var _onChange:Function;

		protected var _state:Boolean;

		public function get state():Boolean {
			return _state;
		}

		protected function setState(value:Boolean):void {
			_state = value;

			HelperSetting._set(_key, _state);

			if (_onChange != null) {
				_onChange(this);
			}
		}

	}
}