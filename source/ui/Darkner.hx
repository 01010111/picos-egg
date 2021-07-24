package ui;

import flixel.FlxSprite;

class Darkner extends FlxSprite {
	
	public function new() {
		super();
		makeGraphic(1,1,0xFF000000);
		origin.set(0, 0);
		scale.set(FlxG.width, FlxG.height);
		alpha = 0;
		scrollFactor.set();
		flash.listen('darken');
	}

	function flash(?_:Dynamic) {
		alpha = _;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		alpha += (0 - alpha) * 0.05;
	}

}