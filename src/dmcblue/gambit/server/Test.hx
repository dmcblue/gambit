package dmcblue.gambit.server;

import interealmGames.server.http.test.Server;
import utest.Runner;
import utest.ui.Report;
import dmcblue.gambit.server.GameRecordPersistenceTest;
import dmcblue.gambit.server.Persistence;
import dmcblue.gambit.server.HandlersTest;
import dmcblue.gambit.server.Handlers;
import interealmGames.server.http.test.Server;
import interealmGames.persistence.FileSystemConnection;
import interealmGames.persistence.InMemoryFileSystemConnection;

/**
 * All tests for this package
 */
class Test {
	static public var server:Server;
	static public var persistence:Persistence;
	static public var fileConnection:FileSystemConnection;

	public static function main() {
		Test.fileConnection = new InMemoryFileSystemConnection();
		Test.persistence = new Persistence(Test.fileConnection);
		var handlers = new Handlers(Test.persistence);
		Test.server = new Server(handlers.getHandlers());
		var runner:Runner = new Runner();
		runner.addCase(new GameRecordPersistenceTest());
		runner.addCase(new HandlersTest());
		Report.create(runner);
		runner.run();
	}
}
