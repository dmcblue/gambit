package dmcblue.gambit.terminal;

import haxe.io.Eof;
import dmcblue.gambit.Display.StartChoice;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.PieceTools;
import dmcblue.gambit.Display in DisplayInterface;
import interealmGames.common.errors.Error;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.ai.Level;
import dmcblue.gambit.server.GameState;
import interealmGames.common.uuid.Uuid;
import interealmGames.common.uuid.UuidV4;
import dmcblue.gambit.error.EndGameInterrupt;
import dmcblue.gambit.server.parameters.MoveParams.MoveObject;

typedef LevelChoice = {
	choice:Int,
	label:String,
	level:Level
};

@:buildXml("
    <target id='haxe'>
		<lib name='-lpanel' if='linux'/>
		<lib name='-lmenu' if='linux'/>
		<lib name='-lncurses' if='linux'/>
       <lib name='ncurses.lib' if='windows'/>
    </target>
")
@:cppFileCode("
%CPP%
")
class Display implements DisplayInterface {
	static public var ROW_IDS = ['A', 'B', 'C', 'D'];
	static public var COL_IDS = ['1', '2', '3', '4', '5', '6', '7', '8'];
	static public var EXIT = "Esc";

	/************************/
	/****  CppInterface  ****/
	/************************/

	@:native("askAiLevel")
	extern static function askAiLevel():cpp.ConstCharStar;

	@:native("askCreateOrJoin")
	extern static function askCreateOrJoin():cpp.ConstCharStar;

	@:native("askOpponentType")
	extern static function askOpponentType():cpp.ConstCharStar;

	@:native("askSide")
	extern static function askSide():cpp.ConstCharStar;

	@:native("askYesNo")
	extern static function askYesNo():cpp.ConstCharStar;

	@:native("clearWindow")
	extern static function clearWindow():Void;

	@:native("drawBoard")
	extern static function drawBoard(str:cpp.ConstCharStar):Void;

	@:native("endCurses")
	extern static public function endCurses():Void;

	@:native("read")
	extern static function read():cpp.ConstCharStar;

	@:native("setCursor")
	extern static function setCursor(x:Int, y:Int):Void;

	@:native("showCreate")
	extern static function showCreate():Void;

	@:native("showError")
	extern static function showError(error:cpp.ConstCharStar):Void;

	@:native("showPlay")
	extern static function showPlay():Void;

	@:native("showPositionChoices")
	extern static function showPositionChoices(choicesStrs:cpp.Pointer<Int>, nChoices:Int, canPass:Bool):Int;

	@:native("showRules")
	extern static function showRules():Void;

	@:native("startCurses")
	extern static public function startCurses():Void;

	@:native("waitPress")
	extern static function waitPress():Void;

	@:native("write")
	extern static function write(str:cpp.ConstCharStar):Void;

	/*************************/
	/****  CustomMethods  ****/
	/*************************/

	public var me:Piece;

	public function new() {
		Display.startCurses();
	}

	/**
		Display the board to user
	**/
	public function boardToString(board:Array<Array<Piece>>):String {
		var str = '';
		for(row in board) {
			for(cell in row) {
				str += this.pieceToString(cell);
			}
		}
		return str;
	}

	public function choice(position:Position):Int {
		return (position.y * 8) + position.x;
	}

	public function getPositionChoice(positions:Array<Position>, canPass:Bool):Null<Position> {
		Display.showPlay();
		var choices:Array<Int> = [];
		var m:Map<Int, Position> = new Map();
		for(i in 0...positions.length) {
			var choiceInt = this.choice(positions[i]);
			choices.push(choiceInt);
			m.set(choiceInt, positions[i]);
		}

		var responseInt = Display.showPositionChoices(cpp.Pointer.ofArray(choices), positions.length, canPass);
		if (responseInt == 32) {
			return null;
		}

		if (responseInt == 33) {
			throw new EndGameInterrupt();
		}
		return m.get(responseInt);
	}

	/**
		Creates a display version of Piece
	**/
	public function pieceToString(piece:Piece):String {
		return switch piece {
			case Piece.WHITE: 'O';
			case Piece.BLACK: 'X';
			case Piece.NONE: ' ';
			default: '';
		};
	}

	public function print(str:String) {
		Display.write(cpp.ConstCharStar.fromString(str));
	}

	public function println(str:String) {
		this.print(str + "\n");
	}

	public function prompt(prompt:String, y:Int = 0) {
		this.print(prompt);
		Display.setCursor(prompt.length + 1, y);
	}

	public function readln():String {
		return Display.read().toString();
	}

	/**
		Displays the rules of the game
	**/
	public function rules() {
		Display.showRules();
	}


	/**
		Converts a Position to displayable String
	**/
	public function positionToString(position:Position):String {
		return Display.ROW_IDS[position.y] + Display.COL_IDS[position.x];
	}


	/****************************/
	/****  DisplayInterface  ****/
	/****************************/


	/**
		@implements DisplayInterface
	**/
	public function displayError(error:Error):Void {
		Display.showError(cpp.ConstCharStar.fromString(error.message));
	}

	/**
		@implements DisplayInterface
	**/
	public function displayGameId(gameId:UuidV4):Void {
		Display.showCreate();
		Display.clearWindow();
		this.println('Your Game ID is:');
		this.println('    $gameId');
		this.println('Send this code to an opponent for them to join.');
	}

	/**
		@implements DisplayInterface
	**/
	public function endGame(scores:Map<Piece,Int>, board:Array<Array<Piece>>):Void {
		Display.showPlay();
		Display.clearWindow();
		var blackScore = scores.get(Piece.BLACK);
		var whiteScore = scores.get(Piece.WHITE);
		var winner = Piece.NONE;
		if (blackScore > whiteScore) {
			winner = Piece.BLACK;
		} else if (whiteScore > blackScore) {
			winner = Piece.WHITE;
		}
		if (winner != Piece.NONE) {
			var teamStr = this.pieceToString(winner);
			if (winner == this.me) {
				this.println('You ($teamStr) are the winner!');
			} else {
				this.println('Opponent ($teamStr) is the winner!');
			}
		} else {
			this.println('Tie game.');
		}
		for(team => score in scores) {
			var teamStr = this.pieceToString(team);
			this.println('($teamStr): $score points');
		}
		this.println('');
		this.println('Press any key');
		Display.waitPress();
	}

	/**
		@implements DisplayInterface
	**/
	public function exit() {
		Display.clearWindow();
		this.println('Goodbye');
		Display.endCurses();
		Sys.println('Goodbye');
		Sys.exit(0);
	}

	/**
		@implements DisplayInterface
	**/
	public function getAiLevel():Level {
		Display.showCreate();
		Display.clearWindow();
		this.println('Difficulty:');
		var choice = Display.askAiLevel().toString();
		return switch(choice) {
			case 'Easy': return Level.EASY;
			case 'Medium': return Level.MEDIUM;
			case 'Hard': return Level.HARD;
			default: throw 'Bad Input';
		};
	}

	/**
		@implements DisplayInterface
	**/
	public function getGameId():UuidV4 {
		Display.showCreate();
		Display.clearWindow();
		this.println('Please enter the game id:');
		this.println('');
		Display.setCursor(0, 1);
		while (true) {
			try {
				var input = this.readln().toLowerCase();
				if(input.charCodeAt(0) == 27) { //ESC
					throw new EndGameInterrupt();
				}

				if(Uuid.isV4(input)) {
					return input;
				}

				this.println('"${input}" Invalid game id, please try again:');
				Display.setCursor(0, 1);
			} catch(e:Eof) {
				throw new EndGameInterrupt();
			}
		}
	}

	/**
		@implements DisplayInterface
	**/
	public function getGameStart():StartChoice {
		Display.clearWindow();
		Display.showCreate();
		this.println('Would you like to create or join a game?');

		var response:String = Display.askCreateOrJoin().toString();
		if(response == Display.EXIT) {
			throw new EndGameInterrupt();
		} else if(response == 'Join') {
			return StartChoice.JOIN;
		}
		Display.clearWindow();
		this.println('Play against an AI or Human opponent?');
		var response:String = Display.askOpponentType().toString();
		if(response == Display.EXIT) {
			throw new EndGameInterrupt();
		} else if(response == 'AI') {
			return StartChoice.AI;
		} else if(response == 'Human') {
			return StartChoice.CREATE;
		}

		return null;
	}

	/**
		@implements DisplayInterface
	**/
	public function getTeamChoice():Piece {
		Display.showCreate();
		Display.clearWindow();
		this.println('Which team would you like to play as?');
		var choice = Display.askSide().toString().toLowerCase().charAt(0);
		return switch(choice) {
			case 'o': Piece.WHITE;
			case 'x': Piece.BLACK;
			default: Piece.BLACK;
		}
	}

	/**
		@implements DisplayInterface
	**/
	public function invite(gameId:String):Void {
		Display.showCreate();
		this.println('Join code: "${gameId}"');
	}

	/**
		@implements DisplayInterface
	**/
	public function playAgain():Bool {
		Display.showCreate();
		Display.clearWindow();
		this.println('Would you like to play again:');
		var answer = Display.askYesNo().toString();

		return answer == 'Yes';
	}

	/**
		@implements DisplayInterface
	**/
	public function requestFollowUpMove(currentPlayer:Piece, position:Position, moves:Array<Position>):Null<Move> {
		Display.showPlay();
		Display.clearWindow();
		var teamStr = this.pieceToString(currentPlayer);
		var positionStr = this.positionToString(position);
		this.println('($teamStr) has a follow-up move for Position "$positionStr":');
		var to:Null<Position> = this.getPositionChoice(moves, true);
		if (to == null) return null;
		return {
			from: position,
			to: to
		};
	}

	/**
		@implements DisplayInterface
	**/
	public function requestNextMoveFrom(currentPlayer:Piece, positions:Array<Position>):Position {
		Display.showPlay();
		this.println('Please select the next move:');
		this.println('The following pieces are available to move:');
		return this.getPositionChoice(positions, false);
	}

	/**
		@implements DisplayInterface
	**/
	public function requestNextMoveTo(currentPlayer:Piece, moves:Array<Position>):Position {
		Display.showPlay();
		Display.clearWindow();
		this.println('The following moves are available:');
		return this.getPositionChoice(moves, false);
	}

	/**
		@implements DisplayInterface
	**/
	public function showBoard(currentPlayer:Piece, isMe:Bool, gameState:GameState, board:Array<Array<Piece>>):Void {
		Display.showPlay();
		Display.clearWindow();
		if (gameState == GameState.WAITING) {
			this.println('Waiting for opponent to join.');
		} else {
			if (isMe) {
				this.me = currentPlayer;
				this.println('Your Move (${this.pieceToString(currentPlayer)}).');
			} else {
				this.println('Waiting for opponent (${this.pieceToString(currentPlayer)}) to move.');
			}
		}
		Display.drawBoard(cpp.ConstCharStar.fromString(this.boardToString(board)));
	}

	/**
		@implements DisplayInterface
	**/
	public function showLastMove(movedPlayer:Piece, move:MoveObject):Void {
		this.println('${this.pieceToString(movedPlayer)} moved');
		this.println('  from (${move.from.x}, ${move.from.y})');
		this.println('  to   (${move.to.x}, ${move.to.y})');
	}
}
