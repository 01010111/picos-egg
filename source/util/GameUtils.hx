package util;

import zero.utilities.Timer;
import objects.FireSource;
import flixel.FlxObject;
import objects.Actor;

class GameUtils {

	static var phases:Array<Phase>;
	public static var phase:Phase;
	public static var active:Array<FlxObject> = [];

	public static function init() {
		phases = [PLAYER, ENEMY];
		Actor.current = null;
	}

	public static function switch_character() {
		var next:Actor = cast GameUtils.active.shift();
		GameUtils.active.push(next);
		if (next.has_gone && GameUtils.phase == ENEMY) {
			trace('already gone!');
			GameUtils.new_phase();
			return;
		}
		Timer.get(0.01, () -> {
			if (Actor.current != null) Actor.current.turn = false;
			next.turn = true;
		});
	}

	public static function new_phase() {
		phase = phases.shift();
		phases.push(phase);
		trace(phase, 'phase');
		var actors = FlxTags.get_objects(phase.string().toLowerCase(), true);
		active = actors;
		for (actor in FlxTags.get_objects('actor')) (cast actor:Actor).available = false;
		for (actor in actors) (cast actor:Actor).available = true;
		switch_character();
		trace([for (actor in actors) (cast actor:Actor).data.name]);
		FireSource.propogate();
	}

	public static function check_active() {
		var available = false;
		for (actor in active) if (actor.alive) available = true;
		if (!available) new_phase();
		else if (!Actor.current.alive) switch_character();
	}

}

enum Phase {
	PLAYER;
	ENEMY;
}