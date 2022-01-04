# gambit

Gambit is a board game played on a 8x4 checkerboard. This repository implements the rules of the game
with a display interface, along with example implementation of that interface.

## Rules

The board is setup with the players facing either of the 8 piece sides.
A line of 8 pieces for each player are setup one piece away from the player, like:

```
 Player X

 --------
|        |
|XXXXXXXX|
|OOOOOOOO|
|        |
 --------

 Player O
```

Each player takes turns making moves.

Pieces are moved by jumping over a single piece of the opposing team in a straight line in any direction (orthogonal or diagonal) onto an empty space.
The piece that has been jumped over is removed from the board.
If a subsequent move is available, the same piece can make multiple jumps in a row before the turn is over.
The subsequent moves do not have to be in the same direction as the original jump.

The game ends when any player is unable to make a move on their turn.
The board is then scored.

Players earn points for each island of pieces they have on the board.
An island is a group of piece from the same side that does not touch any pieces of the opposing player, including diagonally.
Scores are by the number of pieces per island, added up for all islands for a player.

Scores per island:
- 1 piece:  1 point
- 2 pieces: 3 points
- 3 pieces: 5 points
- 4 pieces: 7 points
- 5 pieces: 9 points

The player with the most points wins.

## Display

This repository handles all game logic but does not implement the display interface (see [Display.hx](src/dmcblue/gambit/Display.hx))

An example implementation is given in the [terminal](src/dmcblue/gambit/terminal) subfolder.

The example implementation can be built from scratch using [OpenTask](https://github.com/interealm-games/opentask) with the commands:

```
opentask rungroup init # install all dependencies
opentask rungroup build # build an executable to bin/gambit
```

Then run:
```
bin/gambit
```

Alternatively, you can read `opentask.json` for the list of explicit commands.

## To Do

- Create asynchronous web server version
- Create AI player

## Server Setup

- Requires Redis to be installed and running
- If using PHP:
	- Make sure the `sockets` extension is enabled in `php.ini`.
