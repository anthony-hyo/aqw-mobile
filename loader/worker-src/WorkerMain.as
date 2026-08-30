package {

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;

	import util.SWFStripper;
	
	public class WorkerMain extends Sprite {

		public function WorkerMain() {
			if (Worker.current.isPrimordial) {
				return;
			}

			const fromMain:MessageChannel = Worker.current.getSharedProperty("toWorker") as MessageChannel;
			const toMain:MessageChannel = Worker.current.getSharedProperty("fromWorker") as MessageChannel;

			fromMain.addEventListener(Event.CHANNEL_MESSAGE, function (e:Event):void {
				while (fromMain.messageAvailable) {
					const job:Object = fromMain.receive();

					var resultBytes:ByteArray;
					var errorMsg:String = null;

					try {
						resultBytes = SWFStripper.process(job.bytes as ByteArray, job.stripAnimation, job.stripFilters);
					} catch (err:Error) {
						errorMsg = err.message;
					}

					toMain.send({id: job.id, bytes: resultBytes, error: errorMsg});
				}
			});
		}
	}
}