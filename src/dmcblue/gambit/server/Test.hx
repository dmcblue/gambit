package dmcblue.gambit.server;

import interealmGames.server.http.test.Server;
import utest.Runner;
import utest.ui.Report;
import dmcblue.gambit.server.GameRecordPersistenceTest;
import dmcblue.gambit.server.Persistence;
import dmcblue.gambit.server.HandlersCreateTest;
import dmcblue.gambit.server.HandlersGetTest;
import dmcblue.gambit.server.HandlersJoinTest;
import dmcblue.gambit.server.HandlersMoveTest;
import dmcblue.gambit.server.HandlersPassTest;
import dmcblue.gambit.server.HandlersStatusTest;
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
	static public var fileConnection:InMemoryFileSystemConnection;

	public static function main() {
		Test.fileConnection = new InMemoryFileSystemConnection();
		Test.persistence = new Persistence(Test.fileConnection);
		var handlers = new Handlers(Test.persistence);
		Test.server = new Server(handlers.getHandlers());
		var runner:Runner = new Runner();
		runner.addCase(new GameRecordPersistenceTest());
		runner.addCase(new HandlersCreateTest());
		runner.addCase(new HandlersGetTest());
		runner.addCase(new HandlersJoinTest());
		runner.addCase(new HandlersMoveTest());
		runner.addCase(new HandlersPassTest());
		runner.addCase(new HandlersStatusTest());
		Report.create(runner);
		runner.run();
	}

	public static function resetDatabase() {
		Test.fileConnection.clear();
	}
}
