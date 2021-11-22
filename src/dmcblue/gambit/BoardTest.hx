package dmcblue.gambit;

import dmcblue.gambit.Position;
import dmcblue.gambit.Board;
import utest.Assert;
import utest.Async;
import utest.Test;

typedef MidPointTest = {
	var here: Position;
	var there: Position;
	var expected: Position;
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
		// var positions = board.getPositions(Piece.WHITE);
		// trace(positions);
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
}
