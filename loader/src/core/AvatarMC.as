package core {

	import flash.display.MovieClip;
	import flash.geom.ColorTransform;

	public class AvatarMC {

		private static const _ct:ColorTransform = new ColorTransform();

		public function AvatarMC(pocket:Pocket) {
			this.pocket = pocket;
		}

		private var pocket:Pocket;

		public function setColor(target: MovieClip, mc:MovieClip, strColor:String, strLocation:String, strShade:String):void {
			const colorInt:Number = Number(target.pAV.objData[("intColor" + strLocation)]);

			mc.isColored = true;
			mc.intColor = colorInt;
			mc.strLocation = strLocation;
			mc.strShade = strShade;

			this.changeColor(mc, colorInt, strShade);
		}

		public function changeColor(mc:MovieClip, colorInt:Number, strShade:String, strModifier:String = ""):void {
			// Animation may call this every frame -> _cKey skips the colorTransform
			// write (and the dirty region mark it triggers) when nothing changed

			const cacheKey:String = colorInt + "|" + strShade + "|" + strModifier;

			if (mc.hasOwnProperty("_cKey") && mc._cKey == cacheKey) {
				return;
			}

			mc._cKey = cacheKey;

			// Reuse static instance -> no GC pressure regardless of call frequency
			_ct.color = 0;
			_ct.redOffset = 0;
			_ct.greenOffset = 0;
			_ct.blueOffset = 0;

			if (strModifier == "") {
				_ct.color = colorInt;
			}

			switch (strShade.toUpperCase()) {
				case "LIGHT":
					_ct.redOffset += 100;
					_ct.greenOffset += 100;
					_ct.blueOffset += 100;
					break;
				case "DARK":
					_ct.redOffset -= mc.strLocation == "Skin" ? 25 : 50;
					_ct.greenOffset -= 50;
					_ct.blueOffset -= 50;
					break;
				case "DARKER":
					_ct.redOffset -= 125;
					_ct.greenOffset -= 125;
					_ct.blueOffset -= 125;
					break;
			}

			if (strModifier == "-") {
				_ct.redOffset *= -1;
				_ct.greenOffset *= -1;
				_ct.blueOffset *= -1;
			}

			mc.transform.colorTransform = _ct;
		}

	}

}