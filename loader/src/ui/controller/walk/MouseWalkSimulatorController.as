package ui.controller.walk {

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.geom.ColorTransform;
    import flash.geom.Point;
    import flash.utils.getTimer;

    public class MouseWalkSimulatorController extends WalkController {

        private static const SEND_EVERY_N_FRAMES:int = 5;
        private static const MOVE_SPEED_MULTIPLIER:Number = 8;

        private static const WALK_MAX_THRESHOLD:Number = 0.65;
        private static const DASH_THRESHOLD:Number = 0.85;

        private static const DASH_COOLDOWN_MS:int = 1000;

        private static const normalColor:ColorTransform = new ColorTransform();
        private static const dashColor:ColorTransform = new ColorTransform(0, 0, 0, 1, 0, 145, 0, 0);

        private var isDashingVisual:Boolean = false;

        private var lastDashTime:int = 0;

        public function MouseWalkSimulatorController(pocket:Pocket) {
            super(pocket);
        }

        public override function update():void {
            if (!this.pocket.game.world || !this.pocket.game.world.myAvatar) {
                return;
            }

            const pMC:MovieClip = MovieClip(this.pocket.game.world.myAvatar.pMC);
            const joystick:* = this.pocket.overlay.gameUI.joystickMouseSimulator;

            const dirX:Number = joystick.dirX;
            const dirY:Number = joystick.dirY;

            const directionMagnitude:Number = Math.sqrt(dirX * dirX + dirY * dirY);

            if (pMC == null || directionMagnitude == 0) {
                return;
            }

            if (!this.pocket.game.world.isMoveOK(this.pocket.game.world.myAvatar.dataLeaf) || !Boolean(this.pocket.game.world.bitWalk)) {
                return;
            }

            const angle:Number = Math.atan2(dirY, dirX);
            const baseSpeed:Number = Number(this.pocket.game.world.WALKSPEED);

            var moveSpeed:Number = baseSpeed;

            if (directionMagnitude >= DASH_THRESHOLD && !this.isDashingVisual) {
                if (joystick.knob) {
                    joystick.knob.transform.colorTransform = dashColor;
                }

                this.isDashingVisual = true;
            } else if (directionMagnitude < DASH_THRESHOLD && this.isDashingVisual) {
                if (joystick.knob) {
                    joystick.knob.transform.colorTransform = normalColor;
                }

                this.isDashingVisual = false;
            }

            if (directionMagnitude < WALK_MAX_THRESHOLD) {
                moveSpeed = Math.max(baseSpeed * 0.3, baseSpeed * (directionMagnitude / WALK_MAX_THRESHOLD));
            } else if (directionMagnitude >= WALK_MAX_THRESHOLD && directionMagnitude < DASH_THRESHOLD) {
                moveSpeed = baseSpeed;
            } else if (!this.pocket.game.world.justRan) {
                const currentTime:int = getTimer();

                if (currentTime - this.lastDashTime >= DASH_COOLDOWN_MS) {
                    const myAvatar:* = this.pocket.game.world.myAvatar;
                    const playerName:String = myAvatar.pnm;
                    const dashCost:Number = this.pocket.game.world.uoTree[playerName].sta.$dsh || 100;

                    if (myAvatar.dataLeaf.intSP >= dashCost) {
                        this.pocket.game.pDash = true;

                        this.lastDashTime = currentTime;
                    }
                }
            }

            if (this.pocket.game.pDash && !this.pocket.game.world.justRan) {
                this.pocket.game.world.justRan = true;
                this.pocket.game.pDash = false;
            }

            if (this.pocket.game.world.justRan) {
                moveSpeed = baseSpeed * 3;
            }

            this.pocket.game.world.speed = moveSpeed;

            const localX:Number = pMC.x + Math.cos(angle) * MOVE_SPEED_MULTIPLIER * 10;
            const localY:Number = pMC.y + Math.sin(angle) * MOVE_SPEED_MULTIPLIER * 10;

            const stagePt:Point = Sprite(this.pocket.game.world.CHARS).localToGlobal(new Point(localX, localY));

            if (stagePt.x < 0 || stagePt.x > 960 || stagePt.y < 0 || stagePt.y > 550) {
                return;
            }

            const mvPT:Point = pMC.simulateTo(localX, localY, moveSpeed);

            if (mvPT == null) {
                return;
            }

            pMC.walkTo(mvPT.x, mvPT.y, moveSpeed);

            this.frameTick++;

            if (this.frameTick >= SEND_EVERY_N_FRAMES) {
                this.frameTick = 0;

                this.pocket.game.world.moveRequest({
                    mc: pMC,
                    tx: mvPT.x,
                    ty: mvPT.y,
                    sp: moveSpeed
                });
            }
        }

        public override function stop():void {
            this.frameTick = 0;

            if (this.pocket.game.world && this.pocket.game.world.myAvatar && this.pocket.game.world.myAvatar.pMC) {
                this.pocket.game.world.myAvatar.pMC.stopWalking();
            }

            if (this.isDashingVisual) {
                const joystick:* = this.pocket.overlay.gameUI.joystickMouseSimulator;
                if (joystick && joystick.knob) {
                    joystick.knob.transform.colorTransform = normalColor;
                }
                this.isDashingVisual = false;
            }
        }

    }

}