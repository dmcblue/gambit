package dmcblue.gambit.server;

// enum GameState {
// 	WAITING;
// 	PLAYING;
// 	DONE;	
// }

@:enum abstract GameState(Int) to Int {
	var WAITING = 0;
	var PLAYING = 1;
	var DONE = 2;
}
