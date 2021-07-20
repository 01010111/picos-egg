package objects;

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

	function set_turn(v) {
		immovable = !v;
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
	}

	function animations() {
		if (velocity.vector_length() == 0) animation.play('idle');
		else animation.play('walk');
	}

	function hold() {
		if (held == null) return;
		held.x = x + 4;
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
		var tp = getMidpoint().to_vector(true);
		var d = mp - tp;
		held.rotation = d.angle;
		mp.put();
		tp.put();
		d.put();
	}
	
	function fire_held() {
		if (held == null) return;
	}
	
	function throw_held() {
		if (held == null) return;
	}

	function switch_character() {
		var players = FlxTags.get_objects('player', true);
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

	public function pick_up(pickup:Pickup) {
		trace('picking up');
		if (held != null || pickup.state != FREE) return;
		held = pickup;
		pickup.state = HELD;
	}

}

typedef ActorOptions = {
	> GameObjectOptions,
	spriteset:Int,
	playable:Bool,
	move_amt:Float,
	health:Float,
}