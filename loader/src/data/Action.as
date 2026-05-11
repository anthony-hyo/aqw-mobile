package data {
	public class Action {
		
		public var name:String;
		public var onClick:Function;

		public function Action(name:String, onClick:Function = null) {
			this.name = name;
			this.onClick = onClick;
		}
		
	}
}