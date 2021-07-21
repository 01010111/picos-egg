package objects;

class Pickup extends GameObject {

	public var state(default, set):PickupState;
	public var rotation(never, set):Float;
	public var last_held:LastHeld = NONE;
	public var data:PickupData;
	
	var angle_target:Float = 0;
	
	public function new(x:Float, y:Float, data:PickupData) {
		super(x, y, { solid: false, tags: ['pickup', data.type.string().toLowerCase()] });
		loadGraphic(Images.pickups__png, true, 32, 32);
		animation.frameIndex = data.sprite;
		this.make_and_center_hitbox(2, 2);
		this.data = data;
		state = FREE;
		elasticity = 0.5;
	}

	override function get_sy():Float {
		if (state == HELD) return y + 5;
		return y + height/2;
	}

	function set_rotation(v:Float) {
		scale.x = v.get_relative_degree() > 90 && v.get_relative_degree() < 270 ? -1 : 1;
		angle_target = v.get_relative_degree() > 90 && v.get_relative_degree() < 270 ? v + 180 : v;
		return v;
	}

	function set_state(s:PickupState) {
		switch s {
			case FREE:drag.set(PICKUP_DRAG, PICKUP_DRAG);
			case FLYING:drag.set();
			case HELD:
		}
		return state = s;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		switch state {
			case FREE:
			case FLYING: 
				if (wasTouching > 0) state = FREE;
				angle += velocity.x < 0 ? -30 : 30;
			case HELD:
				angle_target = angle_target.translate_to_nearest_angle(angle);
				angle += (angle_target - angle) * 0.25;
		}
	}

}

enum PickupState {
	FREE;
	FLYING;
	HELD;
}

enum LastHeld {
	PLAYER;
	ENEMY;
	NONE;
}

enum PickupType {
	THROWABLE;
	WEAPON;
}

typedef PickupData = {
	sprite:Int,
	type:PickupType,
	projectiles:Int,
	power:Float,
	max_range:Float,
	falloff:Float -> Float,
	timing:Float,
	ammo:Int,
}