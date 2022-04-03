package dmcblue.gambit;

import haxe.Json;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.Board;
import dmcblue.gambit.error.NotIslandError;
import utest.Assert;
import utest.Async;
import utest.Test;

typedef CalculateScoreTest = {
	var board: String;
	var team: Piece;
	var expected: Int;
};

typedef GetIslandTest = {
	var board: String;
	var start: Position;
	var raises: Bool;
	var expected: Array<Position>;
};

typedef GetMovesTest = {
	var board: String;
	var position: Position;
	var moves:Array<Position>;
};

typedef HasAnyMoreMovesTest = {
	var board: String;
	var team: Piece;
	var expected: Bool;
};

typedef IsOverTest = {
	var board: String;
	var expected: Bool;
};

typedef IsValidMoveTest = {
	var move:Move;
	var expected:Bool;
};

typedef MidPointTest = {
	var here: Position;
	var there: Position;
	var expected: Position;
};

class BoardTest extends Test 
{
	/**
	 * constructor
	 */
	public function testConstructor() {
		var board = new Board();
		Assert.equals(4, board.board.length);
		//Assert.equals(board.board[2][3], Piece.BLACK);
	}

	/**
	 * getPositions
	 */
	public function testGetPositions() {
		var board = Board.newGame();
		var positions = board.getPositions(Piece.BLACK);
		Assert.equals(8, positions.length);
		Assert.equals(2, positions[0].y);
	}

	/**
	 * fromString
	 */
	public function testFromString() {
		var str =
			'00000000' +
			'10000000' +
			'00000000' +
			'00000000';
		var board = Board.fromString(str);

		Assert.equals(Piece.WHITE, board.board[1][0]);
	}

	public function testHasAnyMoreMoves() {
		var tests:Array<HasAnyMoreMovesTest> = [{
			board: '20002000000010000002000001000011',
			team: Piece.WHITE,
			expected: true
		}];

		for(test in tests) {
			var board = Board.fromString(test.board);
			var actual = board.hasAnyMoreMoves(test.team);
			Assert.equals(test.expected, actual);
		}
	}
	
	/**
	 * midPoint()
	 */
	public function testMidPoint() {
		var tests:Array<MidPointTest> = [{
			here: new Position(0, 0),
			there: new Position(2, 0),
			expected: new Position(1, 0),
		}];

		var board = new Board();
		for(test in tests) {
			var actual = board.midPoint(test.here, test.there);
			Assert.same(actual, test.expected, 'x: ${test.expected.x}, y: ${test.expected.y}, x: ${actual.x}, y: ${actual.y}');
		}
	}

	/**
	 * getMoves()
	 */
	public function testGetMoves() {
		var tests:Array<GetMovesTest> = [{
			board: 
				'00000000' +
				'12000000' +
				'22000000' +
				'00000000',
			position: new Position(0, 1),
			moves: [
				new Position(0, 3),
				new Position(2, 3),
				new Position(2, 1)
			]
		}, {
			board: 
				'20002000' +
				'00001000' +
				'00020000' +
				'01000011',
			position: new Position(4, 1),
			moves: [
				new Position(2, 3)
			]
		}];
		
		for(test in tests) {
			var board = Board.fromString(test.board);
			var moves = board.getMoves(test.position);
			Assert.equals(test.moves.length, moves.length);
			for(expectedMove in test.moves) {
				Assert.isTrue(this.contains(moves, expectedMove), '$expectedMove');
			}
		}
	}

	private function contains(moves:Array<Position>, needle:Position):Bool {
		return moves.filter(function(move) {
			return move.x == needle.x && move.y == needle.y;
		}).length > 0;
	}

	/**
	 *
	 */
	 public function testGetIsland() {
		var tests:Array<GetIslandTest> = [{
			board:
				'00000000' +
				'12000000' +
				'22000000' +
				'00000000',
			raises: true,
			start: new Position(0, 1),
			expected: [],
		}, {
			board:
				'00000000' +
				'02010000' +
				'22000000' +
				'00000000',
			raises: false,
			start: new Position(0, 2),
			expected: [new Position(0, 2), new Position(1, 1), new Position(1, 2)],
		}, {
			board:
				'00000000' +
				'02010000' +
				'22000000' +
				'00000000',
			raises: false,
			start: new Position(3, 1),
			expected: [new Position(3, 1)],
		}, {
			board:
				'00100000' +
				'02000000' +
				'22000000' +
				'00000000',
			raises: true,
			start: new Position(2, 0),
			expected: [],
		}, {
			board: //here
				'22000002' +
				'00001001' +
				'00200002' +
				'01000101',
			raises: false,
			start: new Position(5, 3),
			expected: [new Position(5, 3)],
		}];

		for(test in tests) {
			var board = Board.fromString(test.board);
			if (test.raises) {
				Assert.raises(function() {
					board.getIsland(test.start);
				}); // could be exact
			} else {
				var island = board.getIsland(test.start);

				Assert.same(island, test.expected, test.start.toString());
			}
		}
	}

	public function testIsValidMove() {
		var board = Board.newGame();
		var tests:Array<IsValidMoveTest> = [{
			move: {
				from: new Position(2, 2),
				to: new Position(2, 0)
			},
			expected: true
		}, {
			move: {
				from: new Position(2, 2),
				to: new Position(2, 3)
			},
			expected: false
		}, {
			move: {
				from: new Position(2, 2),
				to: new Position(1, 0)
			},
			expected: false
		}, {
			move: {
				from: new Position(2, 2),
				to: new Position(0, 0)
			},
			expected: true
		}];

		for(test in tests) {
			Assert.equals(test.expected, board.isValidMove(test.move), Json.stringify(test.move));
		}
	}
	
	public function testCalculateScores() {
		var tests:Array<CalculateScoreTest> = [{
			board:
				'00000000' +
				'12000000' +
				'22000000' +
				'00000000',
			team: Piece.WHITE,
			expected: 0
		}, {
			board:
				'22000002' +
				'00001001' +
				'00200002' +
				'01000101',
			team: Piece.WHITE,
			expected: 2
		}, {
			board:
				'22000002' +
				'00001001' +
				'00200002' +
				'01000101',
			team: Piece.BLACK,
			expected: 3
		}];

		for (test in tests) {
			var board = Board.fromString(test.board);
			var score = board.calculateScore(test.team);
			Assert.equals(test.expected, score);
		}
	}
}
