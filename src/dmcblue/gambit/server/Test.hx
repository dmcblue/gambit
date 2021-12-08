package dmcblue.gambit.server;

import utest.Runner;
import utest.ui.Report;
import dmcblue.gambit.server.GameRecordTest;

/**
 * All tests for this package
 */
class Test {
	public static function main() {
		var runner:Runner = new Runner();
		runner.addCase(new GameRecordTest());
		Report.create(runner);
		runner.run();
	}
}
