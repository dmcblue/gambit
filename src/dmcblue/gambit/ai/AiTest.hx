package dmcblue.gambit.ai;

import utest.Assert;
import utest.Async;
import utest.Test;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;

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
