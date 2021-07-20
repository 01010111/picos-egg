package util;

import objects.Actor;

class GameUtils {
	
	public static function player_turn() {
		var players = FlxTags.get_objects('player', true);
		for (player in players) (cast player:Actor).available = true;
		(cast players[0]:Actor).turn = true;
	}

	public static function enemy_turn() {
		var players = FlxTags.get_objects('player', true);
		for (player in players) (cast player:Actor).available = false;
	}

}