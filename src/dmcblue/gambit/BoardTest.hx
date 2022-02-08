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

typedef MidPointTest = {
	var here: Position;
	var there: Position;
	var expected: Position;
};

typedef GetIslandTest = {
	var board: String;
	var start: Position;
	var raises: Bool;
	var expected: Array<Position>;
};

typedef IsOverTest = {
	var board: String;
	var expected: Bool;
};

typedef CalculateScoreTest = {
	var board: String;
	var team: Piece;
	var expected: Int;
};

typedef IsValidMoveTest = {
	var move:Move;
	var expected:Bool;
};

class BoardTest extends Test 
{
	/**
	 * Basic tests for capitalization
	 */
	public function testConstructor() {
		var board = new Board();
		Assert.equals(4, board.board.length);
		//Assert.equals(board.board[2][3], Piece.BLACK);
	}

	/**
	 * Basic tests for capitalization
	 */
	public function testGetPositions() {
		var board = Board.newGame();
		var positions = board.getPositions(Piece.BLACK);
		Assert.equals(8, positions.length);
		Assert.equals(2, positions[0].y);
	}

	/**
	 * Basic tests for capitalization
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
	
	/**
	 * Basic tests for capitalization
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
	 * Basic tests for capitalization
	 */
	public function testGetMoves() {
		var str =
			'00000000' +
			'12000000' +
			'22000000' +
			'00000000';
		var board = Board.fromString(str);

		var position = new Position(0, 1);
		var moves = board.getMoves(position);
		var expectedMoves:Array<Position> = [
			new Position(0, 3),
			new Position(2, 3),
			new Position(2, 1)
		];
		Assert.equals(expectedMoves.length, moves.length);
		for(expectedMove in expectedMoves) {
			Assert.isTrue(this.contains(moves, expectedMove), '$expectedMove');
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
