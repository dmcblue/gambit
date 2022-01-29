package dmcblue.gambit.server.parameters;

import interealmGames.common.uuid.UuidV4;
import dmcblue.gambit.ai.Level;

typedef AiMoveParams = {
	var level: Level;
	var player: UuidV4;
};
