package dmcblue.gambit.ai;

import utest.Assert;
import utest.Async;
import utest.Test;
import dmcblue.gambit.ai.Record;

typedef CreateChildrenTest = {
	name:String,
	children:Array<String>
};

class RecordTest extends Test {
	public function testCreateChildren() {
		var tests:Array<CreateChildrenTest> = [{
			name:
				"1" +
				"20000002" +
				"01101110" +
				"02220220" +
				"00000100",
			children: [
				"120000002001011100022022001000100",
				"220000002001011100022022001000100",
				"120000002001011100202022000010100",
				"220000002001011100202022000010100",
				"220000002010011100022022010000100",
				"120000002010011100202022000100100",
				"220000002010011100202022000100100",
				"220000002010011100220022000001100",
				"120000002011001100220022000100100",
				"220000002011001100220022000100100",
				"220000002011001100222002000000110",
				"220000002011010100222020000000101",
				"220000002011011000222002000001100",
				"220000002011011000222020000000110",
				"220000002011011110222020000000000"
			]
		}, {
			name:
				"1" +
				"20002000" +
				"00001000" +
				"00020000" +
				"01000011",
			children: [
				"2" +
				"20002000" +
				"00000000" +
				"00000000" +
				"01100011"
			]
		}, {
			name:
				"2" +
				"20002000" +
				"00001000" +
				"00020000" +
				"01000011",
			children: [
				"1" +
				"20000000" +
				"00000000" +
				"00022000" +
				"01000011",
				"1" +
				"20002200" +
				"00000000" +
				"00000000" +
				"01000011"
			]
		}, {
			name:
				"2" +
				"20002000" +
				"00000000" +
				"00000000" +
				"01100011",
			children: []
		}];

		for(test in tests) {
			var record = new Record(test.name, []);
			record.createChildren();
			Assert.equals(test.children.length, record.children.length);
			for(childName in test.children) {
				var results = record.children.filter(function(child) {
					return child.name == childName;
				});
				Assert.equals(1, results.length);
			}
		}
	}
}
