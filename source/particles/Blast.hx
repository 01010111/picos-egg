package particles;

import zero.flixel.ec.ParticleEmitter.FireOptions;
import zero.flixel.ec.components.KillAfterAnimation;
import zero.flixel.ec.ParticleEmitter.Particle;

class Blast extends Particle {
	
	public function new() {
		super();
		loadGraphic(Images.blast__png, true, 60, 60);
		this.make_and_center_hitbox(0, 0);
		add_component(new KillAfterAnimation());
		animation.add('play', [0,1,2,3,4,4,5,5,6,6,7,7,8,9,10,11,12,13,14,15], 24, false);
	}

	override function fire(options:FireOptions) {
		super.fire(options);
		animation.play('play');
		'darken'.dispatch(0.4);
	}

}