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
import dmcblue.gambit.Display.StartChoice;

interface DisplayAsync {

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
	public function getAiLevel(callback:Level->Void):Void;

	/**
		Retreives a game id to join
	**/
	public function getGameId(callback:UuidV4->Void):Void;

	/**
		Retreive type of game to play
	**/
	public function getGameStart(callback:StartChoice->Void):Void;

	/**
		Retrieves whether the player wants to go first or second
	**/
	public function getTeamChoice(callback:Piece->Void):Void;

	/**
		Display the invite
	**/
	public function invite(gameId:String):Void;

	/**
		Retrieves whether player wants to play another round
	**/
	public function playAgain(callback:Bool->Void):Void;

	/**
		Gets the move continuing a multistage jump
	**/
	public function requestFollowUpMove(currentPlayer:Piece, position:Position, moves:Array<Position>, callback:Move->Void):Void;

	/**
		Asks user for their move for a round
	**/
	public function requestNextMoveFrom(currentPlayer:Piece, positions:Array<Position>, callback:Position->Void):Void;
	/**
		Asks user for their move for a round
	**/
	public function requestNextMoveTo(currentPlayer:Piece, moves:Array<Position>, callback:Position->Void):Void;

	/**
		Display the current game state
	**/
	public function showBoard(currentPlayer:Piece, isMe:Bool, gameState:GameState, board:Array<Array<Piece>>):Void;

	/**
		Describes the last move made
	**/
	public function showLastMove(movedPlayer:Piece, move:MoveObject):Void;
}
