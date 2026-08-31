package util {
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

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
		private const TIMEOUT_MS:uint = 10000;
		private var supported:Boolean;

		public function SWFWorkerClient() {
			supported = WorkerDomain.isSupported;

			if (!supported) {
				return;
			}

			try {
				const swfBytes:ByteArray = new WorkerSWF() as ByteArray;

				bgWorker = WorkerDomain.current.createWorker(swfBytes);

				toWorker = Worker.current.createMessageChannel(bgWorker);
				fromWorker = bgWorker.createMessageChannel(Worker.current);

				bgWorker.setSharedProperty("toWorker", toWorker);
				bgWorker.setSharedProperty("fromWorker", fromWorker);

				fromWorker.addEventListener(Event.CHANNEL_MESSAGE, onWorkerMessage);

				bgWorker.start();
			} catch (e:Error) {
				supported = false;
			}
		}

		public function process(bytes:ByteArray, stripAnimation:Boolean, stripFilters:Boolean, onDone:Function):void {
			if (!supported) {
				onDone(SWFStripper.process(bytes, stripAnimation, stripFilters));
				return;
			}

			const id:uint = nextId++;
			const job:Object = {callback: onDone, originalBytes: bytes, timeoutId: 0};

			job.timeoutId = setTimeout(function ():void {
				if (pending[id] == null) {
					return;
				}

				delete pending[id];

				onDone(bytes);
			}, TIMEOUT_MS);

			pending[id] = job;

			toWorker.send({id: id, bytes: bytes, stripAnimation: stripAnimation, stripFilters: stripFilters});
		}

		private function onWorkerMessage(e:Event):void {
			while (fromWorker.messageAvailable) {
				const result:Object = fromWorker.receive();
				const job:Object = pending[result.id];

				if (job == null) {
					continue;
				}

				delete pending[result.id];

				clearTimeout(job.timeoutId);

				job.callback(result.error ? job.originalBytes as ByteArray : result.bytes as ByteArray);
			}
		}
	}
}