package ui.controller {

	import data.WidgetEntry;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	import ui.util.Handle;

	import util.HelperSetting;

	public class LayoutController {

		private static const SCALE_STEP:Number = 0.15;
		private static const SCALE_MIN:Number = 0.1;
		private static const SCALE_MAX:Number = 5.0;
		private static const GRID_SIZE:Number = 22;
		private static const GRID_MAJOR_INTERVAL:int = 3;
		private static const GRID_COLOR:uint = 0xFFFFFF;
		private static const GRID_MINOR_ALPHA:Number = 0.05;
		private static const GRID_MAJOR_ALPHA:Number = 0.18;

		public static var editMode:Boolean = false;

		private static var current:WidgetEntry;

		private var widgets:Vector.<WidgetEntry> = new Vector.<WidgetEntry>();
		private var gridLayers:Dictionary = new Dictionary(true);
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

			repositionAllHandles();
		}

		public function exportLayouts():Object {
			const layouts:Object = {};

			var widgetEntry:WidgetEntry;

			for each (widgetEntry in this.widgets) {
				layouts[widgetEntry.id] = {
					x: widgetEntry.target.x,
					y: widgetEntry.target.y,

					scaleX: widgetEntry.target.scaleX,
					scaleY: widgetEntry.target.scaleY
				};
			}

			return layouts;
		}

		public function importLayouts(layouts:Object):void {
			if (layouts == null) {
				return;
			}

			var id:String;
			var saved:Object;

			for (id in layouts) {
				saved = layouts[id];

				if (!isValidLayout(saved)) {
					continue;
				}

				HelperSetting._set(id, {
					x: Number(saved.x),
					y: Number(saved.y),

					scaleX: Number(saved.scaleX),
					scaleY: Number(saved.scaleY)
				});
			}

			load();
		}

		public function toggleEdit(state:Boolean):void {
			editMode = state;

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

			if (!editMode) {
				hideGrids();
			}
		}

		public function refreshGrid():void {
			hideGrids();

			if (!editMode || !isSnapToGridEnabled()) {
				return;
			}

			for each (var widgetEntry:WidgetEntry in this.widgets) {
				if (widgetEntry.target.parent) {
					showGrid(widgetEntry.target.parent);
				}
			}
		}

		public function resetToDefaults():void {
			if (editMode) {
				for each (var e:WidgetEntry in this.widgets) {
					hideHandles(e);
				}

				editMode = false;
				hideGrids();
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

			if (isSnapToGridEnabled()) {
				showGrid(parent);
			}

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

		private function repositionAllHandles():void {
			for each (var widgetEntry:WidgetEntry in this.widgets) {
				repositionHandles(widgetEntry);
			}
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

		private function showGrid(parent:DisplayObjectContainer):void {
			if (parent == null || parent.stage == null || gridLayers[parent] != null) {
				return;
			}

			const grid:Sprite = new Sprite();
			grid.name = "LayoutGrid";
			grid.mouseEnabled = false;
			grid.mouseChildren = false;

			drawGrid(grid, parent);

			parent.addChildAt(grid, 0);
			gridLayers[parent] = grid;
		}

		private function drawGrid(grid:Sprite, parent:DisplayObjectContainer):void {
			const topLeft:Point = parent.globalToLocal(new Point(0, 0));
			const bottomRight:Point = parent.globalToLocal(new Point(parent.stage.stageWidth, parent.stage.stageHeight));

			const left:Number = Math.min(topLeft.x, bottomRight.x);
			const right:Number = Math.max(topLeft.x, bottomRight.x);
			const top:Number = Math.min(topLeft.y, bottomRight.y);
			const bottom:Number = Math.max(topLeft.y, bottomRight.y);

			const graphics:Graphics = grid.graphics;
			graphics.clear();

			var x:Number;
			var y:Number;
			var index:int;
			var major:Boolean;

			for (x = Math.floor(left / GRID_SIZE) * GRID_SIZE; x <= right; x += GRID_SIZE) {
				index = Math.round(x / GRID_SIZE);
				major = index % GRID_MAJOR_INTERVAL == 0;
				graphics.lineStyle(1, GRID_COLOR, major ? GRID_MAJOR_ALPHA : GRID_MINOR_ALPHA);
				graphics.moveTo(x, top);
				graphics.lineTo(x, bottom);
			}

			for (y = Math.floor(top / GRID_SIZE) * GRID_SIZE; y <= bottom; y += GRID_SIZE) {
				index = Math.round(y / GRID_SIZE);
				major = index % GRID_MAJOR_INTERVAL == 0;
				graphics.lineStyle(1, GRID_COLOR, major ? GRID_MAJOR_ALPHA : GRID_MINOR_ALPHA);
				graphics.moveTo(left, y);
				graphics.lineTo(right, y);
			}
		}

		private function hideGrids():void {
			var key:Object;
			var grid:Sprite;

			for (key in gridLayers) {
				grid = Sprite(gridLayers[key]);

				if (grid != null && grid.parent != null) {
					grid.parent.removeChild(grid);
				}

				delete gridLayers[key];
			}
		}

		private function isSnapToGridEnabled():Boolean {
			return HelperSetting.getBool(HelperSetting.OPTION_SNAP_TO_GRID, true);
		}

		private function snap(value:Number):Number {
			return Math.round(value / GRID_SIZE) * GRID_SIZE;
		}

		private function isValidLayout(layout:Object):Boolean {
			if (layout == null) {
				return false;
			}

			return isFinite(Number(layout.x)) &&
				isFinite(Number(layout.y)) &&
				isFinite(Number(layout.scaleX)) &&
				isFinite(Number(layout.scaleY));
		}

	}
}
