package util {
	import flash.display.StageOrientation;
	import flash.filters.ColorMatrixFilter;

	public class Helper {

		public static const GRAYSCALE:ColorMatrixFilter = new ColorMatrixFilter([
			0.3, 0.59, 0.11, 0, 0,
			0.3, 0.59, 0.11, 0, 0,
			0.3, 0.59, 0.11, 0, 0,
			0, 0, 0, 1, 0
		]);

		public static const ORIENTATIONS:Array = [
			StageOrientation.DEFAULT,
			StageOrientation.DEFAULT,
			StageOrientation.ROTATED_LEFT,
			StageOrientation.ROTATED_RIGHT,
			StageOrientation.UPSIDE_DOWN
		];

		public static const RASTERIZER_LEVELS:Array = [
			1,
			1.5,
			2,
			3,
			0.5,
			0.1
		];
		
	}
}
