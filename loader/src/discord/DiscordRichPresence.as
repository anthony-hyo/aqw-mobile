package discord {

	import fi.joniaromaa.adobeair.discordrpc.DiscordRpc;

	import util.Helper;

	public class DiscordRichPresence {

		private var pocket:Pocket;

		private var discordRpc:DiscordRpc = new DiscordRpc();

		private var sessionStartTime:Number = Math.round(new Date().valueOf() / 1000);

		public function DiscordRichPresence(pocket:Pocket) {
			this.pocket = pocket;

			this.discordRpc.init("1526842696306659328");

			refreshPresence();
		}

		public function refreshPresence():void {
			var state:String = null;
			var details:String = null;
			var smallImage:String = null;
			var smallImageDescription:String = null;

			if (!this.pocket.game) {
				this.discordRpc.updatePresence(
					state,
					details,
					this.sessionStartTime,
					0,
					null,
					null,
					smallImage,
					smallImageDescription,
					null,
					0,
					0,
					null,
					null
				);

				return;
			}

			switch (this.pocket.game.currentFrameLabel) {
				case "Game":
					if (this.pocket.game.world.myAvatar) {
						const className:String = " - " + (this.pocket.game.world.myAvatar.objData.strClassName ? this.pocket.game.world.myAvatar.objData.strClassName : "No Class");
						const playerSummary:String = this.pocket.game.world.myAvatar.objData.strUsername + className + " - Lvl " + String(this.pocket.game.world.myAvatar.objData.intLevel);

						details = playerSummary != "" ? playerSummary : "Exploring";

						const uLeaf:Object = this.pocket.game.world.uoTree[this.pocket.game.sfc.myUserName];

						switch (true) {
							case uLeaf && uLeaf.afk:
								state = "AFK in " + Helper.capitalizeFirstLetter(this.pocket.game.world.strMapName);
								smallImage = "iball3";
								smallImageDescription = "AFK";
								break;
							case this.pocket.game.world.myAvatar.dataLeaf.intState == 0:
								state = "Dead in " + Helper.capitalizeFirstLetter(this.pocket.game.world.strMapName);
								smallImage = "iball1";
								smallImageDescription = "Dead";
								break;
							case this.pocket.game.world.myAvatar.dataLeaf.intState == 1:
								state = "In " + Helper.capitalizeFirstLetter(this.pocket.game.world.strMapName);
								smallImage = "iball4";
								smallImageDescription = "Idle";
								break;
							case this.pocket.game.world.myAvatar.dataLeaf.intState == 2:
								state = "In battle at " + Helper.capitalizeFirstLetter(this.pocket.game.world.strMapName);
								smallImage = "iball2";
								smallImageDescription = "Combat";
								break;
						}
					}
					break;
			}

			this.discordRpc.updatePresence(
				state,
				details,
				this.sessionStartTime,
				0,
				null,
				null,
				smallImage,
				smallImageDescription,
				null,
				0,
				0,
				null,
				null
			);
		}

	}
}
