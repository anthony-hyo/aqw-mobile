package ui.controller {
	import data.WidgetEntry;

	import flash.display.*;
	import flash.events.*;

	import ui.util.Handle;

	import util.HelperSetting;

	public class LayoutController {

		private static const SCALE_STEP:Number = 0.15;
		private static const SCALE_MIN:Number = 0.1;
		private static const SCALE_MAX:Number = 5.0;

		private var widgets:Vector.<WidgetEntry> = new Vector.<WidgetEntry>();

		private var current:WidgetEntry;

		public var editMode:Boolean = false;

		public function register(id:String, target:Sprite, defaultPositionX:Number, defaultPositionY:Number, defaultScaleX:Number, defaultScaleY:Number):void {
			this.widgets.push(new WidgetEntry(id, target, defaultPositionX, defaultPositionY, defaultScaleX, defaultScaleY));
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
			this.editMode = state;

			var widgetEntry:WidgetEntry;

			for each (widgetEntry in this.widgets) {
				if (this.editMode) {
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
			if (this.editMode) {
				for each (var e:WidgetEntry in this.widgets) {
					hideHandles(e);
				}

				this.editMode = false;
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

			parent.addChild(handle); // null error when hide joystick

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
				widgetEntry.handle.parent.removeChild(widgetEntry.handle)
			}
			
			widgetEntry.handle = null;
		}

		private function entryForHandle(button:SimpleButton):WidgetEntry {
			var widgetEntry:WidgetEntry;

			for each (widgetEntry in this.widgets) {
				if (widgetEntry.handle.drag == button || widgetEntry.handle.up == button || widgetEntry.handle.down == button) {
					return widgetEntry;
				}
			}

			return null;
		}

		private function onHandleDown(mouseEvent:MouseEvent):void {
			this.current = entryForHandle(SimpleButton(mouseEvent.currentTarget));

			if (this.current == null) {
				return;
			}

			this.current.handle.visible = false;

			this.current.target.startDrag(false);
			this.current.target.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}

		private function onMouseUp(e:MouseEvent):void {
			this.current.handle.visible = true;
			
			this.current.target.stopDrag();
			this.current.target.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			repositionHandles(this.current);
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

	}
}