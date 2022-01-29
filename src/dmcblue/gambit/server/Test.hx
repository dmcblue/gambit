package dmcblue.gambit.server;

import dmcblue.gambit.server.Api;
import dmcblue.gambit.server.Api;
import interealmGames.browser.api.TestApi;
import interealmGames.server.http.test.Server;
import interealmGames.server.http.test.Server;
import utest.Runner;
import utest.ui.Report;
import dmcblue.gambit.server.ApiAiJoinTest;
import dmcblue.gambit.server.ApiAiMoveTest;
import dmcblue.gambit.server.ApiCreateTest;
import dmcblue.gambit.server.ApiGetTest;
import dmcblue.gambit.server.ApiJoinTest;
import dmcblue.gambit.server.ApiMoveTest;
import dmcblue.gambit.server.ApiPassTest;
import dmcblue.gambit.server.ApiStatusTest;
import dmcblue.gambit.server.GameRecordPersistenceTest;
import dmcblue.gambit.server.Persistence;
import dmcblue.gambit.server.HandlersAiJoinTest;
import dmcblue.gambit.server.HandlersAiMoveTest;
import dmcblue.gambit.server.HandlersCreateTest;
import dmcblue.gambit.server.HandlersGetTest;
import dmcblue.gambit.server.HandlersJoinTest;
import dmcblue.gambit.server.HandlersMoveTest;
import dmcblue.gambit.server.HandlersPassTest;
import dmcblue.gambit.server.HandlersStatusTest;
import dmcblue.gambit.server.Handlers;
import interealmGames.server.http.test.Server;
import interealmGames.persistence.MemoryConnection;

/**
 * All tests for this package
 */
class Test {
	static public var api:Api;
	static public var server:Server;
	static public var persistence:Persistence;
	static public var connection:MemoryConnection;

	public static function main() {
		Test.connection = new MemoryConnection();
		Test.persistence = new Persistence(Test.connection, Test.connection);
		var handlers = new Handlers(Test.persistence);
		Test.server = new Server(handlers.getHandlers());
		var api = new TestApi('https://www.gambit.com/api', Test.server);
		Test.api = new Api(api, 'https://www.gambit.com/api');
		var runner:Runner = new Runner();
		runner.addCase(new ApiAiJoinTest());
		runner.addCase(new ApiAiMoveTest());
		runner.addCase(new ApiCreateTest());
		runner.addCase(new ApiGetTest());
		runner.addCase(new ApiJoinTest());
		runner.addCase(new ApiMoveTest());
		runner.addCase(new ApiPassTest());
		runner.addCase(new ApiStatusTest());
		runner.addCase(new GameRecordPersistenceTest());
		runner.addCase(new HandlersAiJoinTest());
		runner.addCase(new HandlersAiMoveTest());
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
		Test.connection.clearAll();
	}
}
