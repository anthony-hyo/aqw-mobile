package engine {

	import data.BakedPart;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	import util.HelperRasterizer;

	public class Rasterizer extends Sprite {

		protected var _bakedParts:Vector.<BakedPart> = new Vector.<BakedPart>();
		protected var _partsToMonitor:Vector.<DisplayObject>;

		protected function bakePart(targetPart:MovieClip):void {
			if (!targetPart || targetPart.numChildren == 0 || targetPart.name == "hitbox" || targetPart.getChildByName("bmp_cache")) {
				return;
			}

			const isTimeline:Boolean = HelperRasterizer.hasLabel(targetPart, "Walk");

			const totalFrames:int = Math.min(isTimeline ? targetPart.totalFrames : HelperRasterizer.getMasterCycle(targetPart), 60);


			var i:int;

			// Start the movieclip at frame 1 and let it play naturally
			HelperRasterizer.resetPlayback(targetPart);

			var bounds:Rectangle;
			var maxBounds:Rectangle = new Rectangle();

			for (i = 1; i <= totalFrames; i++) {
				bounds = targetPart.getBounds(targetPart);

				if (bounds.width > 0 && bounds.height > 0) {
					if (maxBounds.width == 0) {
						maxBounds = bounds.clone();
					} else {
						maxBounds = maxBounds.union(bounds);
					}
				}

				// Advance time naturally
				HelperRasterizer.simulateFrameAdvance(targetPart);
			}

			//maxBounds.inflate(15, 15);
			maxBounds.inflate(15 * Pocket.RASTERIZER_QUALITY_LEVEL, 15 * Pocket.RASTERIZER_QUALITY_LEVEL);

			if (maxBounds.width <= 0 || maxBounds.width > 2000) {
				const marker:Sprite = new Sprite();

				marker.name = "bmp_cache";
				marker.visible = false;

				targetPart.addChild(marker);
				return;
			}

			const frames:Vector.<BitmapData> = new Vector.<BitmapData>();

			// Reset to the beginning
			HelperRasterizer.resetPlayback(targetPart);

			var bmd:BitmapData;
			var matrix:Matrix;

			for (i = 1; i <= totalFrames; i++) {
				bmd = new BitmapData(Math.ceil(maxBounds.width * Pocket.RASTERIZER_QUALITY_LEVEL), Math.ceil(maxBounds.height * Pocket.RASTERIZER_QUALITY_LEVEL), true, 0x00000000);

				matrix = new Matrix();
				matrix.a = Pocket.RASTERIZER_QUALITY_LEVEL;
				matrix.d = Pocket.RASTERIZER_QUALITY_LEVEL;
				matrix.tx = -maxBounds.left * Pocket.RASTERIZER_QUALITY_LEVEL;
				matrix.ty = -maxBounds.top * Pocket.RASTERIZER_QUALITY_LEVEL;

				// bmd.draw(part, m, null, null, null, false);

				//m.scale(Pocket.RASTERIZER_QUALITY_LEVEL, Pocket.RASTERIZER_QUALITY_LEVEL)
				bmd.draw(targetPart, matrix, null, null, null, true);

				frames.push(bmd);

				// Advance time naturally
				HelperRasterizer.simulateFrameAdvance(targetPart);
			}

//			try {
//				while (targetPart.numChildren > 0) {
//					targetPart.removeChildAt(0);
//				}
//			} catch (err:Error) {
//				trace(err.getStackTrace());
//			}

			for (var c:int = 0; c < targetPart.numChildren; c++) {
				targetPart.removeChildAt(c);
			}

			const bitmap:Bitmap = new Bitmap(frames[0]);

			bitmap.name = "bmp_cache";
			bitmap.smoothing = true;

			bitmap.x = maxBounds.left;
			bitmap.y = maxBounds.top;

			bitmap.scaleX = 1 / Pocket.RASTERIZER_QUALITY_LEVEL;
			bitmap.scaleY = 1 / Pocket.RASTERIZER_QUALITY_LEVEL;

			targetPart.addChild(bitmap);

			if (totalFrames > 1) {
				this._bakedParts.push(new BakedPart(targetPart, bitmap, frames, isTimeline));
			}
		}

		public function clearCache():void {
			if (this._bakedParts) {
				for each (var part:BakedPart in this._bakedParts) {
					for each (var bmd:BitmapData in part.frames) {
						bmd.dispose();
					}

					if (part.bitmap && part.bitmap.parent) {
						part.bitmap.parent.removeChild(part.bitmap);
					}

					//if (this.parent) {
					//	this.parent.removeChild(this);
					//}
				}

				this._bakedParts = null; // Force GC

				this._bakedParts = new Vector.<BakedPart>();
			}
		}

		public function dispose():void {
			this.removeEventListener(Event.ENTER_FRAME, onTick);

			clearCache();

			this._bakedParts = null;
		}

		protected function onTick(e:Event):void {
			//if (!Overlay.isAvatarRasterizerOn) {
			//	return;
			//}

			var bakedPart:BakedPart;

			for (var i:int = this._bakedParts.length - 1; i >= 0; i--) {
				bakedPart = this._bakedParts[i];

				if (!bakedPart.part || !bakedPart.part.stage || bakedPart.part.getChildByName("bmp_cache") == null) {
					for each (var bmd:BitmapData in bakedPart.frames) {
						bmd.dispose();
					}

					this._bakedParts.splice(i, 1);

					continue;
				}

				if (bakedPart.isTimeline) {
					var frameIndex:int = bakedPart.part.currentFrame - 1;

					if (frameIndex >= 0 && frameIndex < bakedPart.frames.length) {
						bakedPart.bitmap.bitmapData = bakedPart.frames[frameIndex];
						bakedPart.bitmap.smoothing = true;
					}

					continue;
				}


				const skel:MovieClip = MovieClip(bakedPart.part.parent);

				if (skel && skel.currentLabel == "Idle") {
					bakedPart.currentFrame = 0;
				} else {
					bakedPart.currentFrame++;

					if (bakedPart.currentFrame >= bakedPart.frames.length) {
						bakedPart.currentFrame = 0;
					}
				}

				/*part.cur++;

				if (part.cur >= part.frames.length) {
					part.cur = 0;
				}*/

				bakedPart.bitmap.bitmapData = bakedPart.frames[bakedPart.currentFrame];
				bakedPart.bitmap.smoothing = true;
			}

			for each (var partsToMonitorElement:DisplayObject in _partsToMonitor) {
				if (!(partsToMonitorElement is MovieClip)) {
					continue;
				}

				var mcPart:MovieClip = MovieClip(partsToMonitorElement);

				if (mcPart.numChildren > 0 && mcPart.getChildByName("bmp_cache") == null && mcPart.name != "hitbox") {
					bakePart(mcPart);
				}
			}
		}

	}

}