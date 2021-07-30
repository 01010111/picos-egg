package objects;

class Pickup extends GameObject {

	public var state(default, set):PickupState;
	public var rotation(never, set):Float;
	public var last_held:LastHeld = NONE;
	public var data:PickupData;
	public var is_egg:Bool;
	public var last_parent:Actor;
	
	var angle_target:Float = 0;
	
	public function new(x:Float, y:Float, data:PickupData) {
		super(0, 0, {
			solid: false,
			tags: ['pickup', data.type.string().toLowerCase()],
			health: 999
		});
		loadGraphic(Images.pickups__png, true, 32, 32);
		animation.frameIndex = data.sprite;
		//this.make_and_center_hitbox(4, 4);
		this.data = data;
		is_egg = data.sprite == 0;
		this.add_body({
			shape: {
				type: CIRCLE,
				radius: 2
			},
			x: x + 2,
			y: y + 2,
		});
		this.add_to_group(PLAYSTATE.pickups);
		this.add_to_group(PLAYSTATE.gameobjects);
		body.elasticity = 0.85;
		state = FREE;
		body.drag.set(PICKUP_DRAG, PICKUP_DRAG);
	}

	override function get_my():Float {
		if (state == HELD) return y + height/2 + 5.1;
		return y + height/2;
	}

	function set_rotation(v:Float) {
		scale.x = v.get_relative_degree() > 90 && v.get_relative_degree() < 270 ? -1 : 1;
		angle_target = v.get_relative_degree() > 90 && v.get_relative_degree() < 270 ? v + 180 : v;
		return v;
	}

	function set_state(s:PickupState) {
		trace('pickup state', s);
		switch s {
			case FREE://body.drag.set(PICKUP_DRAG, PICKUP_DRAG);
			case FLYING://body.drag.set(0, 0);
			case HELD:
		}
		return state = s;
	}

	var non_rotatables:Array<Int> = [0,1,2,7];

	override function update(elapsed:Float) {
		super.update(elapsed);
		if (non_rotatables.contains(data.sprite)) angle_target = 0;
		switch state {
			case FREE:
				body.rotation += vel.x/10;
			case FLYING: 
				if (wasTouching > 0) state = FREE;
				body.rotation += vel.x/10;
			case HELD:
				angle_target = angle_target.translate_to_nearest_angle(angle);
				body.rotation += (angle_target - body.rotation) * 0.25;
		}
		offset.x += (0 - offset.x) * 0.1;
	}

	public function fire() {
		offset.x = 5;
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