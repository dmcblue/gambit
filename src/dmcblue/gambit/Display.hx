package dmcblue.gambit;

import dmcblue.gambit.Board;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.ai.Level;
import dmcblue.gambit.server.GameState;
import dmcblue.gambit.server.parameters.MoveParams.MoveObject;
import interealmGames.common.errors.Error;
import interealmGames.common.uuid.UuidV4;

enum StartChoice {
	AI;
	CREATE;
	JOIN;
	RESUME;
}

interface Display {

	/**
		Output error to user.
	**/
	public function displayError(error:Error):Void;

	/**
		Output error to user.
	**/
	public function displayGameId(gameId:UuidV4):Void;

	/**
		Shows the results of the game (winner, score, etc)
	**/
	public function endGame(scores:Map<Piece,Int>, board:Array<Array<Piece>>):Void;

	/**
		Signals the UI that the program will exit
	**/
	public function exit():Void;

	/**
		Retrieve difficulty level
	**/
	public function getAiLevel():Level;

	/**
		Retreives a game id to join
	**/
	public function getGameId():UuidV4;

	/**
		Retreive type of game to play
	**/
	public function getGameStart():StartChoice;

	/**
		Retrieves whether the player wants to go first or second
	**/
	public function getTeamChoice():Piece;

	/**
		Display the invite
	**/
	public function invite(gameId:String):Void;

	/**
		Retrieves whether player wants to play another round
	**/
	public function playAgain():Bool;

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

	/**
		Describes the last move made
	**/
	public function showLastMove(movedPlayer:Piece, move:MoveObject):Void;
}
