package particles;

import objects.Wall;
import objects.GameObject;
import zero.flixel.ec.ParticleEmitter.FireOptions;
import zero.flixel.ec.ParticleEmitter.Particle;

class Shadow extends Particle {
	
	var parent:GameObject;

	public function new() {
		super();
		loadGraphic(Images.shadow__png);
		this.make_and_center_hitbox(0, 0);
	}

	override function fire(options:FireOptions) {
		super.fire(options);
		parent = cast options.data.parent;
		if (parent.is(Wall)) {
			loadGraphic(Images.shadow_sq__png);
			this.make_and_center_hitbox(0, 0);
		}
	}

	override function update(dt:Float) {
		super.update(dt);
		x = parent.mx;
		y = parent.my;
		alpha = parent.alive ? 0.5 : 0;
	}

}