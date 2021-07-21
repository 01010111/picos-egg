package objects;

import util.MapUtils;
import util.Dolly;
import flixel.FlxObject;
import ui.Selection;
import zero.utilities.Timer;
import util.Constants.ACTOR_SPEED;
import zero.utilities.Vec2;
import objects.GameObject.GameObjectOptions;

class Actor extends GameObject {
	
	var options:ActorOptions;
	public var turn(default, set):Bool;
	public var held:Pickup;
	public var available(default, set):Bool;

	var available_move:Float = 0;
	var available_attack:Bool = true;
	var available_special:Bool = true;
	var target:FlxObject;

	function set_turn(v) {
		immovable = !v;
		target = null;
		velocity.set();
		Dolly.i.reset_targets();
		Dolly.i.add_target(this);
		Selection.i.hide();
		MapUtils.i.object_heatmap((held != null ? 'player' : 'weapon'));
		if (!this.has_tag('player')) begin_ai();
		available_move = options.move_amt;
		return turn = v;
	}

	function set_available(v) {
		if (v) available_move = options.move_amt;
		available_attack = available_special = v;
		return available = v;
	}

	public function new(x:Float, y:Float, options:ActorOptions) {
		if (!options.tags.contains('actor')) options.tags.push('actor');
		super(x, y, options);
		this.options = options;
		loadGraphic(Images.actors__png, true, 32, 32);
		var ao = options.spriteset * 9;
		animation.add('idle', [for (i in 0...64) (i - 61).max(0).floor() + ao], 30.get_random(20).floor());
		animation.add('walk', [3 + ao, 3 + ao, 4 + ao, 5 + ao, 6 + ao, 6 + ao, 7 + ao, 8 + ao], 24);
		setSize(9, 9);
		offset.set(12, 20);
		turn = false;
	}

	override function update(elapsed:Float) {
		if (available_move > 0) update_available_move();
		super.update(elapsed);
		animations();
		hold();
		if (this.has_tag('player') && turn) player_controls();
		else if (turn) move();
	}

	function animations() {
		if (velocity.vector_length() == 0) animation.play('idle');
		else animation.play('walk');
	}

	function hold() {
		if (held == null) return;
		held.x = x + 4.5 + (held.scale.x.sign_of() < 0 ? -6.5 : 6.5);
		held.y = y + 2;
	}

	function player_controls() {
		player_movement();
		player_actions();
	}
	
	function player_movement() {
		velocity.set();
		if (available_move <= 0) return;
		var v = Vec2.get(0, 0);
		if (FlxG.keys.pressed.W) v.y -= 1;
		if (FlxG.keys.pressed.S) v.y += 1;
		if (FlxG.keys.pressed.A) v.x -= 1;
		if (FlxG.keys.pressed.D) v.x += 1;
		if (v.length > 0) v.length = ACTOR_SPEED;
		velocity.set(v.x, v.y);
		v.put();	
	}

	function player_actions() {
		aim();
		if (FlxG.mouse.justPressed) fire_held();
		if (FlxG.mouse.justPressedRight) throw_held();
		if (FlxG.keys.justPressed.TAB) switch_character();
		if (FlxG.keys.justPressed.SPACE) end_phase();
	}

	function aim() {
		if (held == null) return;
		var mp = FlxG.mouse.getPositionInCameraView(FlxG.camera).to_vector(true);
		
		// rotate held
		var tp = getMidpoint().to_vector(true);
		var diff = mp - tp;
		held.rotation = diff.angle;

		// find targets
		var targets = FlxTags.get_objects('gameobject', true);
		var nearest = targets[0];
		var get_distance = (t:FlxObject) -> {
			var v = Vec2.get(t.x + t.width/2, t.y + t.height/2);
			var out = mp.distance(v);
			v.put();
			return out;
		}
		var distance = get_distance(nearest);

		for (target in targets) {
			var temp_d = get_distance(target);
			if (temp_d < distance) {
				nearest = target;
				distance = temp_d;
			}
		}

		if (distance <= AIM_THRESHOLD && nearest != this && nearest != held) {
			target = nearest;
			Selection.i.show(target.x + target.width/2, target.y + target.height/2);
		}
		else {
			target = null;
			Selection.i.hide();
		}

		// recycle!
		mp.put();
		tp.put();
		diff.put();
	}
	
	function fire_held() {
		if (held == null) return;
	}
	
	function throw_held() {
		if (held == null) return;
		var v = target == null ? 
			Vec2.get(FlxG.mouse.getPositionInCameraView().x, FlxG.mouse.getPositionInCameraView().y) :
			Vec2.get(target.x + target.width/2, target.y + target.height/2);
		var p = Vec2.get(x + width/2, y + height/2);
		var d = v - p;
		d.length = THROW_SPEED;

		held.state = FLYING;
		held.velocity.set(d.x, d.y);
		held = null;

		v.put();
		p.put();
		d.put();
	}

	function switch_character() {
		var players = FlxTags.get_objects('actor', true);
		if (players.length < 2) return;
		var idx = players.indexOf(this);
		var next:Actor = cast players[++idx % players.length];
		Timer.get(0.01, () -> {
			turn = false;
			next.turn = true;
		});
	}

	function end_phase() {
		
	}

	function update_available_move() {
		var v = Vec2.get(x - last.x, y - last.y);
		available_move -= v.length/TILESIZE;
		v.put();
	}

	public function pick_up_collide(pickup:Pickup) {
		var is_player = this.has_tag('player');
		switch pickup.state {
			case FREE: get_pickup(pickup);
			case FLYING: is_player ? get_pickup(pickup) : pickup_hit(pickup);
			case HELD:return;
		}
	}
	
	function get_pickup(p:Pickup) {
		// set velocity, set state, set last_held
		if (held != null) return;
		var is_player = this.has_tag('player');
		p.velocity.set();
		p.state = HELD;
		p.last_held = is_player ? PLAYER : ENEMY;
		if (!is_player) MapUtils.i.object_heatmap('player');
		held = p;
	}

	function pickup_hit(p:Pickup) {
		FlxObject.separate(this, p);
		hurt(p.data.power);
	}

	function begin_ai() {
		
	}

	function move() {
		velocity.set();
		if (available_move <= 0) return;
		if (held != null && find_players()) {
			trace('found player');
			available_move = 0;
			return;
		}
		var t = MapUtils.i.get_heatmap_pos(x + width/2, y + height/2, ASCENDING);
		var p = Vec2.get(x + width/2, y + height/2);
		var d = t - p;
		d.length = ACTOR_SPEED;
		velocity.set(d.x, d.y);
		t.put();
		p.put();
		d.put();
	}

	function find_players() {
		var players = 'player'.get_objects(true);
		for (player in players) {
			var p1 = getMidpoint().to_vector(true);
			var p2 = player.getMidpoint().to_vector(true);
			trace(p1, p2, p1.distance(p2), MapUtils.i.can_see(p1.x, p1.y, p2.x, p2.y));
			if (
				(held == null || p1.distance(p2) < held.data.max_range/2) &&
				MapUtils.i.can_see(p1.x, p1.y, p2.x, p2.y)
			) return true;
			p1.put();
			p2.put();
		}
		return false;
	}

}

typedef ActorOptions = {
	> GameObjectOptions,
	spriteset:Int,
	move_amt:Float,
	health:Float,
}