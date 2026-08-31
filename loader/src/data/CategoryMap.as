package data {
	public class CategoryMap {

		public function CategoryMap(pattern:String, check:Function) {
			this.pattern = pattern;
			this.check = check;
		}


		public var pattern:String;
		public var check:Function;

	}
}
