package dmcblue.gambit.server;

import interealmGames.persistence.ConnectionFactory.Configuration in DBConfig;

typedef Configuration = {
	gameConnection:DBConfig,
	aiConnection:DBConfig,
};
