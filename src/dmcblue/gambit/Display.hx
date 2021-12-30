package dmcblue.gambit;

import dmcblue.gambit.Board;
import dmcblue.gambit.Game;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import interealmGames.common.errors.Error;

interface Display {
	/**
		Output error to user.
	**/
	public function displayError(error:Error):Void;

	/**
		Shows the results of the game (winner, score, etc)
	**/
	public function endGame(scores:Map<Piece,Int>, game:GameMaster):Void;

	/**
		Display the invite
	**/
	public function invite(gameId:String):Void;

	/**
		Gets the move continuing a multistage jump
	**/
	public function requestFollowUpMove(currentPlayer:Piece, position:Position, moves:Array<Position>, game:GameMaster):Move;

	/**
		Asks user for their move for a round
	**/
	public function requestNextMove(currentPlayer:Piece, positions:Array<Position>, game:GameMaster):Null<Move>;

	/**
		Display the current game state
	**/
	public function showBoard(currentPlayer:Piece, board:Array<Array<Piece>>):Void;
}
