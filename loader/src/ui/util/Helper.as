package ui.util {
	import flash.filters.ColorMatrixFilter;

	public class Helper {

		public static const GRAYSCALE:ColorMatrixFilter = new ColorMatrixFilter([
			0.3, 0.59, 0.11, 0, 0,
			0.3, 0.59, 0.11, 0, 0,
			0.3, 0.59, 0.11, 0, 0,
			0, 0, 0, 1, 0
		]);
		
	}
}
