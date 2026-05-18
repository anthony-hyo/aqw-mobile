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

		public static function sanitize(s:String):String {
			return s.replace(/[^a-zA-Z0-9]/g, "_");
		}

		/**
		 * Removes trailing whitespace from a URL string.
		 *
		 * Some AQW asset paths are stored in the server's database with a trailing
		 * space (e.g. "Imp01.swf "), likely a typo from the original data entry.
		 * Browsers silently trim URLs before sending, but Adobe AIR sends them
		 * verbatim, causing the IIS server to return 404.
		 *
		 * Example of the raw request that exposes the issue:
		 * GET https://game.aq.com/game/gamefiles/mon/Imp01.swf%20 HTTP/1.1 → 404
		 *
		 * @param str The URL string to sanitize.
		 * @return The URL without trailing whitespace, or the original value if clean.
		 */
		public static function trimUrl(str:String):String {
			if (str == null || str.length == 0) {
				return str;
			}

			var end:int = str.length - 1;

			// Fast-path: no trailing space in the vast majority of URLs
			if (str.charCodeAt(end) > 32) {
				return str;
			}

			// Walk back any whitespace (covers edge cases with multiple spaces)
			while (end >= 0 && str.charCodeAt(end) <= 32) {
				end--;
			}

			return str.substring(0, end + 1);
		}

	}
}
