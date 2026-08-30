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

	import flash.utils.ByteArray;

	public class SWFStripper {

		public static function process(originalBytes:ByteArray, stripAnimation:Boolean, stripFilters:Boolean):ByteArray {
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