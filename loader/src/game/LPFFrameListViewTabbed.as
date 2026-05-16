package game {
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	import ui.util.Pagination;

	public class LPFFrameListViewTabbed {

		public function LPFFrameListViewTabbed(pocket:Pocket) {
			this.pocket = pocket;
		}

		private var pocket:Pocket;

		/**
		 * Patch freezing when opening Bank, Inventory etc..
		 *
		 * @param state
		 * @param lpf
		 * @param reset
		 * @return
		 */
		public function fDraw(state:Object, lpf:Object, reset:Boolean):Object {
			var listA:Array = [];
			var sortedGroup:Array = [];
			var filteredItems:Array = [];
			var i:int;
			var itemData:Object;

			const tSel:Object = state.tSel;
			const iSel:Object = state.iSel;
			const filterMap:Object = state.filterMap;
			const itemList:Array = state.itemList;
			const sortOrder:Array = state.sortOrder;
			const onDemand:Boolean = state.onDemand;
			const bLimited:Boolean = state.bLimited;
			const itemEventType:String = state.itemEventType;
			const allowDesel:Boolean = state.allowDesel;
			const multiSelect:Boolean = state.multiSelect;

			const iList:MovieClip = lpf.iList;
			const bgTabs:MovieClip = lpf.bgTabs;
			const listMask:MovieClip = lpf.listMask;
			const scr:Object = lpf.scr;

			const lpfElementListItemItemCls:Class = pocket.game.world.getClass("LPFElementListItemItem");

			while (iList.numChildren > 0) {
				MovieClip(iList.getChildAt(0)).fClose();
			}

			if (reset) {
				iList.y = bgTabs.height - 1;
			}

			if (tSel == null) {
				state.setMessage("No Tab Selected");

				scr.fOpen({
					"subject": iList,
					"subjectMask": listMask,
					"reset": reset
				});

				return {
					listA: listA
				};
			}

			state.setMessage("");

			if (tSel.filter != "*") {
				for each (itemData in itemList) {
					var matchesFilter:Boolean = filterMap[tSel.filter].indexOf(itemData.sType) > -1 || itemData.sType == "Enhancement" && itemData.sES.indexOf(tSel.filter) > -1;

					var isExcludedPot:Boolean =
						tSel.filter == "pots" &&
						itemData.sLink != "potion" &&
						itemData.sLink != "elixir" &&
						itemData.sLink != "tonic" &&
						itemData.sLink != "scroll";

					if (matchesFilter && !isExcludedPot) {
						filteredItems.push(itemData);
					}
				}
			} else {
				filteredItems = itemList;
			}

			if (onDemand && filteredItems.length == 0) {
				state.setMessage("No items of this type");

				scr.fOpen({
					"subject": iList,
					"subjectMask": listMask,
					"reset": reset
				});

				return {listA: listA};
			}

			for (i = 0; i < sortOrder.length; i++) {
				sortedGroup = [];

				for each (itemData in filteredItems) {
					if (itemData.sType == sortOrder[i]) {
						sortedGroup.push(itemData);
					}
				}

				if (sortedGroup.length > 0) {
					sortedGroup.sortOn(["sName", "iLvl"], [undefined, Array.DESCENDING | Array.NUMERIC]);
					listA = listA.concat(sortedGroup);
				}
			}

			sortedGroup = [];

			for each (itemData in filteredItems) {
				if (listA.indexOf(itemData) == -1) {
					sortedGroup.push(itemData);
				}
			}

			if (sortedGroup.length > 0) {
				sortedGroup.sortOn(["sType", "sName"]);
				listA = listA.concat(sortedGroup);
			}

			var itemConfig:Object = {};
			itemConfig.eventType = itemEventType;
			itemConfig.allowDesel = allowDesel;
			itemConfig.multiSelect = multiSelect;
			itemConfig.bLimited = bLimited && state.getLayout().sMode == "shopBuy";

			var needPagination:Boolean = false;
			
			const listLength:int = listA.length;

			for (i = 0; i < listLength; i++) {
				if (i > 100) {
					needPagination = true;
					break;
				}

				addListItem(iList, lpf, lpfElementListItemItemCls, itemConfig, listA, iSel, i);
			}

			if (needPagination) {
				const pagination:DisplayObject = DisplayObject(iList.addChild(new Pagination()));

				pagination.y = iList.height - 5;

				pagination.addEventListener(MouseEvent.CLICK, function (e:MouseEvent):void {
					const buttonY:int = pagination.y;

					iList.removeChild(pagination);

					var ii:int = 0;

					for (var j:int = i; j < listLength; j++) {
						if (ii > 100) {
							break;
						}

						addListItem(iList, lpf, lpfElementListItemItemCls, itemConfig, listA, iSel, j);

						ii++;
					}

					i += ii;

					if (i < listLength) {
						iList.addChild(pagination);
						pagination.y = iList.height - 5;
					}

					const hRun:int = scr.b.height - scr.h.height;
					const dRun:int = iList.height - listMask.height + 20;

					const targetY:Number = Math.max(iList.oy - dRun, iList.oy - buttonY);

					iList.y = targetY;
					scr.h.y = hRun > 0 ? -(targetY - iList.oy) * hRun / dRun : 0;

					scr.fOpen({
						"subject": iList,
						"subjectMask": listMask,
						"reset": false
					});
				});
			}

			scr.fOpen({
				"subject": iList,
				"subjectMask": listMask,
				"reset": reset
			});

			return {
				listA: listA
			};
		}

		private function addListItem(iList:Object, lpf:Object, cls:Class, itemConfig:Object, listA:Array, iSel:Object, key:int):void {
			itemConfig.fData = listA[key];

			const listItem:Object = iList.addChild(new cls());

			listItem.subscribeTo(lpf);
			listItem.fOpen(itemConfig);

			if (listItem.fData == iSel) {
				listItem.select();
			}

			if (key != 0) {
				listItem.y = iList.height;
			}
		}

	}
}