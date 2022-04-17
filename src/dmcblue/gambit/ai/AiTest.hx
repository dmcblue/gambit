package dmcblue.gambit.ai;

import dmcblue.gambit.Position;
import dmcblue.gambit.Position;
import utest.Assert;
import utest.Async;
import utest.Test;
import dmcblue.gambit.Board;
import dmcblue.gambit.Move;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.ai.Ai;
import dmcblue.gambit.ai.Level;
import dmcblue.gambit.ai.Record;
import dmcblue.gambit.ai.RecordPersistence;
import interealmGames.persistence.MemoryConnection;

typedef GetMoveTest = {
	player:Piece,
	board:String,
	options:Array<Move>
};

typedef IndexToPositionTest = {
	input:Int,
	expected:Position
};

typedef MoveFromStringsTest = {
	team:Piece,
	start:String,
	finish:String,
	expected:Move
};

class AiTest extends Test {
	public function testGetMove() {
		var connection = new MemoryConnection();
		var persistence = new RecordPersistence(connection);
		var rec = new Record(
			"100200200" + 
			"10010000" + 
			"02000002" + 
			"00100001",
			[{
				name:
					"200200200" + 
					"10010001" + 
					"02000002" + 
					"00100000",
				success: 0
			}]
		);
		persistence.save(rec);
		var ai = new Ai(persistence);
		var tests:Array<GetMoveTest> = [{
			// success is 0, can cause division error
			player: Piece.WHITE,
			board:
				"00200200" + 
				"10010000" + 
				"02000002" + 
				"00100001",
			options: [{
				from: new Position(7, 3),
				to:   new Position(7, 1)
			}]
		}];

		for(test in tests) {
			var board = Board.fromString(test.board);
			var move = ai.getMove(Level.EASY, test.player, board);
			var m = test.options.filter(function(m:Move) {
				return m.from.x == move.from.x &&
					m.from.y == move.from.y &&
					m.to.x == move.to.x &&
					m.to.y == move.to.y;
			});
			Assert.equals(1, m.length);
			Assert.notNull(m[0]);
		}
	}

	public function testIndexToPosition() {
		var ai = new Ai(null);
		var tests:Array<IndexToPositionTest> = [{
			input: 0,
			expected: new Position(0, 0)
		}, {
			input: 9,
			expected: new Position(1, 1)
		}, {
			input: 31,
			expected: new Position(7, 3)
		}, {
			input: 18,
			expected: new Position(2, 2)
		}];

		for(test in tests) {
			Assert.same(test.expected, ai.indexToPosition(test.input));
		}
	}

	public function testMoveFromStrings() {
		var ai = new Ai(null);
		var tests:Array<MoveFromStringsTest> = [{
			team: Piece.BLACK,
			start:  '00000000' +
				    '11111111' +
				    '22222222' +
				    '00000000',
			finish: '00000200' +
				    '11111011' +
				    '22222022' +
				    '00000000',
			expected: {
				from: new Position(5, 2),
				to: new Position(5, 0)
			}
		}];

		for(test in tests) {
			Assert.same(
				test.expected,
				ai.moveFromStrings(
					test.team,
					test.start,
					test.finish
				)
			);
		}
	}
}
