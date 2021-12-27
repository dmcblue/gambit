package dmcblue.gambit.server;

import interealmGames.common.uuid.UuidV4;
import dmcblue.gambit.Board;
import dmcblue.gambit.Piece;

typedef GameRecordObject = {
	var id:UuidV4;
	var board:String;
	var currentPlayer:Piece;
	var canPass:Bool;
	var black:UuidV4;
	var white:UuidV4;
	var state:GameState;
};
