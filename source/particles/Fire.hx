package particles;

import zero.flixel.ec.ParticleEmitter.FireOptions;
import zero.flixel.ec.components.KillAfterAnimation;
import zero.flixel.ec.ParticleEmitter.Particle;

class Fire extends Particle {
	
	public function new() {
		super();
		loadGraphic(Images.fire__png, true, 64, 64);
		animation.add('play0', [0,1,2,3,4,5,6,7], 30.get_random(20).floor(), false);
		animation.add('play1', [9,10,11,12,13,14,15], 30.get_random(20).floor(), false);
		add_component(new KillAfterAnimation());
		this.make_and_center_hitbox(0, 0);
		blend = ADD;
	}

	override function fire(options:FireOptions) {
		super.fire(options);
		animation.play('play' + (Math.random() > 0.5 ? 1 : 0));
		var s = 2.5.get_random(0.5);
		scale.set(s * (Math.random() > 0.5 ? -1 : 1), s);
	}

}