package util {
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class SWFWorkerClient {

		[Embed(source="../../gamefiles/embed/WorkerMain.swf", mimeType="application/octet-stream")]
		private static const WorkerSWF:Class;

		private static var _instance:SWFWorkerClient;

		public static function get instance():SWFWorkerClient {
			if (_instance == null) {
				_instance = new SWFWorkerClient();
			}

			return _instance;
		}

		private var bgWorker:Worker;
		private var toWorker:MessageChannel;
		private var fromWorker:MessageChannel;

		private var nextId:uint = 0;
		private var pending:Dictionary = new Dictionary();
		private var supported:Boolean;

		public function SWFWorkerClient() {
			supported = WorkerDomain.isSupported;

			if (!supported) {
				return;
			}

			const swfBytes:ByteArray = new WorkerSWF() as ByteArray;

			bgWorker = WorkerDomain.current.createWorker(swfBytes);

			toWorker = Worker.current.createMessageChannel(bgWorker);
			fromWorker = bgWorker.createMessageChannel(Worker.current);

			bgWorker.setSharedProperty("toWorker", toWorker);
			bgWorker.setSharedProperty("fromWorker", fromWorker);

			fromWorker.addEventListener(Event.CHANNEL_MESSAGE, onWorkerMessage);

			bgWorker.start();
		}

		public function process(bytes:ByteArray, stripAnimation:Boolean, stripFilters:Boolean, onDone:Function):void {
			if (!supported) {
				onDone(SWFStripper.process(bytes, stripAnimation, stripFilters));
				return;
			}

			const id:uint = nextId++;
			pending[id] = onDone;

			toWorker.send({id: id, bytes: bytes, stripAnimation: stripAnimation, stripFilters: stripFilters});
		}

		private function onWorkerMessage(e:Event):void {
			while (fromWorker.messageAvailable) {
				const result:Object = fromWorker.receive();
				const callback:Function = pending[result.id];

				if (callback == null) {
					continue;
				}
				
				delete pending[result.id];

				if (result.error) {
					// Fall back to original bytes rather than dropping the load entirely.
					callback(result.bytes as ByteArray);
				} else {
					callback(result.bytes as ByteArray);
				}
			}
		}
	}
}