package dmcblue.gambit.server;

import interealmGames.common.uuid.UuidV4;
import dmcblue.gambit.Board;
import dmcblue.gambit.Piece;
import dmcblue.gambit.server.parameters.MoveParams.MoveObject;

typedef GameRecordObject = {
	var id:UuidV4;
	var board:String;
	var currentPlayer:Piece;
	var canPass:Bool;
	var lastMove:MoveObject;
	var black:UuidV4;
	var white:UuidV4;
	var state:GameState;
};
