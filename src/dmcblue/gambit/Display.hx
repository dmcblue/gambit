package dmcblue.gambit;

import dmcblue.gambit.Board;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.server.GameState;
import interealmGames.common.errors.Error;
import interealmGames.common.uuid.UuidV4;

enum StartChoice {
	CREATE;
	JOIN;
	RESUME;
}

interface Display {
	public function createJoinResume():StartChoice;

	/**
		Output error to user.
	**/
	public function displayError(error:Error):Void;

	/**
		Shows the results of the game (winner, score, etc)
	**/
	public function endGame(scores:Map<Piece,Int>, board:Array<Array<Piece>>):Void;

	public function getGameId():UuidV4;

	public function getTeamChoice():Piece;

	/**
		Display the invite
	**/
	public function invite(gameId:String):Void;

	/**
		Gets the move continuing a multistage jump
	**/
	public function requestFollowUpMove(currentPlayer:Piece, position:Position, moves:Array<Position>):Move;

	/**
		Asks user for their move for a round
	**/
	public function requestNextMoveFrom(currentPlayer:Piece, positions:Array<Position>):Position;
	/**
		Asks user for their move for a round
	**/
	public function requestNextMoveTo(currentPlayer:Piece, moves:Array<Position>):Position;

	/**
		Display the current game state
	**/
	public function showBoard(currentPlayer:Piece, isMe:Bool, gameState:GameState, board:Array<Array<Piece>>):Void;
}
