package util;

import objects.Actor.ActorData;

enum abstract Actor(Int) {
	var PICO = 0;
	var DARNELL = 1;
	var NENE = 2;
	var CASSANDRA = 3;
	var BOYFRIEND = 4;
	var UNKNOWN_1 = 5;
	var UNKNOWN_2 = 6;
	var UNKNOWN_3 = 7;
	var UNKNOWN_4 = 8;
	var UNKNOWN_5 = 9;
	var UNKNOWN_6 = 10;
	var UNKNOWN_7 = 11;
	var UNKNOWN_8 = 12;
	var UNKNOWN_9 = 13;
	var TANKMAN1 = 14;
	var TANKMAN2 = 15;
}

var data:Map<Actor, ActorData> = [
	PICO => {
		solid: true,
		name: 'Pico',
		ap: 16,
		spriteset: cast PICO,
		health: 12,
		tags: ['player']
	},
	DARNELL => {
		solid: true,
		name: 'Darnell',
		ap: 10,
		spriteset: cast DARNELL,
		health: 16,
		tags: ['player']
	},
	NENE => {
		solid: true,
		name: 'Nene',
		ap: 20,
		spriteset: cast NENE,
		health: 8,
		tags: ['player']
	},
	CASSANDRA => {
		solid: true,
		name: 'Cassandra',
		ap: 18,
		spriteset: cast CASSANDRA,
		health: 10,
		tags: ['player']
	},
	BOYFRIEND => {
		solid: true,
		name: 'BF',
		ap: 24,
		spriteset: cast BOYFRIEND,
		health: 32,
		tags: ['player']
	},
	TANKMAN1 => {
		solid: true,
		name: 'Tankman Captain',
		ap: 8,
		spriteset: cast TANKMAN1,
		health: 16,
		tags: ['enemy']
	},
	TANKMAN2 => {
		solid: true,
		name: 'Tankman Steve',
		ap: 12,
		spriteset: cast TANKMAN2,
		health: 12,
		tags: ['enemy']
	},
];

var string_data:Map<String, ActorData> = [
	'PICO' => data[PICO],
	'DARNELL' => data[DARNELL],
	'NENE' => data[NENE],
	'CASSANDRA' => data[CASSANDRA],
	'BOYFRIEND' => data[BOYFRIEND],
	'TANKMAN1' => data[TANKMAN1],
	'TANKMAN2' => data[TANKMAN2],
];