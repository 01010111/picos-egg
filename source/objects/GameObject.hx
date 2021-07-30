package objects;

import zero.utilities.Timer;
import hxmath.math.Vector2;
import echo.Body;
import util.MapUtils;
import flixel.FlxSprite;

class GameObject extends FlxSprite {
	
	public var mx(get, set):Float;
	function get_mx() return body.x;
	function set_mx(v:Float) {
		body.x = v;
		return v;
	}

	public var my(get, set):Float;
	function get_my() return body.y;
	function set_my(v:Float) {
		body.y = v;
		return v;
	}

	public var body(get,never):Body;
	function get_body() return FlxEcho.get_body(this);

	public var vel(get,never):Vector2;
	function get_vel() return body.velocity;

	public function new(x:Float, y:Float, data:GameObjectData) {
		super(x, y);
		if (!data.tags.contains('gameobject')) data.tags.push('gameobject');
		this.add_tags(data.tags);
		PLAYSTATE.overlap.add(this);
		PLAYSTATE.objects.add(this);
		health = data.health;
		PLAYSTATE.shadows.fire({ position: getMidpoint(), data: {parent:this} });
	}

	function set_solid_info(data:GameObjectData) {
		if (data.solid) set_passable(false);
		if (data.solid && !data.tags.contains('solid')) data.tags.push('solid');
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
		if (!alive) return;
		body.active = false;
		if (this.has_tag('solid')) set_passable(true);
		Timer.get(1, () -> body.set_position(-128, -128));
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