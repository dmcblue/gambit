package dmcblue.gambit.ai;

import utest.Assert;
import utest.Async;
import utest.Test;
import dmcblue.gambit.ai.Record;

class RecordTest extends Test {
	public function testCreateChildren() {
		var name =
			"1" +
			"20000002" +
			"01101110" +
			"02220220" +
			"00000100";
		var expectedChildName =
			"1" +
			"20000002" +
			"01001110" +
			"02020220" +
			"00100100";
		var record = new Record(name, []);
		record.createChildren();
		var results = record.children.filter(function(child) {
			return child.name == expectedChildName;
		});
		Assert.equals(1, results.length);
	}
}
