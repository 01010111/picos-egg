package objects;

class Pickup extends GameObject {

	public var state:PickupState;
	public var rotation(never, set):Float;
	var data:PickupData;
	var tag:String;

	public function new(x:Float, y:Float, data:PickupData) {
		super(x, y, { solid: false, tags: ['pickup'] });
		loadGraphic(Images.pickups__png, true, 32, 32);
		animation.frameIndex = data.sprite;
		this.make_and_center_hitbox(2, 2);
		this.data = data;
		state = FREE;
	}

	override function get_sy():Float {
		if (state == HELD) return y + 5;
		return y + height/2;
	}

	function set_rotation(v:Float) {
		scale.x = v.get_relative_degree() > 90 && v.get_relative_degree() < 270 ? -1 : 1;
		angle = v.get_relative_degree() > 90 && v.get_relative_degree() < 270 ? v + 180 : v;
		return v;
	}

}

enum PickupState {
	FREE;
	FLYING;
	HELD;
}

typedef PickupData = {
	sprite:Int,
	projectiles:Int,
	power:Float,
	max_range:Float,
	falloff:Float -> Float,
	timing:Float,
	ammo:Int,
}