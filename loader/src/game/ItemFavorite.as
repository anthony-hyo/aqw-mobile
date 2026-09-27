package game {
	import flash.display.MovieClip;

	import ui.util.Favorite;

	import util.HelperSetting;

	public class ItemFavorite {

		public function ItemFavorite(pocket:Pocket) {
			this.pocket = pocket;
			this.favoriteIds = HelperSetting.getArray(HelperSetting.OPTION_FAVORITE_ITEMS);
		}

		private var pocket:Pocket;

		private var favoriteIds:Array;

		private var favoriteButton:Favorite;

		public function isFavorite(itemData:Object):Boolean {
			return itemData != null && this.favoriteIds.indexOf(itemData.ItemID) > -1;
		}

		public function toggleFavorite(itemData:Object):Boolean {
			if (itemData == null) {
				return false;
			}

			const index:int = this.favoriteIds.indexOf(itemData.ItemID);

			if (index > -1) {
				this.favoriteIds.splice(index, 1);
			} else {
				this.favoriteIds.push(itemData.ItemID);
			}

			HelperSetting.setArray(HelperSetting.OPTION_FAVORITE_ITEMS, this.favoriteIds);

			return index == -1;
		}

		public function fDraw(state:Object, lpf:MovieClip):void {
			if (this.favoriteButton) {
				this.favoriteButton.fClose();
				this.favoriteButton = null;
			}

			lpf.btnDelete.visible = false;

			if (state.iSel != null) {
				lpf.btnDelete.visible = true;

				lpf.tInfo.htmlText = this.pocket.game.getItemInfoStringB(state.iSel);

				lpf.tInfo.y = lpf.tInfo.textHeight >= 109.8 ? int(((lpf.btnDelete.y + lpf.btnDelete.height) - lpf.tInfo.height) + 10) : int((lpf.btnDelete.y + lpf.btnDelete.height) - lpf.tInfo.textHeight - 3);

				lpf.mcUpgrade.visible = false;
				lpf.mcCoin.visible = false;

				if (state.iSel.bUpg == 1) {
					lpf.mcUpgrade.visible = true;
				}

				if (state.iSel.bCoins == 1) {
					lpf.mcUpgrade.visible = false;
					lpf.mcCoin.visible = true;
				}

				state.loadPreview(state.iSel);
			} else {
				lpf.tInfo.htmlText = "Please select an item to preview.";

				while (lpf.mcPreview.numChildren > 0) {
					lpf.mcPreview.removeChildAt(0);
				}

				state.clearPreview();
			}


			lpf.btnDelete.visible = lpf.getLayout().sMode.toLowerCase().indexOf("shop") <= -1;

			if (state.iSel != null) {
				if (!lpf.btnDelete.visible && state.iSel.sType != "Enhancement") {
					switch (state.iSel.sES) {
						case "Weapon":
						case "he":
						case "ba":
						case "pe":
						case "ar":
						case "co":
						case "mi":
							if (state.iSel.bUpg == 1 && !this.pocket.game.world.myAvatar.isUpgraded()) {
								lpf.btnTry.visible = false;
								break;
							}

							lpf.btnTry.visible = true;
							break;
						case "ho":
						case "hi":
						default:
							lpf.btnTry.visible = false;
					}
				}

				if (state.iSel.sType != "Enhancement") {
					switch (state.iSel.sES) {
						case "ar":
						case "co":
							if (this.pocket.game.world.myAvatar.objData.strGender == "M") {
								lpf.btnFGender.visible = false;
								lpf.btnMGender.visible = true;
							} else {
								lpf.btnFGender.visible = true;
								lpf.btnMGender.visible = false;
							}
							break;
						default:
							lpf.btnFGender.visible = false;
							lpf.btnMGender.visible = false;
					}

				}

				lpf.btnWiki.y = !lpf.btnFGender.visible && !lpf.btnMGender.visible ? lpf.btnMGender.y : 121;

				if (!lpf.btnTry.visible && !lpf.btnDelete.visible) {
					lpf.btnWiki.y = lpf.btnTry.y;
				}

				lpf.btnWiki.visible = true;

				const itemData:Object = state.iSel;
				const favorite:Favorite = Favorite(lpf.addChild(new Favorite()));

				favorite.x += 5;
				favorite.y += 5;

				favorite.fOpen({
					"favorited": this.isFavorite(itemData),
					"onToggle": function ():Boolean {
						const result:Boolean = toggleFavorite(itemData);

						lpf.getLayout().update({"eventType": "refreshItems"});

						return result;
					}
				});

				this.favoriteButton = favorite;
			}
		}

	}
}