const s = () => {
	const webhookGlobal = process.env?.DISCORD_WEBHOOK_CHAT_GLOBAL;

	if (!webhookGlobal) {
		console.error("DISCORD_WEBHOOK_CHAT_GLOBAL is not set");
		return;
	}

	const server = Bun.serve({
		hostname: "0.0.0.0",
		port: 6767,
		fetch(req, server) {
			if (server.upgrade(req)) {
				return;
			}

			return new Response("AQW Pocket");
		},
		websocket: {
			message(_ws, message) {
				console.log(message);

				server.publish("world", message);

				fetch(webhookGlobal, {
					method: "POST",
					headers: {
						"Content-Type": "application/json"
					},
					body: JSON.stringify({content: message})
				})
					.catch(console.error);
			},
			open(ws) {
				ws.subscribe("world");
			}
		}
	});

	console.log(`Server is running on ${server.url}`);
};

s();