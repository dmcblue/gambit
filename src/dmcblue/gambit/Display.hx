package dmcblue.gambit;

import dmcblue.gambit.Board;
import dmcblue.gambit.Game;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import interealmGames.common.errors.Error;

interface Display {
	// greeting, start
	public function displayError(error:Error):Void;
	public function endGame(scores:Map<Piece,Int>, board:Board):Void;
	public function playAgain():Bool;
	public function requestFollowUpMove(currentPlayer:Piece, position:Position, moves:Array<Position>, game:GameMaster):Move;
	public function requestNextMove(currentPlayer:Piece, positions:Array<Position>, game:GameMaster):Move;
}
