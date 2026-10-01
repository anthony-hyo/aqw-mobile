package game {

	import ui.input.SkillFrame;
	import ui.input.SkillMask;

	public class SkillInfinity {

		public var id:int;
		public var frame:SkillFrame;
		public var mask:SkillMask;

		public function SkillInfinity(id:int, frame:SkillFrame, mask:SkillMask) {
			this.id = id;
			this.frame = frame;
			this.mask = mask;
		}

	}

}
