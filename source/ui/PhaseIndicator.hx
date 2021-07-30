package ui;

import openfl.text.TextFormatAlign;
import openfl.text.TextFieldAutoSize;
import util.GameUtils.Phase;
import openfl.Lib;
import zero.utilities.Ease;
import zero.utilities.Tween;
import openfl.text.TextFormat;
import zero.utilities.Color;
import openfl.text.TextField;
import openfl.display.Sprite;

class PhaseIndicator extends Sprite {
	
	public static var i:PhaseIndicator;

	var text:TextField;
	var bg:Sprite;

	public function new() {
		i = this;
		super();

		this.set_position(1080/2, 720/2);
		trace(x, y);

		bg = new Sprite();
		bg.fill_rect(Color.BLACK, -720, -64, 720 * 2, 128);
		bg.scaleY = 0;
		addChild(bg);

		text = new TextField()
			.format({
				font: 'Lilita One',
				size: 64,
				color: Color.PICO_8_RED
			})
			.set_string("HELLO WORLD")
			.set_autosize(CENTER)
			.set_position(0, 0, MIDDLE_CENTER);
		addChild(text);

		play(PLAYER);
	}

	public function play(phase:Phase) {
		text.text = '${phase.string()} PHASE';
		var tx = text.set_position(0, 0, MIDDLE_CENTER).x;
		text.set_position(1080, 0, MIDDLE_CENTER);
		rotation = 15.get_random(-15);
		Tween.tween(bg, 0.2, { scaleY: 1 }, { ease: Ease.backOut, on_complete: () -> {
			Tween.tween(text, 0.2, { x: tx }, { ease: Ease.backOut, on_complete: () -> {
				Tween.tween(text, 0.2, { x: -1080 }, { ease: Ease.backIn, delay: 1, on_complete: () -> {
					Tween.tween(bg, 0.2, { scaleY: 0 }, { ease: Ease.backIn });
				}});
			}});
		}});
	}

}