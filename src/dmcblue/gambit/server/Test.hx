package dmcblue.gambit.server;

import interealmGames.server.http.test.Server;
import utest.Runner;
import utest.ui.Report;
import dmcblue.gambit.server.GameRecordTest;
import dmcblue.gambit.server.Persistence;
import dmcblue.gambit.server.HandlersTest;
import dmcblue.gambit.server.Handlers;
import interealmGames.server.http.test.Server;
import interealmGames.persistence.InMemoryFileSystemConnection;

/**
 * All tests for this package
 */
class Test {
	static public var server:Server;

	public static function main() {
		var fileConnection = new InMemoryFileSystemConnection();
		var persistence = new Persistence(fileConnection);
		var handlers = new Handlers(persistence);
		Test.server = new Server(handlers.getHandlers());
		var runner:Runner = new Runner();
		runner.addCase(new GameRecordTest());
		runner.addCase(new HandlersTest());
		Report.create(runner);
		runner.run();
	}
}
