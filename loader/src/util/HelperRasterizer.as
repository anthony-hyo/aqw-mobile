package util {

	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;

	public class HelperRasterizer {

		public static function hasLabel(mc:MovieClip, label:String):Boolean {
			//TODO: Cache

			for each (var fl:FrameLabel in mc.currentLabels) {
				if (fl.name == label) {
					return true;
				}
			}

			return false;
		}


		public static function resetPlayback(container:DisplayObjectContainer):void {
			if (container is MovieClip) {
				MovieClip(container).gotoAndPlay(1);
			}

			for (var i:int = 0; i < container.numChildren; i++) {
				if (container.getChildAt(i) is DisplayObjectContainer) {
					resetPlayback(DisplayObjectContainer(container.getChildAt(i)));
				}
			}
		}

		public static function simulateFrameAdvance(container:DisplayObjectContainer):void {
			if (container is MovieClip) {
				var mc:MovieClip = MovieClip(container);

				var nextF:int = mc.currentFrame + 1;

				if (nextF > mc.totalFrames) {
					nextF = 1;
				}

				mc.gotoAndPlay(nextF);
			}

			for (var i:int = 0; i < container.numChildren; i++) {
				if (container.getChildAt(i) is DisplayObjectContainer) {
					simulateFrameAdvance(DisplayObjectContainer(container.getChildAt(i)));
				}
			}
		}

		public static function getTotalCycle(container:DisplayObjectContainer):int {
			const counts:Array = [];

			const mc:MovieClip = container as MovieClip;

			if (mc && mc.totalFrames > 1) {
				return mc.totalFrames;
			}

			findCounts(container, counts);

			if (counts.length == 0) {
				return 1;
			}

			var maxFrames:int = counts[0];
			var cycle:int = counts[0];

			for (var i:int = 1; i < counts.length; i++) {
				if (counts[i] > maxFrames) {
					maxFrames = counts[i];
				}

				cycle = lcm(cycle, counts[i]);
			}

			if (cycle > 150) {
				return maxFrames;
			}

			return cycle;
		}

		public static function getMasterCycle(container:DisplayObjectContainer):int {
			var counts:Array = [];

			findCounts(container, counts);

			if (counts.length == 0) {
				return 1;
			}

			var cycle:int = counts[0];

			for (var i:int = 1; i < counts.length; i++) {
				cycle = lcm(cycle, counts[i]);
			}

			return cycle;
		}

		private static function findCounts(container:DisplayObjectContainer, list:Array):void {
			if (container is MovieClip) {
				const mc:MovieClip = MovieClip(container);

				if (mc.totalFrames > 1 && list.indexOf(mc.totalFrames) == -1) {
					list.push(mc.totalFrames);
				}
			}

			for (var i:int = 0; i < container.numChildren; i++) {
				if (container.getChildAt(i) is DisplayObjectContainer) {
					findCounts(DisplayObjectContainer(container.getChildAt(i)), list);
				}
			}
		}

		private static function lcm(a:int, b:int):int {
			return (a * b) / gcd(a, b);
		}

		private static function gcd(a:int, b:int):int {
			while (b != 0) {
				var temp:int = b;

				b = a % b;
				a = temp;
			}

			return a;
		}

	}
}