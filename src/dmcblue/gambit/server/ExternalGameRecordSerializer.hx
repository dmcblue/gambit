package dmcblue.gambit.server;

import dmcblue.gambit.Piece;
import dmcblue.gambit.Move;
import interealmGames.common.uuid.UuidV4;
import dmcblue.gambit.server.ExternalGameRecordObject;
import dmcblue.gambit.server.ExternalGameRecordObject;
import interealmGames.common.serializer.object.Json;
import interealmGames.common.serializer.object.Serializer;
import interealmGames.persistence.ObjectPersistence;
import dmcblue.gambit.server.GameRecord;

class ExternalGameRecordObjectSerializer extends Json<ExternalGameRecordObject> {}

class ExternalGameRecordSerializer implements Serializer<GameRecord> {
	private var sessionPlayer:UuidV4;
	private var objectSerializer:ExternalGameRecordObjectSerializer;
	private var persistence:ObjectPersistence<String, GameRecord>;
	private var lastMove:Move;
	public function new(
		persistence:ObjectPersistence<String, GameRecord>,
		sessionPlayer:UuidV4,
		?lastMove:Move
	) {
		this.objectSerializer = new ExternalGameRecordObjectSerializer();
		this.persistence = persistence;
		this.sessionPlayer = sessionPlayer;
		this.lastMove = lastMove;
	}

	public function decode(s:String):GameRecord {
		var egro:ExternalGameRecordObject = this.objectSerializer.decode(s);
		return this.persistence.get(egro.id);
	}

	public function encode(gameRecord:GameRecord):String {
		var obj:ExternalGameRecordObject = {
			id: gameRecord.id,
			board: gameRecord.board.toString(),
			currentPlayer: gameRecord.currentPlayer,
			canPass: gameRecord.canPass,
			state: gameRecord.state
		};

		if (this.sessionPlayer != null) {
			obj.player = this.sessionPlayer;

			if (gameRecord.black != "" || gameRecord.white != "") {
				obj.team = gameRecord.black == this.sessionPlayer ? Piece.BLACK : Piece.WHITE;
			}
		}

		if (this.lastMove != null) {
			obj.lastMove = {
				from: this.lastMove.from.toPoint(),
				to: this.lastMove.to.toPoint()
			};
		}

		return this.objectSerializer.encode(obj);
	}
}
