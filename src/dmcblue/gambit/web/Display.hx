package dmcblue.gambit.web;

import haxe.io.Eof;
import dmcblue.gambit.Display.StartChoice;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.PieceTools;
import dmcblue.gambit.DisplayAsync in DisplayInterface;
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
import js.Browser.document;
import interealmGames.browser.components.multiViewComponent.MultiViewComponent;
import interealmGames.browser.display.TemplateView;
import interealmGames.browser.display.View;
import js.html.Event;
import js.html.HtmlElement;
import js.html.InputElement;
import js.html.NodeList;
import js.html.TextAreaElement;

enum MoveType {
	FOLLOW_UP;
	NEXT_FROM;
	NEXT_TO;
}

class Display implements DisplayInterface extends View {
	static public var ROW_IDS = ['A', 'B', 'C', 'D'];
	static public var COL_IDS = ['1', '2', '3', '4', '5', '6', '7', '8'];
	
	/*************************/
	/****  CustomMethods  ****/
	/*************************/

	public var me:Piece;
	private var lastFrom:Position = null;
	private var levelCallbackDefault:Level-> Void = function(level:Level) {};
	private var levelCallback:Level->Void;
	private var gameIdCallbackDefault:UuidV4-> Void = function(gameId:UuidV4) {};
	private var gameIdCallback:UuidV4->Void;
	private var startChoiceCallbackDefault:StartChoice->Void = function(startChoice:StartChoice) {};
	private var startChoiceCallback:StartChoice->Void;
	private var getTeamChoiceCallbackDefault:Piece->Void = function(piece:Piece):Void {};
	private var getTeamChoiceCallback:Piece->Void;
	private var playAgainCallbackDefault:Bool->Void = function(playAgain:Bool) {};
	private var playAgainCallback:Bool->Void;
	private var moveCallbackDefault:Move->Void = function(move:Move):Void {};
	private var moveCallback:Move->Void;
	private var positionCallbackDefault:Position->Void = function(position:Position):Void {};
	private var positionCallback:Position->Void;
	private var moveType:MoveType;
	private var validChoices:Array<Position>;

	public function new() {
		super(cast document.getElementById('app'));
		this.addEvent("#ai_level_easy", "click", this.levelCallbackClosure(Level.EASY));
		this.addEvent("#ai_level_medium", "click", this.levelCallbackClosure(Level.MEDIUM));
		this.addEvent("#ai_level_hard", "click", this.levelCallbackClosure(Level.HARD));

		this.addEvent("#invite_game_id_done", "click", function() {
			var elem:InputElement = cast this.getElement('#invite_game_id');
			this.gameIdCallback(elem.value);
			this.gameIdCallback = this.gameIdCallbackDefault;
		});

		this.addEvent("#start_create", "click", function() {
			this.showText('Play against an AI or Human opponent?');
			this.showComponents('create');
		});
		this.addEvent("#start_join", "click", this.gameStartCallbackClosure(StartChoice.JOIN));
		this.addEvent("#start_ai", "click", this.gameStartCallbackClosure(StartChoice.AI));
		this.addEvent("#start_human", "click", this.gameStartCallbackClosure(StartChoice.CREATE));

		this.addEvent("#team_black", "click", this.getTeamChoiceCallbackClosure(Piece.BLACK));
		this.addEvent("#team_white", "click", this.getTeamChoiceCallbackClosure(Piece.WHITE));

		this.addEvent("#play_again_yes", "click", this.playAgainCallbackClosure(true));
		this.addEvent("#play_again_no", "click", this.playAgainCallbackClosure(false));

		// for(row in ['A', 'B', 'C', 'D']) {
		// 	for(col in 0...8) {
		// 		this.addEvent('#move$row$col', "click", this.positionCallbackClosure(row, col));
		// 	}
		// }
		this.addEvent('#pass', "click", function() {
			this.positionCallback(null);
			this.getElement('#pass').style.display = "none";
		});

		for(y in 0...4) {
			for(x in 0...8) {
				var position = new Position(x, y);
				var pieceId = this.positionToPieceId(position);
				this.addEvent('#$pieceId', "click", this.positionCallbackClosure(x, y));
			}
		}

		this.addEvent('#error_close', "click", function() {
			this.getElement('#error').style.display = "none";
		});

		this.addEvent('#help', "click", function() {
			this.getElement('#description').style.display = "block";
		});
		this.addEvent('#description_close', "click", function() {
			this.getElement('#description').style.display = "none";
		});
	}
	
	// public override function onLoad(root:HtmlElement) {
	// 	super.onLoad(root);
		
	// }
		
	private function levelCallbackClosure(level:Level) {
		return function() {
			this.levelCallback(level);
			this.levelCallback = this.levelCallbackDefault;
		};
	}

	private function gameStartCallbackClosure(startChoice:StartChoice) {
		return function() {
			this.startChoiceCallback(startChoice);
			this.startChoiceCallback = this.startChoiceCallbackDefault;
		};
	}

