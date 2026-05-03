package ui.controller.walk {

    import flash.errors.IllegalOperationError;

    public class WalkController {

        public function WalkController(pocket:Pocket) {
            this.pocket = pocket;
        }

        protected var pocket:Pocket;

        protected var frameTick:int = 0;

        public function update():void {
            throw new IllegalOperationError("Must override update Function");
        }

        public function stop():void {
            throw new IllegalOperationError("Must override stop Function");
        }

    }
}

