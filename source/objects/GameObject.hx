package objects;

import util.MapUtils;
import flixel.FlxSprite;

class GameObject extends FlxSprite {
	
	public var mx(get, set):Float;
	function get_mx() return x + width/2;
	function set_mx(v:Float) {
		x = v - width/2;
		return v;
	}

	public var my(get, set):Float;
	function get_my() return y + height/2;
	function set_my(v:Float) {
		y = v - height/2;
		return v;
	}

	public function new(x:Float, y:Float, data:GameObjectData) {
		super(x, y);
		if (data.solid) set_passable(false);
		if (data.solid && !data.tags.contains('solid')) data.tags.push('solid');
		if (!data.tags.contains('gameobject')) data.tags.push('gameobject');
		this.add_tags(data.tags);
		PLAYSTATE.overlap.add(this);
		PLAYSTATE.objects.add(this);
		health = data.health;
		PLAYSTATE.shadows.fire({ position: getMidpoint(), data: {parent:this} });
	}
	
	override function hurt(Damage:Float) {
		var p = getMidpoint().add(15.get_random(-15), 5.get_random(-20));
		PLAYSTATE.damage.fire({
			position: p,
			util_int: Damage.clamp(0, 16).floor()
		});
		PLAYSTATE.impacts.fire({position:p});
		p.put();
		if (Damage <= 0) return;
		super.hurt(Damage);
	}

	override function kill() {
		if (this.has_tag('solid')) set_passable(true);
		PLAYSTATE.blasts.fire({ position: getMidpoint() });
		super.kill();
	}

	function set_passable(pass:Bool) {
		MapUtils.i.set_passable(mx, my, pass);
	}

}

typedef GameObjectData = {
	solid:Bool,
	tags:Array<String>,
	health:Int,
}