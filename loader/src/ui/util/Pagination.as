package ui.util {

	import flash.display.MovieClip;

	public class Pagination extends MovieClip {

		public var fData:Object = {};

		public function fClose():void {
			fData = null;
			parent.removeChild(this);
		}

	}

}
