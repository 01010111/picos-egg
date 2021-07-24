package objects;

import util.GameUtils;
import zero.utilities.Ease;
import flixel.FlxSprite;
import util.MapUtils;
import util.Dolly;
import flixel.FlxObject;
import ui.Selection;
import zero.utilities.Timer;
import util.Constants.ACTOR_SPEED;
import zero.utilities.Vec2;
import objects.GameObject.GameObjectData;

class Actor extends GameObject {

	public static var current:Actor;
	
	public var data:ActorData;
	public var turn(default, set):Bool;
	public var held(default, set):Pickup;
	public var available(default, set):Bool;
	public var has_gone:Bool;

	var ap:Float = 0;
	var available_attack:Bool = true;
	var available_special:Bool = true;
	var target(default, set):GameObject;
	var wait:Bool = false;
	var ai_state(default, set):AIState;

	function set_turn(v:Bool) {
		set_passable(v);
		if (v) {
			trace('turn:', data.name);
			current = this;
			'turn'.dispatch();
			has_gone = true;
		}
		immovable = !v;
		wait = !v;
		target = null;
		velocity.set();
		Dolly.i.reset_targets();
		Dolly.i.add_target(this);
		Selection.i.hide();
		if (!this.has_tag('player')) begin_ai();
		if (v) trace([for (a in GameUtils.active) (cast a:Actor).has_gone]);
		return turn = v;
	}

	function set_available(v) {
		if (v) ap = data.ap;
		available_attack = available_special = v;
		has_gone = false;
		return available = v;
	}

	function set_held(v) {
		return held = v;
	}

	function set_ai_state(v:AIState) {
		trace('ai', v);
		velocity.set();
		switch v {
			case CHASE:
				MapUtils.i.object_heatmap('player');
			case ESCAPE:
				target = null;
				MapUtils.i.object_heatmap('player');
			case GET_WEAPON:
				target = null;
				MapUtils.i.object_heatmap('weapon');
			case WAIT:
			case ATTACK:
		}
		return ai_state = v;
	}

	function set_target(v:GameObject) {
		if (target == v) return v;
		if (v == null) {

		}
		else {
			trace('target', v.is(Actor) ? (cast v:Actor).data.name : v.get_tags(), v.health, held == null ? 0 : get_chance(v));
		}
		return target = v;
	}

	public function new(x:Float, y:Float, data:ActorData) {
		if (!data.tags.contains('actor')) data.tags.push('actor');
		super(x, y, data);
		this.data = data;
		loadGraphic(Images.actors__png, true, 32, 32);
		var ao = data.spriteset * 9;
		animation.add('idle', [for (i in 0...64) (i - 61).max(0).floor() + ao], 30.get_random(20).floor());
		animation.add('walk', [3 + ao, 3 + ao, 4 + ao, 5 + ao, 6 + ao, 6 + ao, 7 + ao, 8 + ao], 24);
		setSize(9, 9);
		offset.set(12, 20);
		turn = false;
	}

	override function update(elapsed:Float) {
		if (ap > 0) update_ap();
		animations();
		hold();
		if (this.has_tag('player') && turn) player_controls();
		else if (turn) ai();
		super.update(elapsed);
	}

	function animations() {
		if (velocity.vector_length() == 0) animation.play('idle');
		else animation.play('walk');
	}

	function hold() {
		if (held == null) return;
		held.mx = mx + (held.scale.x.sign_of() < 0 ? -6.5 : 6.5);
		held.my = my - 2;
	}

	function player_controls() {
		player_movement();
		player_actions();
	}
	
	function player_movement() {
		velocity.set();
		if (wait) return;
		if (ap <= 0) return;
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
		if (wait) return;
		aim();
		if (FlxG.mouse.justPressed) fire_held();
		if (FlxG.mouse.justPressedRight) throw_held();
		if (FlxG.keys.justPressed.TAB) GameUtils.switch_character();
		if (FlxG.keys.justPressed.SPACE) GameUtils.new_phase();
	}

