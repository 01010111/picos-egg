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
		var xx = shift ? FlxG.mouse.x - FlxG.camera.scroll.x : 0;
		var yy = shift ? FlxG.mouse.y - FlxG.camera.scroll.y : 0;
		for (target in targets) {
			xx += target.x;
			yy += target.y;
		}
		xx /= targets.length + (shift ? 1 : 0);
		yy /= targets.length + (shift ? 1 : 0);
		x += (xx - x) * 0.2;
		y += (yy - y) * 0.2;
	}

}