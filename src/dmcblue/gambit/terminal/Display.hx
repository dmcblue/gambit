package dmcblue.gambit.terminal;

import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.PieceTools;
import dmcblue.gambit.Display in DisplayInterface;
import interealmGames.common.errors.Error;
import dmcblue.gambit.Game;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;

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
	public function displayError(error:Error):Void {
		Sys.println(error.message);
	}

	/**
		@implements DisplayInterface
	**/
	public function endGame(scores:Map<Piece,Int>, game:GameMaster):Void {
		Sys.println('');
		Sys.println(this.boardToString(game.getBoard()));
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

	/**
		@implements DisplayInterface
	**/
	public function getResponse(numOptions:Int, passable:Bool = false):String {
		var options:Array<String> = [];
		if (passable) {
			options.push('p');
			options.push('P');
		}
		for(i in 1...(numOptions + 1)) {
			options.push('$i');
		}
		while (true) {
			var input = Sys.stdin().readLine();
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


	/**
		@implements DisplayInterface
	**/
	public function playAgain():Bool {
		Sys.println('Would you like to play again:');
		var options = ['Yes', 'No'];
		for(i in 0...options.length) {
			Sys.println('\t${i + 1}:\t${options[i]}');
		}
		var answer = options[Std.parseInt(this.getResponse(options.length+1)) - 1];

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
	public function requestFollowUpMove(currentPlayer:Piece, position:Position, moves:Array<Position>, game:GameMaster):Move {
		Sys.println('');
		Sys.println(this.boardToString(game.getBoard()));
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
		var input = this.getResponse(moves.length, true);
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
	public function requestNextMove(currentPlayer:Piece, positions:Array<Position>, game:GameMaster):Null<Move> {
		Sys.println('');
		Sys.println(this.boardToString(game.getBoard()));
		var teamStr = this.pieceToString(currentPlayer);
		Sys.println('Please select the next $currentPlayer ($teamStr) move:');
		Sys.println('The following pieces are available to move:');
		for(i in 0...positions.length) {
			var position = this.positionToString(positions[i]);
			Sys.println('\t${i + 1}:\t$position');
		}
		Sys.print('Please enter which position: ');
		var input = this.getResponse(positions.length);
		var choice = Std.parseInt(input);
		var from = positions[choice - 1];

		Sys.println('The following moves are available:');
		var moves = game.getMoves(from);
		for(i in 0...moves.length) {
			var position = this.positionToString(moves[i]);
			Sys.println('\t${i + 1}:\t$position');
		}
		Sys.print('Please enter which move: ');
		var choice = Std.parseInt(this.getResponse(moves.length));
		var to = moves[choice - 1];

		return {
			to: to,
			from: from
		};
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

	// public function positionFromString(str:String):Null<Position> {
	// 	if (str.toLowerCase() == 'p') {
	// 		return null;
	// 	}

	// 	if(!Display.COL_IDS.contains(str.charAt(1)) || !Display.ROW_IDS.contains(str.charAt(0)) {

	// 	}

	// 	var x = Display.COL_IDS.indexOf(str.charAt(1));
	// 	var y = Display.ROW_IDS.indexOf(str.charAt(0));

	// 	return new Position(x, y);
	// }
}
