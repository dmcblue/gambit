package dmcblue.gambit.server;

import interealmGames.server.http.Error;
import interealmGames.server.http.ErrorObject;
import interealmGames.common.uuid.Uuid;
import dmcblue.gambit.server.ExternalGameRecordObject;
import haxe.Json;
import interealmGames.server.http.test.Request;
import interealmGames.server.http.RequestType;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.errors.InvalidInputError;
import dmcblue.gambit.server.parameters.MoveParams;
import utest.Assert;
import utest.Async;
import utest.Test;

class ApiMoveTest extends Test 
{
	public function setup() {
		Test.resetDatabase();
	}

	public function testMove(async:Async) {
		var playerId = Uuid.v4();
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:MoveParams = {
			move: {
				from: {
					x: 2,
					y: 2
				},
				to: {
					x: 2,
					y: 0
				}
			},
			player: playerId
		};

		Test.api.move("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(error);
			Assert.equals("1234", Reflect.field(game, 'id'));
			Assert.equals(Piece.WHITE, Reflect.field(game, 'currentPlayer'));
			Assert.equals(false, Reflect.field(game, 'canPass'));
			Assert.equals("00200000110111112202222200000000", Reflect.field(game, 'board'));
			Assert.equals(GameState.PLAYING, Reflect.field(game, 'state'));
			Assert.isTrue(Reflect.hasField(game, 'player'));
			Assert.isTrue(Uuid.isV4(Reflect.field(game, 'player')));
			Assert.equals(otherPlayerId, Reflect.field(game, 'player'));
			async.done();
		});
	}

	public function testNotFound(async:Async) {
		var playerId = Uuid.v4();
		var params:MoveParams = {
			move: {
				from: {
					x: 2,
					y: 2
				},
				to: {
					x: 2,
					y: 0
				}
			},
			player: playerId
		};

		Test.api.move("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(404, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testGameUnstarted(async:Async) {
		var playerId = Uuid.v4();
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.WAITING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:MoveParams = {
			move: {
				from: {
					x: 2,
					y: 2
				},
				to: {
					x: 2,
					y: 0
				}
			},
			player: playerId
		};

		Test.api.move("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testGameFinished(async:Async) {
		var playerId = Uuid.v4();
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.DONE
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:MoveParams = {
			move: {
				from: {
					x: 2,
					y: 2
				},
				to: {
					x: 2,
					y: 0
				}
			},
			player: playerId
		};
		
		Test.api.move("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testBadPlayer(async:Async) {
		var randomId = Uuid.v4();
		var playerId = Uuid.v4();
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:MoveParams = {
			move: {
				from: {
					x: 2,
					y: 2
				},
				to: {
					x: 2,
					y: 0
				}
			},
			player: randomId
		};
		
		Test.api.move("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testWrongPlayer(async:Async) {
		var playerId = Uuid.v4();
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:MoveParams = {
			move: {
				from: {
					x: 2,
					y: 2
				},
				to: {
					x: 2,
					y: 0
				}
			},
			player: otherPlayerId
		};
		
		Test.api.move("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testWrongPiece(async:Async) {
		var playerId = Uuid.v4();
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:MoveParams = {
			move: {
				from: {
					x: 2,
					y: 1
				},
				to: {
					x: 2,
					y: 3
				}
			},
			player: playerId
		};
		
		Test.api.move("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testOccupiedSpace(async:Async) {
		var playerId = Uuid.v4();
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:MoveParams = {
			move: {
				from: {
					x: 2,
					y: 2
				},
				to: {
					x: 2,
					y: 1
				}
			},
			player: playerId
		};
		
		Test.api.move("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}

	public function testNoJump(async:Async) {
		var playerId = Uuid.v4();
		var otherPlayerId = Uuid.v4();
		var game: GameRecord = new GameRecord(
			"1234",
			Piece.BLACK,
			Board.newGame(),
			false,
			playerId, // black
			otherPlayerId, // white
			GameState.PLAYING
		);
		Test.persistence.getGameRecordPersistence().save(game);
		var params:MoveParams = {
			move: {
				from: {
					x: 2,
					y: 2
				},
				to: {
					x: 2,
					y: 3
				}
			},
			player: playerId
		};
		
		Test.api.move("1234", params, function(game:ExternalGameRecordObject, error:ErrorObject) {
			Assert.isNull(game);
			Assert.equals(400, Reflect.field(error, 'status'));
			Assert.isTrue(Reflect.hasField(error, 'message'));
			async.done();
		});
	}
}
