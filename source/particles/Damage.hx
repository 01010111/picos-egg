package particles;

import zero.utilities.Timer;
import zero.flixel.ec.ParticleEmitter.FireOptions;
import zero.flixel.ec.ParticleEmitter.Particle;

class Damage extends Particle {
	
	public function new() {
		super();
		loadGraphic(Images.damage__png, true, 17, 8);
		this.make_anchored_hitbox(0, 0);
		offset.y = 12;
		drag.set(500, 500);
	}

	override function fire(options:FireOptions) {
		super.fire(options);
		animation.frameIndex = options.util_int;
		velocity.y = -100;
		Timer.get(1, () -> this.flicker(0.5, 0.04, true, true, (_) -> kill()));
	}

}