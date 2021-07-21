package util;

import zero.utilities.IntPoint;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import zero.utilities.Vec2;

using zero.utilities.AStar;

class MapUtils {

	public static var i:MapUtils;

	var object_map:Map<Int, Vec2> = [];
	var map:Array<Array<Int>>;

	public var debug_tiles:FlxGroup;
	public var heatmap:Array<Array<Int>> = [];

	public function new() {
		i = this;
	}

	public function init(array:Array<Array<Int>>, solids:Array<Int>) {
		map = [];
		for (row in array) {
			var r = [];
			map.push(r);
			heatmap.push([]);
			for (value in row) {
				r.push(solids.contains(value) ? 1 : 0);
				heatmap.last().push(0);
			}
		}
		for (i in 0...9) map[i][8] = 1;
		for (i in 2...9) map[8][i] = 1;
		#if debug
		make_debug_tiles();
		#end
		draw_debug();
	}

	function make_debug_tiles() {
		debug_tiles = new FlxGroup();
		for (j in 0...map.length) for (i in 0...map[j].length) {
			var tile = new FlxSprite(i * TILESIZE, j * TILESIZE);
			tile.makeGraphic(TILESIZE, TILESIZE, 0x00FFFFFF);
			tile.drawRect(4, 4, TILESIZE - 8, TILESIZE - 8);
			tile.alpha = 0.5;
			debug_tiles.add(tile);
		}
	}

	function draw_debug() {
		#if debug
		for (j in 0...heatmap.length) for (i in 0...heatmap[j].length) {
			var tile = debug_tiles.members[j * heatmap[j].length + i];
			(cast tile:FlxSprite).color = FlxColor.interpolate(0xFFFF004D, 0xFF001060, heatmap[j][i].map(0, 32, 0, 1));
		}
		#end
	}

	public function set_passable(x:Float, y:Float, passable:Bool) {
		var xx = (x/TILESIZE).floor();
		var yy = (y/TILESIZE).floor();
		var o = passable ? -1 : 1;
		map[yy][xx] = (map[yy][xx] + o).max(0).floor();
	}

	public function find_path(start_x:Float, start_y:Float, end_x:Float, end_y:Float) {
		var sx = (start_x/TILESIZE).floor();
		var sy = (start_y/TILESIZE).floor();
		var ex = (start_x/TILESIZE).floor();
		var ey = (start_y/TILESIZE).floor();
		var int_path = AStar.get_path(map, { start: [sx, sy], end: [ex, ey], passable: [0] });
		var path = [for (p in int_path) Vec2.get(p.x * TILESIZE, p.y * TILESIZE)];
		path[0].set(start_x, start_y);
		path.last().set(end_x, end_y);
	}

	public function line_of_sight(x1:Int, y1:Int, x2:Int, y2:Int) {
		return AStar.los([x1, y1], [x2, y2], map, [0]);
	}

	public function can_see(sx:Float, sy:Float, ex:Float, ey:Float) {
		var out = line_of_sight(
			(sx/TILESIZE).floor(),
			(sy/TILESIZE).floor(),
			(ex/TILESIZE).floor(),
			(ey/TILESIZE).floor()
		);
		return out;
	}

	public function object_heatmap(filter:String) {
		heatmap.fill(-1);
		for (j in 0...map.length) for (i in 0...map[j].length) {
			if (map[j][i] > 0) heatmap[j][i] = 999;
		}
		var objects = FlxTags.get_objects(filter, true);
		var points:Array<IntPoint> = [for (object in objects) [(object.x/TILESIZE).floor(), (object.y/TILESIZE).floor()]];
		var i = 0;
		var check = (x, y) -> {
			if (y < 0 || y >= map.length || x < 0 || x >= map[0].length) return;
			if (map[y][x] > 0) return;
			if (heatmap[y][x] >= 0) return;
			var p = IntPoint.get(x, y);
			for (pt in points) if (p.equals(pt)) {
				p.put();
				return;
			}
			points.push(p);
		}
		while (points.length > 0) {
			var queue = [];
			while (points.length > 0) queue.push(points.shift());
			while (queue.length > 0) {
				var p = queue.shift();
				heatmap[p.y][p.x] = i;
				check(p.x, p.y - 1);
				check(p.x, p.y + 1);
				check(p.x - 1, p.y);
				check(p.x + 1, p.y);
				p.put();
			}
			i++;
		}
		#if debug draw_debug(); #end
	}

	public function get_heatmap_pos(x:Float, y:Float, d:Direction) {
		var i = (x/TILESIZE).floor();
		var j = (y/TILESIZE).floor();
		var dirs = [
			[j, i],
			[j - 1, i],
			[j + 1, i],
			[j, i - 1],
			[j, i + 1],
		];
		dirs.sort((a,b) -> heatmap[a[0]][a[1]] < heatmap[b[0]][b[1]] ? -1 : 1);
		var res = switch d {
			case ASCENDING: dirs.shift();
			case DESCENDING: dirs.pop();
		}
		return Vec2.get(res[1] * TILESIZE + (TILESIZE/2).floor(), res[0] * TILESIZE + (TILESIZE/2).floor());
	}

}

enum Direction {
	ASCENDING;
	DESCENDING;
}