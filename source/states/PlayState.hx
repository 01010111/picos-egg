package states;

import zero.utilities.Color;
import flixel.group.FlxGroup;
import particles.Decal;
import objects.FireSource;
import zero.utilities.Timer;
import particles.Fire;
import particles.Impact;
import particles.Damage;
import ui.Darkner;
import particles.Shadow;
import particles.Blast;
import zero.flixel.ec.ParticleEmitter;
import flixel.tile.FlxTilemap;
import zero.flixel.utilities.FlxOgmoUtils;
import zero.utilities.OgmoUtils;
import zero.flixel.utilities.FlxOgmoUtils.OgmoPackage;
import objects.Wall;
import util.Dolly;
import ui.Selection;
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

using zero.utilities.OgmoUtils;

class PlayState extends State
{

	public static var instance:PlayState;

	public function new() {
		super();
		instance = this;
	}

	public var overlap:OverlapUtil;
	public var objects:FlxTypedGroup<GameObject> = new FlxTypedGroup();
	public var ogmo:OgmoPackage;

	public var shadows:ParticleEmitter = new ParticleEmitter(() -> new Shadow());
	public var blasts:ParticleEmitter = new ParticleEmitter(() -> new Blast());
	public var damage:ParticleEmitter = new ParticleEmitter(() -> new Damage());
	public var impacts:ParticleEmitter = new ParticleEmitter(() -> new Impact());
	public var fire:ParticleEmitter = new ParticleEmitter(() -> new Fire());
	public var decals:ParticleEmitter = new ParticleEmitter(() -> new Decal());

	public var solids:FlxGroup = new FlxGroup();
	public var pickups:FlxGroup = new FlxGroup();
	public var actors:FlxGroup = new FlxGroup();
	public var walls:FlxGroup = new FlxGroup();
	public var gameobjects:FlxGroup = new FlxGroup();

	override function create() {
		FlxTags.clear_tags();
		GameUtils.init();
		ogmo = FlxOgmoUtils.get_ogmo_package(Data.picos_egg__ogmo, Data.test__json);
		FlxEcho.init({ width: ogmo.level.width, height: ogmo.level.height });
		init_map();
		init_logic();
		init_objects();
		init_ui();
		GameUtils.new_phase();
	}

	function init_map() {
		new MapUtils().init(ogmo.level.get_tile_layer('tiles').data2D, [999]);
	}

	function init_logic() {
		add(overlap = new OverlapUtil());
		FlxEcho.listen(solids, solids, { separate: true });
		FlxEcho.listen(pickups, walls, {
			separate: true,
			enter: (a,b,c) -> {
				var pickup:Pickup = cast a.object;
				if (pickup.state == FLYING) pickup.state = FREE;
				if (pickup.is_egg && pickup.state != HELD) game_over();
			}
		});
		FlxEcho.listen(pickups, actors, {
			separate: true,
			condition: (a,b,c) -> {
				var pickup:Pickup = a.object.is(Pickup) ? cast a.object : cast b.object;
				if (pickup.state == HELD) return false;
				var actor:Actor = b.object.is(Actor) ? cast b.object : cast a.object;
				actor.pick_up_collide(pickup);
				if (pickup.state != FLYING) return false;
				return true;
			},
		});
		return;
		overlap.listen({
			tag1: 'solid',
			tag2: 'solid',
			separate: true
		});
		overlap.listen({
			tag1: 'pickup',
			tag2: 'wall',
			separate: true,
			callback: (p, w) -> if ((cast p:Pickup).is_egg) game_over()
		});
		overlap.listen({
			tag1: 'actor',
			tag2: 'pickup',
			separate: false,
			callback: (a, p) -> (cast a:Actor).pick_up_collide(cast p),
		});
	}

	function init_objects() {
		var tilemap = FlxOgmoUtils.load_tilemap(new FlxTilemap(), ogmo, 'assets/images/');
		tilemap.useScaleHack = false;
		//tilemap.follow();
		add(tilemap);
		add(decals);
		#if debug add(MapUtils.i.debug_tiles); #end
		add(new Dolly(FlxG.width/2, FlxG.height/2));
		add(new Selection());
		add(shadows);
		add(objects);
		Wall.make_walls(ogmo.level.get_grid_layer('walls').grid2D.strings2D_to_ints());
		ogmo.level.get_entity_layer('entities').load_entities(load_entities);
		add(fire);
		add(new Darkner());
		add(damage);
		add(impacts);
		add(blasts);

		FireSource.init(tilemap.widthInTiles, tilemap.heightInTiles);
		Timer.get(0.1, () -> new FireSource(128, 64));
	}

	function load_entities(e:EntityData) {
		switch e.name {
			case 'player', 'enemy': 
				new Actor(e.x, e.y, util.ActorUtils.string_data[e.values.name]);
				if (e.values.held != 'NONE') new Pickup(e.x, e.y, util.PickupUtils.string_data[e.values.held]);
			case 'pickup': new Pickup(e.x, e.y, util.PickupUtils.string_data[e.values.type]);
		}
	}

	function init_ui() {
		UI.removeChildren();
		UI.addChild(new ui.PhaseIndicator());
	}

	override function update(e:Float) {
		super.update(e);
		objects.sort((d, o1, o2) -> o1.my < o2.my ? -1 : 1);
		FlxG.camera.pixelPerfectRender = true;
		FlxG.camera.scroll.x = FlxG.camera.scroll.x.round();
		FlxG.camera.scroll.y = FlxG.camera.scroll.y.round();
	}

	public function game_over() {
		FlxG.resetState();
	}

}