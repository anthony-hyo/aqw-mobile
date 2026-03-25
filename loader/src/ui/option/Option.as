package ui.option {

	import flash.display.Sprite;
	import flash.text.TextField;

	import util.HelperSetting;

	public class Option extends Sprite {

		public function Option(key:String = "", name:String = "", info:String = "", onChange:Function = null, onFrameChange:Function = null, onOverlayStateChange:Function = null) {
			this.key = key;
			
			this.state = this.key != null ? HelperSetting.getBool(key) : false;
			
			this.onChange = onChange;
			this.onFrameChange = onFrameChange;
			this.onOverlayStateChange = onOverlayStateChange;

			this.nameTxt.text = name;
			this.infoTxt.text = info;
		}
		
		public var nameTxt:TextField;
		public var infoTxt:TextField;

		public var key:String;
		public var state:Boolean;
		public var onChange:Function;
		public var onFrameChange:Function;
		public var onOverlayStateChange:Function;

	}
}