	private function getTeamChoiceCallbackClosure(piece:Piece) {
		return function() {
			this.getTeamChoiceCallback(piece);
			this.getTeamChoiceCallback = this.getTeamChoiceCallbackDefault;
		};
	}

	private function playAgainCallbackClosure(playAgain:Bool) {
		return function() {
			this.playAgainCallback(playAgain);
			this.playAgainCallback = this.playAgainCallbackDefault;
		};
	}

	private function clearChosen() {
		var elements:NodeList = cast this.getRoot().querySelectorAll('.cell .chosen');
		for(i in 0...elements.length) {
			var element:HtmlElement = cast elements.item(i);
			element.style.display = "none";
		}
	}

	// private function positionCallbackClosure(row:String, col:Int) {
	private function positionCallbackClosure(x:Int, y:Int) {
		return function() {
			var position = new Position(x, y);
			var choice = this.validChoices.filter(function(p:Position) {
				return p.x == position.x &&
					p.y == position.y;
			});

			this.clearChosen();

			if(choice.length > 0) {
				this.lastFrom = position;
				this.positionCallback(position);
			}
			// this.positionCallback = this.positionCallbackDefault;
		};
	}

	private function showText(...text:String):Void {
		var elem:TextAreaElement = cast this.getElement('#text');
		elem.innerHTML = text.toArray().join('<br/>');
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

	/**
		Creates a display version of Piece
	**/
	public function pieceToString(piece:Piece):String {
		return switch piece {
			case Piece.WHITE: 'white';
			case Piece.BLACK: 'black';
			case Piece.NONE: ' ';
			default: '';
		};
	}

	/**
		Converts a Position to displayable String
	**/
	public function positionToString(position:Position):String {
		return Display.ROW_IDS[position.y] + Display.COL_IDS[position.x];
	}

	public function positionToId(position:Position) {
		return 'm' + Std.string(['A', 'B', 'C', 'D'][position.y]) + Std.string(position.x);
	}

	public function positionToPieceId(position:Position) {
		return Std.string(['A', 'B', 'C', 'D'][position.y]) + Std.string(position.x);
	}

	public function limitOptions(positions:Array<Position>, withPass:Bool = false, from:Position = null) {
		this.validChoices = positions;
		var ids = positions.map(function(position:Position) {
			return this.positionToId(position);
		});
		var fromId = from == null
			? null
			: this.positionToPieceId(from);

		var element = this.getElement('#pass');
		if (withPass) {
			element.style.display = 'list-item';
		} else {
			element.style.display = 'none';
		}

		var pieceIds = positions.map(function(position:Position) {
			return this.positionToPieceId(position);
		});
		for(y in 0...4) {
			for(x in 0...8) {
				var position = new Position(x, y);
				var pieceId = this.positionToPieceId(position);
				var background:HtmlElement = cast this.getElement('#$pieceId .choice');
				var chosenBackground:HtmlElement = cast this.getElement('#$pieceId .chosen');

				if (pieceIds.indexOf(pieceId) != -1) {
					background.style.display = "block";
				} else {
					background.style.display = "none";
				}

				if (fromId == pieceId) {
					chosenBackground.style.display = "block";
				} else {
					chosenBackground.style.display = "none";
				}
			}
		}
	}

	public function displayPieces(board:Array<Array<Piece>>) {
		for(y in 0...board.length) {
			var row = board[y];
			for(x in 0...row.length) {
				var id = this.positionToPieceId(new Position(x, y));
				var elements:NodeList = cast this.getRoot().querySelectorAll('#$id .piece');
				for(i in 0...elements.length) {
					var element:HtmlElement = cast elements.item(i);
					element.style.display = "none";
				}

				if(board[y][x] == Piece.BLACK) {
					var element:HtmlElement = cast this.getElement('#$id .black');
					element.style.display = "block";
				} else if(board[y][x] == Piece.WHITE) {
					var element:HtmlElement = cast this.getElement('#$id .white');
					element.style.display = "block";
				}

				var background:HtmlElement = cast this.getElement('#$id .choice');
				background.style.display = "none";
			}
		}
	}

	public function showComponents(...componentNames:String) {
		var components = componentNames.toArray();
		var elements:NodeList = cast this.getRoot().querySelectorAll('.component');
		for(i in 0...elements.length) {
			var element:HtmlElement = cast elements.item(i);
			if (components.indexOf(element.id) == -1) {
				element.style.display = "none";
			} else {
				element.style.display = "block";
			}
		}
	}

	/****************************/
	/****  DisplayInterface  ****/
	/****************************/


	/**
		@implements DisplayInterface
	**/
	public function displayError(error:Error):Void {
		var errorDiv:HtmlElement = this.getElement("#error_message");
		errorDiv.innerHTML = error.message;
		this.getElement('#error').style.display = "block";
	}

	/**
		@implements DisplayInterface
	**/
	public function displayGameId(gameId:UuidV4):Void {
		this.showText(
			'Your Game ID is:',
			'    $gameId', 
			'Send this code to an opponent for them to join.'
		);
	}

	/**
		@implements DisplayInterface
	**/
	public function endGame(scores:Map<Piece,Int>, board:Array<Array<Piece>>):Void {
		this.showComponents('play');
		this.clearChosen();
		var blackScore = scores.get(Piece.BLACK);
		var whiteScore = scores.get(Piece.WHITE);
		var winner = Piece.NONE;
		if (blackScore > whiteScore) {
			winner = Piece.BLACK;
		} else if (whiteScore > blackScore) {
			winner = Piece.WHITE;
		}
		var opponent = this.me == Piece.BLACK ? Piece.WHITE : Piece.BLACK;
		var text:Array<String> = [];
		if (winner != Piece.NONE) {
			var teamStr = this.pieceToString(winner);
			if (winner == this.me) {
				text.push('You ($teamStr) are the winner!');
			} else {
				text.push('Opponent ($teamStr) is the winner!');
			}
		} else {
			text.push('Tie game.');
		}
		for(team => score in scores) {
			var teamStr = this.pieceToString(team);
			text.push('($teamStr): $score points');
		}
		
		// this.println('');
		// this.println('Press any key');
		text.push('Would you like to play again:');
		this.showText(...text);
	}

	/**
		@implements DisplayInterface
	**/
	public function exit() {
		this.showText('Goodbye');
	}

	/**
		@implements DisplayInterface
	**/
	public function getAiLevel(callback:Level->Void):Void {
		this.showComponents('ai_level');
		this.showText('Please select AI Level');
		this.levelCallback = callback;
	}

	/**
		@implements DisplayInterface
	**/
	public function getGameId(callback:UuidV4->Void):Void {
		this.showComponents('invite');
		this.showText('Enter Game ID');
		this.gameIdCallback = callback;
	}

	/**
		@implements DisplayInterface
	**/
	public function getGameStart(callback:StartChoice->Void):Void {
		this.showComponents('start');
		this.showText('Would you like to create or join a game?');
		this.startChoiceCallback = callback;
	}

	/**
		@implements DisplayInterface
	**/
	public function getTeamChoice(callback:Piece->Void):Void {
		this.showComponents('team');
		this.showText('Which team would you like to play as?');
		this.getTeamChoiceCallback = callback;
	}

	/**
		@implements DisplayInterface
	**/
	public function invite(gameId:String):Void {
		// this.showComponents('team');// ?
		// this.showText('Join code: "${gameId}"');
		this.showText(
			'Your Game ID is:',
			'    $gameId', 
			'Send this code to an opponent for them to join.'
		);
	}

	/**
		@implements DisplayInterface
	**/
	public function playAgain(callback:Bool->Void):Void {
		this.showComponents('play', 'play_again');
		this.playAgainCallback = callback;
	}

	/**
		@implements DisplayInterface
	**/
	public function requestFollowUpMove(currentPlayer:Piece, position:Position, moves:Array<Position>, callback:Move->Void):Void {
		this.showComponents('play', 'moves', 'pass_option');
		var teamStr = this.pieceToString(currentPlayer);
		var positionStr = this.positionToString(position);
		this.showText('($teamStr) has a follow-up move for Position "$positionStr":');
		this.limitOptions(moves, true, position);
		this.positionCallback = function(positionTo:Position) {
			if (positionTo != null) {
				callback({
					from: position,
					to: positionTo
				});
			} else {
				callback(null);
			}
		};
	}

	/**
		@implements DisplayInterface
	**/
	public function requestNextMoveFrom(
		currentPlayer:Piece,
		positions:Array<Position>,
		callback:Position->Void
	):Void {
		this.showComponents('play');
		this.showText(
			'Please select the next move:',
			'(Red are options, Green are selections)'
		);
		this.limitOptions(positions);
		this.positionCallback = callback;
	}

	/**
		@implements DisplayInterface
	**/
	public function requestNextMoveTo(currentPlayer:Piece, moves:Array<Position>, callback:Position->Void):Void {
		this.showComponents('play');
		this.showText('The following moves are available:');
		this.limitOptions(moves, false, this.lastFrom);
		this.positionCallback = callback;
	}

	/**
		@implements DisplayInterface
	**/
	public function showBoard(currentPlayer:Piece, isMe:Bool, gameState:GameState, board:Array<Array<Piece>>):Void {
		this.showComponents('play');
		var text:Array<String> = [];
		if (gameState == GameState.WAITING) {
			text.push('Waiting for opponent to join.');
		} else {
			if (isMe) {
				this.me = currentPlayer;
				text.push('Your Move (${this.pieceToString(currentPlayer)}).');
			} else {
				this.clearChosen();
				text.push('Waiting for opponent (${this.pieceToString(currentPlayer)}) to move.');
			}
		}
		this.showText(...text);
		this.displayPieces(board);
	}

	/**
		@implements DisplayInterface
	**/
	public function showLastMove(movedPlayer:Piece, move:MoveObject):Void {
		this.showText(
			'${this.pieceToString(movedPlayer)} moved',
			'  from (${move.from.x}, ${move.from.y})',
			'  to   (${move.to.x}, ${move.to.y})'
		);
	}
}
