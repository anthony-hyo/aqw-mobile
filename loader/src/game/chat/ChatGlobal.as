package game.chat {
	import air.net.WebSocket;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.WebSocketEvent;

	public class ChatGlobal {

		private var ws:WebSocket;

		public function ChatGlobal() {
			this.ws = new WebSocket();

			this.ws.addEventListener(Event.CONNECT, onConnect);
			this.ws.addEventListener(WebSocketEvent.DATA, onData);
			this.ws.addEventListener(Event.CLOSE, onClose);
			this.ws.addEventListener(IOErrorEvent.IO_ERROR, onError);
			this.ws.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);

			this.ws.connect("ws://localhost:6767");
		}

		private function onConnect(e:Event):void {
			trace(">Connected");

			ws.sendMessage(WebSocket.fmtTEXT, "Hello World!");
		}

		private function onData(e:WebSocketEvent):void {
			trace(">Message received", e.stringData);

			//game.chatF.pushMsg("server", ("The server time is now " + dt.toString()), "SERVER", "", 0);
		}

		private function onClose(e:Event):void {
			trace(">Closed", ws.closeReason);
		}

		private function onError(e:*):void {
			trace(">Error",e.text);
		}

	}
}
