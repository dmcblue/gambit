package dmcblue.gambit.server;

import interealmGames.common.uuid.Uuid;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.GameRecordPersistence;
import interealmGames.persistence.ObjectPersistence;
import dmcblue.gambit.Piece;
import dmcblue.gambit.Position;
import dmcblue.gambit.server.GameRecord;
import dmcblue.gambit.server.GameRecordObject;
import dmcblue.gambit.server.errors.InvalidInputError;
import utest.Assert;
import utest.Async;
import utest.Test;
import haxe.Json;

class GameRecordPersistenceTest extends Test 
{
	private var persistence:ObjectPersistence<String, GameRecord>;
	public function setup() {
		Test.resetDatabase();
		this.persistence = new GameRecordPersistence(Test.connection);
	}

	public function testGet() {
		var record:GameRecordObject = {
			id: "1234",
			board: "00000000111111112222222200000000",
			currentPlayer: Piece.BLACK,
			canPass: false,
			lastMove: {
				from: { x: 1, y: 1 },
				to: { x: 2, y: 2 }
			},
			black: "5678",
			white: "9012",
			state: GameState.DONE
		};
		Test.connection.save('games', '1234', Json.stringify(record));
		var game = this.persistence.get("1234");
		Assert.equals("1234", game.id);
		Assert.equals("00000000111111112222222200000000", game.board.toString());
		Assert.equals(Piece.BLACK, game.currentPlayer);
		Assert.equals(false, game.canPass);
		Assert.equals("5678", game.black);
		Assert.equals("9012", game.white);
		Assert.equals(GameState.DONE, game.state);
		Assert.equals(1, game.lastMove.from.y);
		Assert.equals(2, game.lastMove.to.x);
	}

	public function testSave() {
		var id = Uuid.v4();
		var game = new GameRecord(
			id,
			Piece.BLACK,
			Board.newGame(),
			false,
			Uuid.v4(),
			Uuid.v4(),
			GameState.WAITING
		);
		this.persistence.save(game);
		var file = Test.connection.get('games', id);
		var game = Json.parse(file);
		Assert.isTrue(Reflect.hasField(game, 'id'));
		Assert.equals(36, Reflect.field(game, 'id').length);
		Assert.equals(Piece.BLACK, Reflect.field(game, 'currentPlayer'));
		Assert.equals(false, Reflect.field(game, 'canPass'));
		Assert.equals("00000000111111112222222200000000", Reflect.field(game, 'board'));
		Assert.equals(GameState.WAITING, Reflect.field(game, 'state'));
		Assert.isTrue(Reflect.hasField(game, 'lastMove'));
	}
}
