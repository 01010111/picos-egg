package states;

import zero.flixel.utilities.OverlapUtil;
import util.PickupUtils.data;
import objects.Pickup;
import util.MapUtils;
import util.GameUtils;
import objects.Actor;
import objects.GameObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import zero.flixel.states.State;
import util.PickupUtils.PickupName;

class PlayState extends State
{

	public static var instance:PlayState;

	public function new() {
		super();
		instance = this;
	}

	public var overlap:OverlapUtil;
	public var objects:FlxTypedGroup<GameObject> = new FlxTypedGroup();

	override function create() {
		init_map();
		init_logic();
		init_objects();
		GameUtils.player_turn();
	}

	function init_map() {
		bgColor = 0xFF808080;
		new MapUtils().init([for (y in 0...512) [ for (x in 0...512) 0 ]],[1]);
	}

	function init_logic() {
		add(overlap = new OverlapUtil());
		overlap.listen({
			tag1: 'solid',
			tag2: 'solid',
			separate: true
		});
		overlap.listen({
			tag1: 'actor',
			tag2: 'pickup',
			separate: false,
			callback: (a, p) -> (cast a:Actor).pick_up(cast p),
		});
	}

	function init_objects() {
		add(objects);
		new Actor(32, 32, {solid: true,playable: true,tags: ['player'], health: 10, move_amt: 32, spriteset: 5.get_random().floor()});
		new Actor(64, 64, {solid: true,playable: true,tags: ['player'], health: 10, move_amt: 32, spriteset: 5.get_random().floor()});
		new Pickup(128, 128, data[SHOTGUN]);
	}

	override function update(e:Float) {
		super.update(e);
		objects.sort((d, o1, o2) -> o1.sy < o2.sy ? -1 : 1);
	}

}