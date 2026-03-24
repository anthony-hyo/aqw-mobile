package ui.controller {
	import flash.display.*;
	import flash.geom.*;

	import ui.input.*;

	public class WalkController {

		private static const SEND_EVERY_N_FRAMES:int = 5;
		private static const MOVE_SPEED_MULTIPLIER:Number = 8;

		public function WalkController(pocket:Pocket, joystick:Joystick) {
			this.pocket = pocket;
			this.joystick = joystick;
		}

		private var pocket:Pocket;
		private var joystick:Joystick;

		private var frameTick:int = 0;

		public function update():void {
			if (!this.pocket.game.world || !this.pocket.game.world.myAvatar) {
				return;
			}

			const pMC:MovieClip = this.pocket.game.world.myAvatar.pMC;

			if (pMC == null || (joystick.dirX == 0 && joystick.dirY == 0)) {
				return;
			}

			if (!this.pocket.game.world.isMoveOK(this.pocket.game.world.myAvatar.dataLeaf) || !this.pocket.game.world.bitWalk) {
				return;
			}

			const angle:Number = Math.atan2(joystick.dirY, joystick.dirX);
			const localX:Number = pMC.x + Math.cos(angle) * MOVE_SPEED_MULTIPLIER * 10;
			const localY:Number = pMC.y + Math.sin(angle) * MOVE_SPEED_MULTIPLIER * 10;

			const stagePt:Point = this.pocket.game.world.CHARS.localToGlobal(new Point(localX, localY));

			if (stagePt.x < 0 || stagePt.x > 960 || stagePt.y < 0 || stagePt.y > 550) {
				return;
			}

			const mvPT:Point = pMC.simulateTo(localX, localY, this.pocket.game.world.WALKSPEED);

			if (mvPT == null) {
				return;
			}

			pMC.walkTo(mvPT.x, mvPT.y, this.pocket.game.world.WALKSPEED);

			frameTick++;

			if (frameTick >= SEND_EVERY_N_FRAMES) {
				frameTick = 0;

				this.pocket.game.world.moveRequest({
					mc: pMC,
					tx: mvPT.x,
					ty: mvPT.y,
					sp: this.pocket.game.world.WALKSPEED
				});
			}
		}

		public function stop():void {
			frameTick = 0;

			if (this.pocket.game.world && this.pocket.game.world.myAvatar && this.pocket.game.world.myAvatar.pMC) {
				this.pocket.game.world.myAvatar.pMC.stopWalking();
			}
		}
	}
}

