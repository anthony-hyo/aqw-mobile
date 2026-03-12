package data {

	public class Data {

		public function Data(obj:Object = null) {
			if (obj != null) {
				fromObject(obj);
			}
		}

		public function fromObject(obj:Object):void {
			for (var p:String in obj) {
				if (this.hasOwnProperty(p) && !(this[p] is Vector.<*>)) {
					if (typeof this[p] === "boolean") {
						this[p] = !(obj[p] == "false" || obj[p] == "0" || !obj[p]);
					} else {
						this[p] = obj[p];
					}
				}
			}
		}

	}
}
