package util;

import zero.utilities.Vec2;

using zero.utilities.AStar;

class MapUtils {

	public static var i:MapUtils;

	var object_map:Map<Int, Vec2> = [];
	var map:Array<Array<Int>>;

	public function new() {
		i = this;
	}

	public function init(array:Array<Array<Int>>, solids:Array<Int>) {
		map = [];
		for (row in array) {
			var r = [];
			map.push(r);
			for (value in row) r.push(solids.contains(value) ? 1 : 0);
		}
	}

	public function set_passable(x:Float, y:Float, passable:Bool) {
		var xx = x.map(0, TILESIZE, 0, 1).round();
		var yy = y.map(0, TILESIZE, 0, 1).round();
		var o = passable ? -1 : 1;
		map[yy][xx] = (map[yy][xx] + o).max(0).round();
	}

	public function find_path(start_x:Float, start_y:Float, end_x:Float, end_y:Float) {
		var sx = start_x.map(0, TILESIZE, 0, 1).round();
		var sy = start_y.map(0, TILESIZE, 0, 1).round();
		var ex = start_x.map(0, TILESIZE, 0, 1).round();
		var ey = start_y.map(0, TILESIZE, 0, 1).round();
		var int_path = AStar.get_path(map, { start: [sx, sy], end: [ex, ey], passable: [0] });
		var path = [for (p in int_path) Vec2.get(p.x * TILESIZE, p.y * TILESIZE)];
		path[0].set(start_x, start_y);
		path.last().set(end_x, end_y);
	}

	public function line_of_sight(x1:Int, y1:Int, x2:Int, y2:Int) {
		return AStar.los([x1, y1], [x2, y2], map, [0]);
	}

	public function can_see(sx:Float, sy:Float, ex:Float, ey:Float) {
		return line_of_sight(
			sx.map(0, TILESIZE, 0, 1).round(),
			sy.map(0, TILESIZE, 0, 1).round(),
			ex.map(0, TILESIZE, 0, 1).round(),
			ey.map(0, TILESIZE, 0, 1).round()
		);
	}

}