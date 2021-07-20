package objects;

import zero.flixel.utilities.FlxTags;
import util.MapUtils;
import flixel.FlxSprite;

class GameObject extends FlxSprite {
	
	public var sy(get, never):Float;
	function get_sy() return y + height/2;

	public function new(x:Float, y:Float, options:GameObjectOptions) {
		super(x, y);
		if (options.solid) MapUtils.i.set_passable(x, y, true);
		if (options.solid && !options.tags.contains('solid')) options.tags.push('solid');
		if (!options.tags.contains('gameobject')) options.tags.push('gameobject');
		this.add_tags(options.tags);
		PLAYSTATE.overlap.add(this);
		PLAYSTATE.objects.add(this);
	}

	override function kill() {
		if (this.has_tag('solid')) MapUtils.i.set_passable(x, y, true);
		super.kill();
	}

}

typedef GameObjectOptions = {
	solid:Bool,
	tags:Array<String>,
}