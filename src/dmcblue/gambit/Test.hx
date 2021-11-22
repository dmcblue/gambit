package dmcblue.gambit;

import utest.Runner;
import utest.ui.Report;
import dmcblue.gambit.BoardTest;
import dmcblue.gambit.PositionTest;

/**
 * All tests for this package
 */
class Test {
	public static function main() {
		var runner:Runner = new Runner();
		runner.addCase(new BoardTest());
		runner.addCase(new PositionTest());
		Report.create(runner);
		runner.run();
	}
}
