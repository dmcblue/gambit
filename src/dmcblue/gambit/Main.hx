package dmcblue.gambit;

class Main 
{
	static function main() 
	{
		var board = Board.newGame();
		var moves = board.getMoves({x: 0, y: 2});
		trace(moves);
	}
}
