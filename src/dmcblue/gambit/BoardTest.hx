package dmcblue.gambit;

import utest.Assert;
import utest.Async;
import utest.Test;

// typedef CountTest = {
// 	var str: String;
// 	var substr: String;
// 	var expected: Int;
// };

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
	public function testGetMoves() {
		var board = Board.newGame();
		var moves = board.getMoves();
		Assert.equals(8, positions.length);
		Assert.equals(2, positions[0].y);
	}
}
