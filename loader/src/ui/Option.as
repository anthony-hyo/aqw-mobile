package ui {

	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import util.HelperSetting;

	public class Option extends Sprite {

		public function Option(key:String = "", label:String = "", info:String = "", onChange:Function = null) {
			_key = key;
			_state = HelperSetting.getBool(key);
			_onChange = onChange;

			nameTxt.text = label;
			infoTxt.text = info;

			syncState();

			buttonLeft.addEventListener(MouseEvent.CLICK, onToggle);
			buttonRight.addEventListener(MouseEvent.CLICK, onToggle);
		}

		public var nameTxt:TextField;
		public var infoTxt:TextField;
		public var stateTxt:TextField;
		public var buttonLeft:SimpleButton;
		public var buttonRight:SimpleButton;

		private var _key:String;

		private var _onChange:Function;

		private var _state:Boolean;

		public function get state():Boolean {
			return _state;
		}

		public function setup(label:String, info:String, onChange:Function):void {
			nameTxt.text = label;
			infoTxt.text = info;
			_onChange = onChange;
			syncState();
		}

		private function syncState():void {
			stateTxt.text = _state ? "ON" : "OFF";
		}

		private function onToggle(e:MouseEvent):void {
			_state = !_state;

			HelperSetting._set(_key, _state);

			syncState();

			if (_onChange != null) {
				_onChange(_state);
			}
		}

	}
}