package data {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;

	public class BakedPart {

		public var part:MovieClip;
		public var bitmap:Bitmap;
		public var frames: Vector.<BitmapData>;

		public var isTimeline:Boolean;

		public var currentFrame:Number = 0;
		
		public function BakedPart(part: MovieClip, bitmap: Bitmap, frames: Vector.<BitmapData>, isTimeline: Boolean) {
			this.part = part;
			this.bitmap = bitmap;
			this.frames = frames;
			this.isTimeline = isTimeline;
		}

	}
	
}