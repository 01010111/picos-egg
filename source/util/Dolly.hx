package util;

import flixel.FlxObject;

class Dolly extends FlxObject {

	public static var i:Dolly;

	var targets:Array<FlxObject> = [];

	public function new(x, y) {
		i = this;
		super(x, y, 0, 0);
		FlxG.camera.follow(this);
	}

	public function reset_targets() targets = [];
	public function add_target(t:FlxObject) targets.push(t);
	public function remove_target(t:FlxObject) targets.remove(t);

	override function update(elapsed:Float) {
		super.update(elapsed);
		var shift = FlxG.keys.pressed.SHIFT;
		var mp = FlxG.mouse.getWorldPosition().to_vector(true);
		var xx = shift ? mp.x : 0;
		var yy = shift ? mp.y : 0;
		mp.put();
		for (target in targets) {
			if (target == null) {
				trace(targets.length);
				continue;
			}
			xx += target.x;
			yy += target.y;
		}
		xx /= targets.length + (shift ? 1 : 0);
		yy /= targets.length + (shift ? 1 : 0);
		x += (xx - x) * 0.1;
		y += (yy - y) * 0.1;
	}

}