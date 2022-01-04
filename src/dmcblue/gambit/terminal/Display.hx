package dmcblue.gambit.terminal;

import dmcblue.gambit.Display.StartChoice;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.PieceTools;
import dmcblue.gambit.Display in DisplayInterface;
import interealmGames.common.errors.Error;
import dmcblue.gambit.Game;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.server.GameState;
import interealmGames.common.uuid.Uuid;
import interealmGames.common.uuid.UuidV4;

class Display implements DisplayInterface {
	static public var ROW_IDS = ['A', 'B', 'C', 'D'];
	static public var COL_IDS = ['1', '2', '3', '4', '5', '6', '7', '8'];
	public function new() {}

	/**
		Display the board to user
	**/
	public function boardToString(board:Array<Array<Piece>>):String {
		var str = ' |';
		for(colId in Display.COL_IDS) {
			str += '$colId|';
		}
		str += '\n------------------\n';
		for(rowIndex in 0...board.length) {
			str += '${Display.ROW_IDS[rowIndex]}|';
			var row = board[rowIndex];
			var cells:Array<String> = [];
			for(cell in row) {
				cells.push(this.pieceToString(cell));
			}
			str += cells.join(' ') + '|\n';
		}
		str += '------------------\n';
		return str;
	}

	/**
		@implements DisplayInterface
	**/
	public function createJoinResume():StartChoice {
		Sys.print(
			'Would you like to (c)reate or (j)oin a game? (c/j) '
		);
		var options:Array<String> = ['c', 'j'];
		var input:String = this.getResponse(options);
		return switch(input) {
			case 'c': StartChoice.CREATE;
			case 'j': StartChoice.JOIN;
			default: null;
		};
	}

	/**
		@implements DisplayInterface
	**/
	public function displayError(error:Error):Void {
		Sys.println(error.message);
	}

