package dmcblue.gambit.ai;

import utest.Runner;
import utest.ui.Report;
import dmcblue.gambit.ai.AiTest;
import dmcblue.gambit.ai.RecordTest;

/**
 * All tests for this package
 */
class Test {
	public static function main() {
		var runner:Runner = new Runner();
		runner.addCase(new AiTest());
		runner.addCase(new RecordTest());
		Report.create(runner);
		runner.run();
	}
}
