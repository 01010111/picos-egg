package particles;

import zero.flixel.ec.ParticleEmitter.FireOptions;
import zero.flixel.ec.ParticleEmitter.Particle;

class Decal extends Particle {
	
	public function new() {
		super();
		loadGraphic(Images.decals__png, true, 32, 32);
		this.make_and_center_hitbox(0, 0);
	}

	override function fire(options:FireOptions) {
		super.fire(options);
		animation.frameIndex = options.util_int;
	}

}