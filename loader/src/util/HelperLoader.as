package util {

	import com.codeazur.as3swf.SWF;
	import com.codeazur.as3swf.tags.ITag;
	import com.codeazur.as3swf.tags.TagDefineSprite;
	import com.codeazur.as3swf.tags.TagEnd;
	import com.codeazur.as3swf.tags.TagFrameLabel;
	import com.codeazur.as3swf.tags.TagPlaceObject;
	import com.codeazur.as3swf.tags.TagRemoveObject;
	import com.codeazur.as3swf.tags.TagRemoveObject2;
	import com.codeazur.as3swf.tags.TagShowFrame;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;

	public class HelperLoader {

		public static var COUNT:uint = 0;

		private static const CATEGORY_MAP:Array = [
			{
				pattern: "mon/", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_MONSTER_OFF;
				}
			},
			{
				pattern: "hairs", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_HAIR_OFF;
				}
			},
			{
				pattern: "classes", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_ARMOR_OFF;
				}
			},
			{
				pattern: "helms", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_HELM_OFF;
				}
			},
			{
				pattern: "capes", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_CAPE_OFF;
				}
			},
			{
				pattern: "grounds", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_MISC_OFF;
				}
			},
			{
				pattern: "pets", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_PET_OFF;
				}
			},
			{
				pattern: "map", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_MAP_OFF;
				}
			},
			{
				pattern: "items", check: function ():Boolean {
					return Pocket.IS_GRAPHIC_ANIMATION_WEAPON_OFF;
				}
			}
		];

		public static function load(ldr:Loader, url:String, context:LoaderContext, onComplete:Function = null, onProgress:Function = null, onError:Function = null, onHTTPError:Function = null):void {
			prepareContext(context);

			url = Helper.trimUrl(url);

			loadBinary(url,
				function (bytes:ByteArray):void {
					var finalBytes:ByteArray = bytes;

					const categoryCheck:Function = resolveCategoryCheck(url);

					const animationOn:Boolean = categoryCheck != null && categoryCheck();
					const filterOn:Boolean = categoryCheck != null && Pocket.IS_GRAPHIC_FILTER_OFF;

					if (animationOn || filterOn) {
						finalBytes = processSWFBytes(bytes, animationOn, filterOn);
					}

					if (onComplete != null) {
						ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
					}

					if (onHTTPError != null) {
						ldr.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPError);
					}

					ldr.loadBytes(finalBytes, context);
				},
				onProgress,
				function (e:IOErrorEvent):void {
					if (onError != null) {
						onError(e);
						return;
					}

					ldr.dispatchEvent(e);
				}
			);
		}

		private static function resolveCategoryCheck(url:String):Function {
			const lowerUrl:String = url.toLowerCase();

			var entry:Object;

			for each (entry in CATEGORY_MAP) {
				if (lowerUrl.indexOf(entry.pattern) > -1) {
					return entry.check as Function;
				}
			}

			return null;
		}

		private static function loadBinary(url:String, onBytes:Function, onProgress:Function = null, onError:Function = null):void {
			const urlLoader:URLLoader = new URLLoader();

			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;

			urlLoader.addEventListener(Event.COMPLETE, function (e:Event):void {
				onBytes(URLLoader(e.target).data as ByteArray);
			});

			if (onProgress != null) {
				urlLoader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			}

			if (onError != null) {
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			}

			urlLoader.load(new URLRequest(url));
		}

		private static function prepareContext(ctx:LoaderContext):void {
			ctx.checkPolicyFile = false;
			ctx.allowCodeImport = true;
		}

		public static function progressPercent(e:ProgressEvent):int {
			return int((e.currentTarget.bytesLoaded / e.currentTarget.bytesTotal) * 100);
		}

		private static function processSWFBytes(originalBytes:ByteArray, stripAnimation:Boolean, stripFilters:Boolean):ByteArray {
			originalBytes.position = 0;

			const swf:SWF = new SWF(originalBytes);

			stripTags(swf.tags, stripAnimation, stripFilters);

			if (swf.tagsRaw && swf.tagsRaw.length > swf.tags.length) {
				swf.tagsRaw.length = swf.tags.length;
			}

			const newBytes:ByteArray = new ByteArray();
			swf.publish(newBytes);
			newBytes.position = 0;

			return newBytes;
		}

		private static function stripTags(tags:Vector.<ITag>, stripAnimation:Boolean, stripFilters:Boolean):void {
			var tag:ITag;

			var hasFrameLabels:Boolean = false;

			if (stripAnimation) {
				for each (tag in tags) {
					if (tag is TagFrameLabel) {
						hasFrameLabels = true;
						break;
					}
				}
			}

			var shownFirstFrame:Boolean = false;
			const newTags:Vector.<ITag> = hasFrameLabels ? new Vector.<ITag>() : null;

			for (var i:int = 0; i < tags.length; i++) {
				tag = tags[i];

				if (stripAnimation && !hasFrameLabels && tag is TagShowFrame) {
					tags.length = i + 1;
					tags.push(new TagEnd());
					break;
				}

				if (tag is TagDefineSprite) {
					var sprite:TagDefineSprite = tag as TagDefineSprite;

					stripTags(sprite.tags, stripAnimation, stripFilters);

					if (sprite.tagsRaw && sprite.tagsRaw.length > sprite.tags.length) {
						sprite.tagsRaw.length = sprite.tags.length;
					}
				} else if (stripFilters && tag is TagPlaceObject) {
					var po:TagPlaceObject = tag as TagPlaceObject;

					if (po.hasFilterList && po.surfaceFilterList != null && po.surfaceFilterList.length > 0) {
						po.surfaceFilterList.length = 0;
						po.hasFilterList = false;
					}
				}

				if (hasFrameLabels) {
					var isFrameContent:Boolean = (tag is TagPlaceObject) || (tag is TagRemoveObject) || (tag is TagRemoveObject2);

					if (stripAnimation && shownFirstFrame && isFrameContent) {
						// stripped
					} else {
						newTags.push(tag);
					}

					if (tag is TagShowFrame) {
						shownFirstFrame = true;
					}
				}
			}

			if (hasFrameLabels) {
				tags.length = 0;
				for each (tag in newTags) {
					tags.push(tag);
				}
			}
		}

	}
}