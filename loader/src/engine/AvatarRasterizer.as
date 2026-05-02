package engine {

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;

	public class AvatarRasterizer extends Rasterizer {

		public function AvatarRasterizer(avatar:*) {
			const source:MovieClip = avatar.mcChar;

			if (Pocket.IS_ANIMATION_OFF) {
				source.stopAllMovieClips();
			}

			if (!Pocket.IS_RASTERIZER_ON) {
				return;
			}

			_partsToMonitor = new <DisplayObject>[
				source.idlefoot,
				source.chest,
				source.weaponOff,
				source.frontthigh,
				source.cape,
				source.frontshoulder,
				source.weaponFistOff,
				//source.hitbox,
				source.head,
				source.backshoulder,
				source.hip,
				source.backthigh,
				source.backhair,
				source.weaponFist,
				source.backshin,
				source.weaponTemp,
				source.robe,
				//source.pvpFlag,
				source.weapon,
				source.frontshin,
				source.backfoot,
				source.backrobe,
				source.arrow,
				//source.emoteFX,
				source.shield,
				source.frontfoot,
				source.backhand,
				source.fronthand,

				//Misc
				avatar.cShadow
			];

			avatar.addChild(this);

			this.addEventListener(Event.ENTER_FRAME, onTick, false, 0, true);
		}

	}

}