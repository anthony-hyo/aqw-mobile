package ui.input {

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class SkillBar extends Sprite {

		private static const BTN_SIZE:Number = 58;
		private static const BTN_GAP:Number = 10;

		public function SkillBar(pocket:Pocket) {
			this.pocket = pocket;
			build();
		}

		private var pocket:Pocket;

		private var btns:Vector.<Skill> = new Vector.<Skill>();

		private function build():void {
			return;
			const skills = Sprite(this.pocket.game.ui.mcInterface.actBar);


			for (var i:int = 0; i < 6; i++) {
				trace(skills.getChildAt(i));

				const col:int = i % 3;
				const row:int = int(i / 3);

				const attackButton:Skill = new Skill();

				attackButton.x = col * (BTN_SIZE + BTN_GAP);
				attackButton.y = row * (BTN_SIZE + BTN_GAP);

				attackButton.addEventListener(MouseEvent.MOUSE_DOWN, onPress, false, 0, true);
				attackButton.addEventListener(MouseEvent.MOUSE_UP, onRelease, false, 0, true);
				attackButton.addEventListener(MouseEvent.ROLL_OUT, onRelease, false, 0, true);

				addChild(attackButton);

				btns.push(attackButton);
			}
		}

		private function onPress(e:MouseEvent):void {
			const btn:Skill = Skill(e.currentTarget);

			//btn.setPressed(true);

			const idx:int = btns.indexOf(btn);
			if (idx < 0) return;

			const icon:MovieClip = MovieClip(Sprite(this.pocket.game.ui.mcInterface.actBar).getChildByName("i" + (idx + 1)));

			if (icon != null && icon.actObj != null) {
				if (icon.actObj.auto) {
					this.pocket.game.world.approachTarget();
				} else {
					this.pocket.game.world.testAction(icon.actObj);
				}
			}
		}

		private static function onRelease(e:MouseEvent):void {
			AttackButton(e.currentTarget).setPressed(false);
		}

	}
}

