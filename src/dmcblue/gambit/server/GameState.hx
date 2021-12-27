package dmcblue.gambit.server;

enum abstract GameState(Int) {
	var WAITING = 0;
	var PLAYING = 1;
	var DONE = 2;
}
