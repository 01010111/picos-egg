package particles;

import zero.flixel.ec.ParticleEmitter.FireOptions;
import zero.flixel.ec.components.KillAfterTimer;
import zero.flixel.ec.ParticleEmitter.Particle;

class Impact extends Particle {

	var timer:KillAfterTimer;

	public function new() {
		super();
		loadGraphic(Images.impact__png);
		add_component(timer = new KillAfterTimer());
		this.make_and_center_hitbox(0, 0);
	}

	override function fire(options:FireOptions) {
		super.fire(options);
		timer.reset(0.25);
	}

}