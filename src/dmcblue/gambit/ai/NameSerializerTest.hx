package dmcblue.gambit.ai;

import utest.Assert;
import utest.Async;
import utest.Test;
import dmcblue.gambit.ai.NameSerializer;

typedef NSTest = {
	input:String,
	expected:String
};

class NameSerializerTest extends Test {
	public function testDecode() {
		var tests:Array<NSTest> = [{
			input: "10000000000000000",
			expected: "100000000000000000000000000000000"
		}];
		var serializer = new NameSerializer();

		for(test in tests) {
			var actual = serializer.decode(test.input);
			Assert.equals(test.expected, actual);
		}
	}
}
