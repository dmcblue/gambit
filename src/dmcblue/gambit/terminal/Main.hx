package dmcblue.gambit.terminal;

import dmcblue.gambit.Game;
import dmcblue.gambit.Piece;
import dmcblue.gambit.terminal.Display;

class Main 
{
	static function main() 
	{
		var display = new Display();
		var game = new Game(display, Piece.BLACK);
		display.greetings();
		game.run();
	}
}
