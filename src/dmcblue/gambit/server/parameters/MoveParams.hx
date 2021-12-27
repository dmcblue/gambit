package dmcblue.gambit.server.parameters;

import interealmGames.common.uuid.UuidV4;
import dmcblue.gambit.Point;

typedef MoveObject = {
	from: Point,
	to: Point
};

typedef MoveParams = {
	var move: MoveObject;
	var player: UuidV4;
};
