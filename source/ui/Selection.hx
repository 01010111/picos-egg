package ui;

import flixel.FlxSprite;

class Selection extends FlxSprite {
	
	public static var i:Selection;

	public function new() {
		i = this;
		super();
		loadGraphic(Images.selection__png, true, 30, 30);
		animation.add('play', [0,0,1,2,3,3,2,1], 15);
		animation.play('play');
		this.make_and_center_hitbox(0, 0);
		hide();
	}

	public function show(x:Float, y:Float) {
		visible = true;
		setPosition(x, y);
	}

	public function hide() {
		visible = false;
	}

}