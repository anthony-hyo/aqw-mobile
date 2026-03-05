package core {

	import flash.display.MovieClip;
	import flash.geom.ColorTransform;

	public class Game {

		public function Game(pocket:Pocket) {
			this.pocket = pocket;
		}

		private var pocket:Pocket;

		public function mcSetColor(mc:MovieClip, strColor:String, strShade:String):void {
			var avOwner:MovieClip;
			var location:String;

			if (pocket.game.currentLabel == "Select") {
				pocket.game.mcCharSelect.mcSetColor(mc, strColor, strShade);
				return;
			}

			// Animation calls this every frame -> traversal only happens once
			// Cache lives on the MC, dies naturally when MC is removed/GC'd

			if (mc.hasOwnProperty("_ctxLoc")) {
				location = mc._ctxLoc;
				avOwner = mc._ctxAV;
			} else {
				avOwner = mc;
				location = "none";

				var nodeName:String;

				while (avOwner != null && avOwner.parent != null && avOwner.parent != avOwner.stage) {
					if ("pAV" in avOwner) {
						nodeName = avOwner.name;

						switch (true) {
							case (nodeName.indexOf("previewMC") > -1):
								location = "e";
								break;
							case (nodeName.indexOf("Dummy") > -1):
								location = "d";
								break;
							case (nodeName.indexOf("mcPortraitTarget") > -1):
								location = "c";
								break;
							case (nodeName.indexOf("mcPortrait") > -1):
								location = "b";
								break;
							default:
								location = "a";
						}

						break;
					}

					avOwner = MovieClip(avOwner.parent);
				}

				mc._ctxLoc = location;
				mc._ctxAV = avOwner;
			}

			if (location != "none") {
				if (avOwner.pAV == undefined) {
					pocket.game.world.myAvatar.pMC.setColor(mc, location, strColor, strShade);
				} else {
					avOwner.pAV.pMC.setColor(mc, location, strColor, strShade);
				}
			}
		}

	}

}