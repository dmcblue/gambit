package dmcblue.gambit.server;

import interealmGames.common.uuid.UuidV4;
import dmcblue.gambit.Board;
import dmcblue.gambit.Piece;
import dmcblue.gambit.server.parameters.MoveParams.MoveObject;

typedef ExternalGameRecordObject =  {
	var id:UuidV4; // UUID v4
	var board:String;
	var currentPlayer:Piece;
	var canPass:Bool;
	var state:GameState;
	var ?player:UuidV4;
	var ?team:Piece;
	var ?lastMove:MoveObject;
};
