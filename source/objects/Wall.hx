package objects;

import zero.utilities.IntPoint;

class Wall extends GameObject {

	static var map:Array<Array<Int>>;
	static var walls:Array<Array<Wall>>;
	
	public static function make_walls(map:Array<Array<Int>>) {
		Wall.map = map;
		walls = [ for (j in 0...map.length) [ for (i in 0...map[j].length) null ] ];
		var out:Array<Wall> = [];
		for (j in 0...map.length) for (i in 0...map[j].length) {
			if (map[j][i] == 0) continue;
			walls[j][i] = new Wall(i * TILESIZE, j * TILESIZE, j, i);
		}
		set_walls();
	}

	public static function set_walls() {
		for (j in 0...map.length) for (i in 0...map[j].length) {
			if (map[j][i] == 0) continue;
			var id = 0;
			if (j > 0					&& map[j - 1][i] == 1) id += 1;
			if (j < map.length - 1		&& map[j + 1][i] == 1) id += 2;
			if (i > 0					&& map[j][i - 1] == 1) id += 4;
			if (i < map[j].length - 1	&& map[j][i + 1] == 1) id += 8;
			walls[j][i].animation.frameIndex = id;
		}
	}

	var id:IntPoint;

	public function new(x:Float, y:Float, j:Int, i:Int) {
		x = x.snap_to_grid(TILESIZE);
		y = y.snap_to_grid(TILESIZE);
		id = [i,j];
		var data = {
			solid: true,
			tags: ['wall'],
			health: 25,
		};
		if (i == 0 || j == 0 || i == map[0].length - 1 || j == map.length - 1) data.health = 9999;
		super(0,0, data);
		loadGraphic(Images.walls__png, true, 17, 27);
		//this.make_anchored_hitbox(15, 15);
		offset.set(0, 5);
		this.add_body({
			shape: {
				type: RECT,
				width: 15,
				height: 15
			},
			x: x + 7.5,
			y: y + 7.5,
			mass: 0,
		});
		set_solid_info(data);
		immovable = true;
		this.add_to_group(PLAYSTATE.solids);
		this.add_to_group(PLAYSTATE.walls);
		this.add_to_group(PLAYSTATE.gameobjects);
	}

	override function kill() {
		map[id.y][id.x] = 0;
		walls[id.y][id.x] = null;
		set_walls();
		super.kill();
	}

}