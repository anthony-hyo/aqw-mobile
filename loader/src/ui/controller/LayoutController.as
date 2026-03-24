package ui.controller {
	import data.WidgetEntry;

	import ui.*;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;

	import ui.util.Handle;

	import util.HelperSetting;

	public class LayoutController {

		private var widgets:Vector.<WidgetEntry> = new Vector.<WidgetEntry>();

		private var dragging:WidgetEntry;
		private var dragOffX:Number;
		private var dragOffY:Number;

		private var _editMode:Boolean = false;

		public function get editMode():Boolean {
			return _editMode;
		}

		public function register(id:String, target:DisplayObject, defaultX:Number, defaultY:Number):void {
			widgets.push(new WidgetEntry(id, target, defaultX, defaultY));
		}

		public function load():void {
			var saved:Object;

			for each (var e:WidgetEntry in widgets) {
				saved = HelperSetting._get(e.id);

				e.target.x = saved ? saved.x : e.defaultX;
				e.target.y = saved ? saved.y : e.defaultY;
			}
		}

		public function toggleEdit():void {
			_editMode = !_editMode;

			for each (var e:WidgetEntry in widgets) {
				if (_editMode) {
					showHandle(e);
					continue;
				}

				hideHandle(e);

				HelperSetting._set(e.id, {
					x: e.target.x,
					y: e.target.y
				});
			}
		}

		public function resetToDefaults():void {
			if (_editMode) {
				for each (var e:WidgetEntry in widgets) {
					hideHandle(e);
				}

				_editMode = false;
			}

			for each (var entry:WidgetEntry in widgets) {
				entry.target.x = entry.defaultX;
				entry.target.y = entry.defaultY;

				HelperSetting._delete(entry.id);
			}
		}


		private function showHandle(e:WidgetEntry):void {
			if (e.handle != null) {
				return;
			}

			const handle:Handle = new Handle();

			handle.x = e.target.x;
			handle.y = e.target.y;

			handle.buttonMode = true;
			handle.useHandCursor = true;

			e.target.parent.addChild(handle);

			handle.addEventListener(MouseEvent.MOUSE_DOWN, onHandleDown, false, 0, true);

			e.handle = handle;
		}

		private function hideHandle(e:WidgetEntry):void {
			if (e.handle == null) {
				return;
			}

			e.handle.removeEventListener(MouseEvent.MOUSE_DOWN, onHandleDown);

			if (e.handle.parent) {
				e.handle.parent.removeChild(e.handle);
			}

			e.handle = null;
		}

		private function entryForHandle(h:Sprite):WidgetEntry {
			for each (var e:WidgetEntry in widgets) {
				if (e.handle == h) {
					return e;
				}
			}

			return null;
		}

		private function onHandleDown(e:MouseEvent):void {
			const h:Sprite = Sprite(e.currentTarget);

			dragging = entryForHandle(h);

			if (dragging == null) {
				return;
			}

			dragOffX = h.parent.mouseX - dragging.target.x;
			dragOffY = h.parent.mouseY - dragging.target.y;

			h.stage.addEventListener(MouseEvent.MOUSE_MOVE, onDragMove, false, 0, true);
			h.stage.addEventListener(MouseEvent.MOUSE_UP, onDragUp, false, 0, true);

			e.stopImmediatePropagation();
		}

		private function onDragMove(e:MouseEvent):void {
			if (dragging == null) {
				return;
			}

			const pt:Point = dragging.target.parent.globalToLocal(new Point(e.stageX, e.stageY));

			dragging.target.x = pt.x - dragOffX;
			dragging.target.y = pt.y - dragOffY;
			dragging.handle.x = dragging.target.x;
			dragging.handle.y = dragging.target.y;
		}

		private function onDragUp(e:MouseEvent):void {
			if (dragging == null) {
				return;
			}

			dragging.handle.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
			dragging.handle.stage.removeEventListener(MouseEvent.MOUSE_UP, onDragUp);

			dragging = null;
		}

	}
}