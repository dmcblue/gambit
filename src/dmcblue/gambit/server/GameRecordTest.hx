package dmcblue.gambit.server;

import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.errors.InvalidInputError;
import utest.Assert;
import utest.Async;
import utest.Test;

typedef FromStringTest = {
	var input: String;
	var raises: Bool;
	var expectedTeam: Piece;
	var blackPositions: Array<Position>;
	var whitePositions: Array<Position>;
};

class GameRecordTest extends Test 
{
	public function testFromString() {
		var tests:Array<FromStringTest> = [{
			input: '2' +
				'00000000' +
				'01000000' +
				'00000000' +
				'00000000',
			raises: false,
			expectedTeam: Piece.BLACK,
			blackPositions: [],
			whitePositions: [new Position(1, 1)]
		}];
		for(test in tests) {
			if(test.raises) {
				Assert.raises(function() {
					var game = GameRecord.fromString('', test.input);
				});
			} else {
				var game = GameRecord.fromString('', test.input);
				Assert.equals(test.expectedTeam, game.currentPlayer);
				for(position in test.blackPositions) {
					Assert.equals(Piece.BLACK, game.board.pieceAt(position));
				}
				for(position in test.whitePositions) {
					Assert.equals(Piece.WHITE, game.board.pieceAt(position));
				}
			}
		}
	}

	public function testToString() {
		var board = Board.newGame();
		var gameRecord = new GameRecord('', Piece.WHITE, board);
		var expected =
			'1' +
			'00000000' +
			'11111111' +
			'22222222' +
			'00000000';
		Assert.equals(expected, gameRecord.toString());
	}
}
