package controller {

	import data.WidgetEntry;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;

	import ui.util.BasicButton;
	import ui.util.Handle;

	import util.Helper;
	import util.HelperSetting;

	public class LayoutController {

		private static const SCALE_STEP:Number = 0.15;
		private static const SCALE_MIN:Number = 0.1;
		private static const SCALE_MAX:Number = 5.0;
		private static const GRID_SIZE:Number = 22;

		public static var editMode:Boolean = false;

		private static var current:WidgetEntry;

		private var widgets:Vector.<WidgetEntry> = new Vector.<WidgetEntry>();
		private var dragOffsetX:Number = 0;
		private var dragOffsetY:Number = 0;

		public function register(id:String, target:Sprite, defaultPositionX:Number, defaultPositionY:Number, defaultScaleX:Number, defaultScaleY:Number):void {
			this.widgets.push(new WidgetEntry(id, target, defaultPositionX, defaultPositionY, defaultScaleX, defaultScaleY));
		}

		public function unregister(id:String):void {
			for (var i:uint = 0; i < this.widgets.length; i++) {
				if (this.widgets[i].id == id) {
					hideHandles(this.widgets[i]);

					this.widgets.removeAt(i);
					return;
				}
			}
		}

		public function load():void {
			var saved:Object;
			var widgetEntry:WidgetEntry;

			for each (widgetEntry in this.widgets) {
				saved = HelperSetting._get(widgetEntry.id);

				widgetEntry.target.x = saved ? saved.x : widgetEntry.defaultPositionX;
				widgetEntry.target.y = saved ? saved.y : widgetEntry.defaultPositionY;

				widgetEntry.target.scaleX = saved ? saved.scaleX : widgetEntry.defaultScaleX;
				widgetEntry.target.scaleY = saved ? saved.scaleY : widgetEntry.defaultScaleY;
			}
		}

		public function toggleEdit(state:Boolean):void {
			editMode = state;

			if (editMode) {
				if (Pocket.SINGLETON.gameUI.getChildByName("LayoutSaveButton") == null) {
					Pocket.SINGLETON.worldCore.setWorldFilters([
						Helper.GRAYSCALE
					]);

					const saveButton:BasicButton = new BasicButton("Save");
					saveButton.name = "LayoutSaveButton";
					saveButton.x = 480 - (saveButton.width >> 1);
					saveButton.y = 10;

					saveButton.addEventListener(MouseEvent.CLICK, Pocket.SINGLETON.gameUI.hideEditLayout, false, 0, true);

					Pocket.SINGLETON.gameUI.addChild(saveButton);
				}
			} else {
				Pocket.SINGLETON.worldCore.setWorldFilters([]);

				const saveButton2:DisplayObject = Pocket.SINGLETON.gameUI.getChildByName("LayoutSaveButton");

				if (saveButton2 != null && saveButton2.parent != null) {
					saveButton2.removeEventListener(MouseEvent.CLICK, Pocket.SINGLETON.gameUI.hideEditLayout);
					saveButton2.parent.removeChild(saveButton2);
				}
			}

			var widgetEntry:WidgetEntry;

			for each (widgetEntry in this.widgets) {
				if (editMode) {
					showHandles(widgetEntry);
					continue;
				}

				hideHandles(widgetEntry);

				HelperSetting._set(widgetEntry.id, {
					x: widgetEntry.target.x,
					y: widgetEntry.target.y,

					scaleX: widgetEntry.target.scaleX,
					scaleY: widgetEntry.target.scaleY
				});
			}
		}

		public function resetToDefaults():void {
			if (editMode) {
				for each (var e:WidgetEntry in this.widgets) {
					hideHandles(e);
				}

				editMode = false;
			}

			var widgetEntry:WidgetEntry;

			for each (widgetEntry in this.widgets) {
				widgetEntry.target.x = widgetEntry.defaultPositionX;
				widgetEntry.target.y = widgetEntry.defaultPositionY;

				widgetEntry.target.scaleX = widgetEntry.defaultScaleX;
				widgetEntry.target.scaleY = widgetEntry.defaultScaleY;

				HelperSetting._delete(widgetEntry.id);
			}
		}

		private function showHandles(widgetEntry:WidgetEntry):void {
			if (widgetEntry.handle != null) {
				return;
			}

			const parent:DisplayObjectContainer = widgetEntry.target.parent;

			const handle:Handle = new Handle();

			handle.x = widgetEntry.target.x;
			handle.y = widgetEntry.target.y;

			parent.addChild(handle);

			handle.drag.addEventListener(MouseEvent.MOUSE_DOWN, onHandleDown, false, 0, true);
			handle.up.addEventListener(MouseEvent.CLICK, onResizeUp, false, 0, true);
			handle.down.addEventListener(MouseEvent.CLICK, onResizeDown, false, 0, true);

			widgetEntry.handle = handle;
		}

		private function repositionHandles(widgetEntry:WidgetEntry):void {
			if (widgetEntry.handle == null) {
				return;
			}

			widgetEntry.handle.x = widgetEntry.target.x;
			widgetEntry.handle.y = widgetEntry.target.y;
		}

		private function hideHandles(widgetEntry:WidgetEntry):void {
			if (!widgetEntry.handle) {
				return;
			}

			widgetEntry.handle.drag.removeEventListener(MouseEvent.MOUSE_DOWN, onHandleDown);
			widgetEntry.handle.up.removeEventListener(MouseEvent.CLICK, onResizeUp);
			widgetEntry.handle.down.removeEventListener(MouseEvent.CLICK, onResizeDown);

			if (widgetEntry.handle.parent) {
				widgetEntry.handle.parent.removeChild(widgetEntry.handle);
			}

			widgetEntry.handle = null;
		}

		private function entryForHandle(button:SimpleButton):WidgetEntry {
			var widgetEntry:WidgetEntry;

			for each (widgetEntry in this.widgets) {
				if (widgetEntry.handle != null && (widgetEntry.handle.drag == button || widgetEntry.handle.up == button || widgetEntry.handle.down == button)) {
					return widgetEntry;
				}
			}

			return null;
		}

		private function onHandleDown(mouseEvent:MouseEvent):void {
			current = entryForHandle(SimpleButton(mouseEvent.currentTarget));

			if (current == null) {
				return;
			}

			const parent:DisplayObjectContainer = current.target.parent;
			const pointer:Point = parent.globalToLocal(new Point(mouseEvent.stageX, mouseEvent.stageY));

			dragOffsetX = pointer.x - current.target.x;
			dragOffsetY = pointer.y - current.target.y;

			current.handle.visible = false;
			current.target.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			current.target.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}

		private function onMouseMove(e:MouseEvent):void {
			if (current == null || current.target.parent == null) {
				return;
			}

			const parent:DisplayObjectContainer = current.target.parent;
			const pointer:Point = parent.globalToLocal(new Point(e.stageX, e.stageY));

			var nextX:Number = pointer.x - dragOffsetX;
			var nextY:Number = pointer.y - dragOffsetY;

			if (isSnapToGridEnabled()) {
				nextX = snap(nextX);
				nextY = snap(nextY);
			}

			current.target.x = nextX;
			current.target.y = nextY;

			e.updateAfterEvent();
		}

		private function onMouseUp(e:MouseEvent):void {
			if (current == null) {
				return;
			}

			current.target.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			current.target.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			if (isSnapToGridEnabled()) {
				current.target.x = snap(current.target.x);
				current.target.y = snap(current.target.y);
			}

			current.handle.visible = true;

			repositionHandles(current);

			current = null;
		}

		private function onResizeUp(e:MouseEvent):void {
			const entry:WidgetEntry = entryForHandle(SimpleButton(e.currentTarget));

			if (entry == null) {
				return;
			}

			const scale:Number = Math.min(SCALE_MAX, entry.target.scaleX + SCALE_STEP);

			entry.target.scaleX = scale;
			entry.target.scaleY = scale;

			repositionHandles(entry);
		}

		private function onResizeDown(e:MouseEvent):void {
			const entry:WidgetEntry = entryForHandle(SimpleButton(e.currentTarget));

			if (entry == null) {
				return;
			}

			const scale:Number = Math.max(SCALE_MIN, entry.target.scaleX - SCALE_STEP);

			entry.target.scaleX = scale;
			entry.target.scaleY = scale;

			repositionHandles(entry);
		}

		private function isSnapToGridEnabled():Boolean {
			return HelperSetting.getBool(HelperSetting.OPTION_SNAP_TO_GRID, true);
		}

		private function snap(value:Number):Number {
			return Math.round(value / GRID_SIZE) * GRID_SIZE;
		}

	}
}
