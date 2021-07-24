package objects;

import zero.utilities.Timer;
import flixel.group.FlxGroup;
import flixel.FlxObject;

class FireSource extends FlxObject {

	static var map:Array<Array<FireSource>> = [];
	static var mi:Int;
	static var mj:Int;
	static var gameobjects:FlxGroup;
	public static function init(mi:Int, mj:Int) {
		map = [for (j in 0...mj) [ for (i in 0...mi) null ]];
		FireSource.mi = mi;
		FireSource.mj = mj;
	}

	public static function propogate() {
		for (row in map) for (fs in row) {
			if (fs == null || !fs.alive) continue;
			fs.damage();
			Timer.get(0.1, fs.spread);
		}
	}

	var timer:Float = 0;
	var i:Int;
	var j:Int;

	public function new(x:Float, y:Float) {
		var i = (x/TILESIZE).floor();
		var j = (y/TILESIZE).floor();
		super(i * TILESIZE, j * TILESIZE, TILESIZE, TILESIZE);
		this.add_tag('fire');
		map[j][i] = this;
		this.i = i;
		this.j = j;
		FlxG.state.add(this);
		damage();
		trace('fire', x, y);
		PLAYSTATE.decals.fire({ position: getMidpoint(), util_int: 2.get_random().floor()});
	}

	function damage() {		
		gameobjects = new FlxGroup();
		for (o in FlxTags.get_objects('gameobject')) gameobjects.add(o);
		FlxG.overlap(this, gameobjects, (f, o) -> o.hurt(FIRE_DAMAGE));
	}

	function spread() {
		trace('hi');
		if (!alive) return;
		if (check_prop(i, j - 1)) new FireSource(i * TILESIZE, (j - 1) * TILESIZE);
		if (check_prop(i, j + 1)) new FireSource(i * TILESIZE, (j + 1) * TILESIZE);
		if (check_prop(i - 1, j)) new FireSource((i - 1) * TILESIZE, j * TILESIZE);
		if (check_prop(i + 1, j)) new FireSource((i + 1) * TILESIZE, j * TILESIZE);
		if (Math.random() < EXTINGUISH_CHANCE) kill();
	}

	function check_prop(i:Int, j:Int) {
		var in_range = i > 0 && j > 0 && i < mi - 1 && j < mj - 1;
		var exists = map[j][i] != null && map[j][i].exists;
		if (!in_range) return false;
		if (exists) return false;
		return Math.random() < FIRE_CHANCE;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		if ((timer -= elapsed) <= 0) {
			timer = FIRE_TIME.get_random();
			var p = getMidpoint().add(7.5.get_random(-7.5), 7.5.get_random(-7.5));
			PLAYSTATE.fire.fire({ position: p });
			p.put();
		}
	}

}