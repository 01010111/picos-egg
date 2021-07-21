package util;

import zero.utilities.Ease;
import objects.Pickup.PickupData;

enum PickupName {
	EGG;
	DODGEBALL;
	GRENADE;
	PISTOL;
	SHOTGUN;
	RIFLE;
	BAT;
}

var data:Map<PickupName, PickupData> = [
	EGG => {
		sprite: 0,
		ammo: 0,
		timing: 0,
		falloff: Ease.linear,
		max_range: 0,
		power: 0,
		projectiles: 0,
		type: THROWABLE,
	},
	DODGEBALL => {
		sprite: 1,
		ammo: 0,
		timing: 0,
		falloff: Ease.linear,
		max_range: 0,
		power: 1,
		projectiles: 0,
		type: THROWABLE,
	},
	GRENADE => {
		sprite: 2,
		ammo: 0,
		timing: 3,
		falloff: Ease.linear,
		max_range: 0,
		power: 12,
		projectiles: 0,
		type: THROWABLE,
	},
	PISTOL => {
		sprite: 3,
		ammo: 16,
		timing: 0,
		falloff: Ease.quadIn,
		max_range: 256,
		power: 4,
		projectiles: 1,
		type: WEAPON
	},
	SHOTGUN => {
		sprite: 4,
		ammo: 8,
		timing: 0,
		falloff: Ease.quadOut,
		max_range: 128,
		power: 2,
		projectiles: 8,
		type: WEAPON
	},
	RIFLE => {
		sprite: 5,
		ammo: 10,
		timing: 0.1,
		falloff: Ease.quintIn,
		max_range: 384,
		power: 3,
		projectiles: 4,
		type: WEAPON
	},
	BAT => {
		sprite: 6,
		ammo: 0,
		timing: 0,
		falloff: Ease.linear,
		max_range: 0,
		power: 4,
		projectiles: 0,
		type: THROWABLE,
	}
];