package dmcblue.gambit;

import dmcblue.gambit.Position;
import dmcblue.gambit.Board;
import utest.Assert;
import utest.Async;
import utest.Test;

typedef EqualsTest = {
	var a: Position;
	var b: Position;
	var expected: Bool;
};

class PositionTest extends Test 
{
	/**
	 * Basic tests for capitalization
	 */
	public function testEquals() {
		var tests:Array<EqualsTest> = [{
			a: new Position(1, 2),
			b: new Position(1, 2),
			expected: true
		}, {
			a: new Position(2, 2),
			b: new Position(1, 2),
			expected: false
		}];
		for(test in tests) {
			Assert.equals(test.expected, test.a == test.b, '${test.a} == ${test.b}');
			Assert.equals(test.expected, test.b == test.a, '${test.b} == ${test.a}');
		}
	}
}