	/**
		@implements DisplayInterface
	**/
	public function endGame(scores:Map<Piece,Int>, board:Array<Array<Piece>>):Void {
		Sys.println('');
		Sys.println(this.boardToString(board));
		Sys.println('');
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
			Sys.println('$winner ($teamStr) is the winner!');
		} else {
			Sys.println('Tie game.');
		}
		for(team => score in scores) {
			var teamStr = this.pieceToString(team);
			Sys.println('$team ($teamStr): $score points');
		}
		Sys.println('');
	}

	/**
		Savely ends the program
	**/
	public function exit() {
		Sys.println('Goodbye');
		Sys.exit(0);
	}

	public function getGameId():UuidV4 {
		Sys.print(
			'Please enter the game id:'
		);
		while (true) {
			var input = Sys.stdin().readLine().toLowerCase();
			if(input.charCodeAt(0) == 27) { //ESC
				this.exit();
			}

			if(Uuid.isV4(input)) {
				return input;
			}

			Sys.print('Invalid game id, please try again:');
		}
	}

	public function getResponse(options:Array<String>):String {
		while (true) {
			var input = Sys.stdin().readLine().toLowerCase();
			if(input.charCodeAt(0) == 27) { //ESC
				this.exit();
			}
			if(input.toLowerCase() == 'r') {
				this.rules();
			}
			if(options.contains(input)) {
				return input;
			}

			Sys.print('Invalid reponse, please try again:');
		}
	}

	public function getResponseInt(numOptions:Int):Int {
		var options:Array<String> = [];
		for(i in 1...(numOptions + 1)) {
			options.push('$i');
		}
		return Std.parseInt(this.getResponse(options));
	}

	public function getTeamChoice():Piece {
		Sys.println(
			'Which team would you like to play as? (x/o)'
		);
		var choice = this.getResponse(['o','x']);
		return switch(choice) {
			case 'o': Piece.WHITE;
			case 'x': Piece.BLACK;
			default: Piece.BLACK;
		}
	}

	/**
		Greets player and gives them general key commands
	**/
	public function greetings():Void {
		Sys.println(
			'Welcome to Gambit.\n' +
			'Press R/r any time to read the rules ' +
			'or ESC to quit.'
		);
	}

	/**
		Display the invite
	**/
	public function invite(gameId:String):Void {
		Sys.println(
			'Join code: "${gameId}"'
		);
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

	// no longer part of interface so will not be called externally
	// must self call 
	public function playAgain():Bool {
		Sys.println('Would you like to play again:');
		var options = ['Yes', 'No'];
		for(i in 0...options.length) {
			Sys.println('\t${i + 1}:\t${options[i]}');
		}
		var answer = options[this.getResponseInt(options.length+1) - 1];

		return answer == 'Yes';
	}


	/**
		Converts a Position to displayable String
	**/
	public function positionToString(position:Position):String {
		return Display.ROW_IDS[position.y] + Display.COL_IDS[position.x];
	}

	/**
		@implements DisplayInterface
	**/
	public function requestFollowUpMove(currentPlayer:Piece, position:Position, moves:Array<Position>):Null<Move> {
		var teamStr = this.pieceToString(currentPlayer);
		var positionStr = this.positionToString(position);
		Sys.println('$currentPlayer ($teamStr) has a follow-up move for Position "$positionStr":');
		Sys.println('The following moves are available:');
		for(i in 0...moves.length) {
			var position = this.positionToString(moves[i]);
			Sys.println('\t${i + 1}:\t$position');
		}
		Sys.println('\tP:\tTo pass');
		Sys.print('Please enter which move: ');
		var options:Array<String> = [];
		for(i in 1...(moves.length + 1)) {
			options.push('$i');
		}
		options.push('p');
		var input = this.getResponse(options);
		if (input.toLowerCase() == 'p') {
			return null;
		}
		var choice = Std.parseInt(input);
		var to = moves[choice - 1];

		return {
			to: to,
			from: position
		};
	}

	/**
		@implements DisplayInterface
	**/
	public function requestNextMoveFrom(currentPlayer:Piece, positions:Array<Position>):Position {
		var teamStr = this.pieceToString(currentPlayer);
		Sys.println('Please select the next move:');
		Sys.println('The following pieces are available to move:');
		for(i in 0...positions.length) {
			var position = this.positionToString(positions[i]);
			Sys.println('\t${i + 1}:\t$position');
		}
		Sys.print('Please enter which position: ');
		var choice = this.getResponseInt(positions.length);
		return positions[choice - 1];
	}

	/**
		@implements DisplayInterface
	**/
	public function requestNextMoveTo(currentPlayer:Piece, moves:Array<Position>):Position {
		Sys.println('The following moves are available:');
		for(i in 0...moves.length) {
			var position = this.positionToString(moves[i]);
			Sys.println('\t${i + 1}:\t$position');
		}
		Sys.print('Please enter which move: ');
		var choice = this.getResponseInt(moves.length);
		var to = moves[choice - 1];

		return to;
	}

	/**
		Displays the rules of the game
	**/
	public function rules() {
		Sys.println(
			['\n\nRules:',
			'\n\nEach player takes turns making moves.',
			'Pieces are moved by jumping over the opposing teams pieces in any direction.',
			'The piece that has been jumped over is removed from the board.',
			'If the move is available, the same piece can make multiple jumps in a row before the turn is over.',
			'The game ends when any player is unable to make a move on their turn.',
			'The board is then scored.',
			'Players earn points for each island of pieces they have on the board.',
			'An island is a group of piece from the same side that does not touch any pieces of the opposing player, including diagonoally.',
			'Scores are by the number of pieces per island, added up for all islands for a player.',
			'\nScores per island:',
			'\n\t1 piece:  1 point',
			'\n\t2 pieces: 3 points',
			'\n\t3 pieces: 5 points',
			'\n\t4 pieces: 7 points',
			'\n\t5 pieces: 9 points\n'].join(' ')
		);
	}

	/**
		Display the current game state
	**/
	public function showBoard(currentPlayer:Piece, isMe:Bool, gameState:GameState, board:Array<Array<Piece>>):Void {
		Sys.println('');
		if (gameState == GameState.WAITING) {
			Sys.println('Waiting for opponent to join.');
		} else {
			if (isMe) {
				Sys.println('Your Move (${this.pieceToString(currentPlayer)}).');
			} else {
				Sys.println('Waiting for ${this.pieceToString(currentPlayer)} to move.');
			}
		}
		Sys.println('');
		Sys.println(this.boardToString(board));
		Sys.println('');
	}
}
