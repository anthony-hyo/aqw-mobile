package ui.controller.walk {

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;

	import ui.input.Joystick;

	public class MouseWalkSimulatorController extends WalkController {

		public function MouseWalkSimulatorController(pocket:Pocket) {
			super(pocket);
		}

		public override function update():void {
			if (!this.pocket.game.world || !this.pocket.game.world.myAvatar) {
				return;
			}

			const pMC:MovieClip = MovieClip(this.pocket.game.world.myAvatar.pMC);

			if (pMC == null || (this.pocket.overlay.gameUI.joystickMouseSimulator.dirX == 0 && this.pocket.overlay.gameUI.joystickMouseSimulator.dirY == 0)) {
				return;
			}

			if (!this.pocket.game.world.isMoveOK(this.pocket.game.world.myAvatar.dataLeaf) || !Boolean(this.pocket.game.world.bitWalk)) {
				return;
			}

			const angle:Number = Math.atan2(this.pocket.overlay.gameUI.joystickMouseSimulator.dirY, this.pocket.overlay.gameUI.joystickMouseSimulator.dirX);
			const localX:Number = pMC.x + Math.cos(angle) * MOVE_SPEED_MULTIPLIER * 10;
			const localY:Number = pMC.y + Math.sin(angle) * MOVE_SPEED_MULTIPLIER * 10;

			const stagePt:Point = Sprite(this.pocket.game.world.CHARS).localToGlobal(new Point(localX, localY));

			if (stagePt.x < 0 || stagePt.x > 960 || stagePt.y < 0 || stagePt.y > 550) {
				return;
			}

			const mvPT:Point = pMC.simulateTo(localX, localY, Number(this.pocket.game.world.WALKSPEED));

			if (mvPT == null) {
				return;
			}

			pMC.walkTo(mvPT.x, mvPT.y, Number(this.pocket.game.world.WALKSPEED));

			this.frameTick++;

			if (frameTick >= SEND_EVERY_N_FRAMES) {
				this.frameTick = 0;

				this.pocket.game.world.moveRequest({
					mc: pMC,
					tx: mvPT.x,
					ty: mvPT.y,
					sp: Number(this.pocket.game.world.WALKSPEED)
				});
			}
		}

		public override function stop():void {
			this.frameTick = 0;

			if (this.pocket.game.world && this.pocket.game.world.myAvatar && this.pocket.game.world.myAvatar.pMC) {
				this.pocket.game.world.myAvatar.pMC.stopWalking();
			}
		}

	}

}