	function aim() {
		if (held == null) return;
		var mp = FlxG.mouse.getWorldPosition().to_vector(true);
		
		// rotate held
		var tp = getMidpoint().to_vector(true);
		var diff = mp - tp;
		held.rotation = diff.angle;

		// find targets
		var targets = FlxTags.get_objects('gameobject', true);
		for (target in targets) if (target.is(Pickup)) targets.remove(target);
		var nearest:GameObject = cast targets[0];
		var get_distance = (t:GameObject) -> {
			var v = Vec2.get(t.mx, t.my);
			var out = mp.distance(v);
			v.put();
			return out;
		}
		var distance = get_distance(cast nearest);

		for (target in targets) {
			var temp_d = get_distance(cast target);
			if (temp_d < distance) {
				nearest = cast target;
				distance = temp_d;
			}
		}

		if (distance <= AIM_THRESHOLD && nearest != this && nearest != held) {
			target = nearest;
			Selection.i.show(target.mx, target.my);
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
		if (ap <= 0) return false;
		if (held == null) return false;
		if (held.data.ammo <= 0) return false;
		if (target == null) return false;
		if (!MapUtils.i.can_see(mx, my, target.mx, target.my)) return false;
		wait = true;
		ap--;
		held.data.ammo--;
		trace('ap', ap, 'ammo', held.data.ammo);
		Timer.get(held.data.timing, () -> {
			held.fire();
		}, held.data.projectiles);
		var chance = get_chance(target);
		Timer.get(held.data.projectiles * held.data.timing + 0.2, () -> {
			if (target == null) return;
			Dolly.i.reset_targets();
			Dolly.i.add_target(target);
			for (i in 0...held.data.projectiles) {
				if (target == null || !target.alive) break;
				Timer.get(i * 0.1, () -> target.hurt(Math.random() > chance ? 0 : held.data.power));
			}
			Timer.get(0.25 + 0.1 * held.data.projectiles, () -> {
				wait = false;
				if (GameUtils.phase == ENEMY) {
					GameUtils.switch_character();
					return;
				}
				Dolly.i.reset_targets();
				Dolly.i.add_target(this);
			});
		});
		return true;
		//(cast target:FlxSprite).scale.set(0.5, 0.5);
	}

	function get_chance(target:FlxObject) {
		if (target == null) return 0.0;
		var p1 = getMidpoint().to_vector(true);
		var p2 = target.getMidpoint().to_vector(true);
		if (!MapUtils.i.can_see(p1.x, p1.y, p2.x, p2.y)) return 0;
		var chance = held.data.falloff(p1.distance(p2)/held.data.max_range).map(0, 1, 1, 0.1);
		p1.put();
		p2.put();
		return chance;
	}
	
	function throw_held() {
		if (held == null) return;
		Selection.i.hide();
		ap--;
		var v = target == null ? 
			Vec2.get(FlxG.mouse.getPositionInCameraView().x, FlxG.mouse.getPositionInCameraView().y) :
			Vec2.get(target.mx, target.my);
		var p = Vec2.get(mx, my);
		var d = v - p;
		d.length = THROW_SPEED;

		held.state = FLYING;
		held.reset(mx, my);
		held.velocity.set(d.x, d.y);
		held = null;

		v.put();
		p.put();
		d.put();
	}

	function update_ap() {
		var v = Vec2.get(x - last.x, y - last.y);
		ap -= v.length/TILESIZE;
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
		if (p.state == FLYING && p.last_parent == this) return;
		var is_player = this.has_tag('player');
		p.velocity.set();
		p.state = HELD;
		p.last_parent = this;
		p.last_held = is_player ? PLAYER : ENEMY;
		if (!is_player) ai_state = CHASE;
		held = p;
	}

	function pickup_hit(p:Pickup) {
		FlxObject.separate(this, p);
		hurt(p.data.power);
	}

	function begin_ai() {
		if (held == null) {
			if ('weapon'.get_objects(true).length == 0) ai_state = ESCAPE;
			else ai_state = GET_WEAPON;
		}
		else ai_state = CHASE;
	}

	var cant_move:Bool;
	var cant_attack:Bool;

	function ai() {
		switch ai_state {
			case CHASE:
				ai_move();
				find_players();
			case ESCAPE: ai_move();
			case GET_WEAPON: ai_move();
			case WAIT:
			case ATTACK: attempt_shot();
		}
		aim_at_target();
	}

	function ai_move() {
		velocity.set();
		if (ap <= 0) {
			trace('out of AP, attacking');	
			ai_state = ATTACK;
		}
		var t = MapUtils.i.get_heatmap_pos(mx, my, (ai_state == ESCAPE ? DESCENDING : ASCENDING));
		if (t == null) {
			ai_state = ATTACK;
			return;
		}
		var p = Vec2.get(mx, my);
		var d = t - p;
		d.length = ACTOR_SPEED;
		velocity.set(d.x, d.y);
		t.put();
		p.put();
		d.put();
	}

	function find_players() {
		if (held == null) {
			begin_ai();
			return;
		}
		var players = 'player'.get_objects(true);
		trace('players found:', players.length);
		players.sort((p1, p2) -> {
			var p1p = p1.getMidpoint().to_vector(true);
			var p2p = p2.getMidpoint().to_vector(true);
			var myp = getMidpoint().to_vector(true);
			var d1 = myp.distance(p1p);
			var d2 = myp.distance(p2p);
			p1p.put();
			p2p.put();
			myp.put();
			return d1 < d2 ? -1 : 1;
		});
		for (player in players) {
			var p1 = getMidpoint().to_vector(true);
			var p2 = player.getMidpoint().to_vector(true);
			var in_range = p1.distance(p2) < held.data.max_range/2;
			var can_see = MapUtils.i.can_see(p1.x, p1.y, p2.x, p2.y);
			if (can_see) target = cast player;
			if (in_range && can_see) {
				trace('player in range: ', (cast player:Actor).data.name, 'attacking...');
				ai_state = ATTACK;
			}
			p1.put();
			p2.put();
		}
	}

	function attempt_shot() {
		trace('attempting shot');
		if (target == null) {
			ai_state = WAIT;
			GameUtils.switch_character();
			return;
		}
		var p1 = getMidpoint().to_vector(true);
		var p2 = target.getMidpoint().to_vector(true);
		var in_range = p1.distance(p2) < held.data.max_range;
		p1.put();
		p2.put();
		if (!in_range) {
			ai_state = WAIT;
			GameUtils.switch_character();
			return;
		}
		ai_state = WAIT;
		Timer.get(0.5, () -> if(!fire_held()) {
			Timer.get(1, GameUtils.switch_character);
		});
	}

	function aim_at_target() {
		if (held == null) return;
		var aim_target = 0.0;
		if (target != null) {
			var p1 = getMidpoint().to_vector(true);
			var p2 = target.getMidpoint().to_vector(true);
			var d = p2 - p1;
			aim_target = d.angle;
			p1.put();
			p2.put();
			d.put();
		}
		held.rotation = aim_target;
	}

	override function hurt(Damage:Float) {
		if (Damage > 0) PLAYSTATE.decals.fire({ position: getMidpoint().add(15.get_random(-15), 12.get_random(-12)), util_int: 7.get_random(2).floor()});
		if (held != null && held.is_egg) return PLAYSTATE.game_over(); 
		super.hurt(Damage);
	}

	override function kill() {
		if (held != null) {
			var d = Vec2.get(DEAD_TOSS_SPEED);
			d.angle = 360.get_random();
			held.state = FREE;
			held.velocity.set(d.x, d.y);
			held = null;
			d.put();
		}
		super.kill();
		GameUtils.check_active();
	}

}

typedef ActorData = {
	> GameObjectData,
	spriteset:Int,
	ap:Float,
	name:String,
}

enum AIState {
	CHASE;
	ESCAPE;
	GET_WEAPON;
	WAIT;
	ATTACK;
}