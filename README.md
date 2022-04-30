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

## Development

Many tasks are handled by [OpenTask](https://github.com/interealm-games/opentask). It is recommended to download an executable from the releases before going forward.

All steps listed below are done using the OpenTask [config](opentask.json), but you can read it to do the steps manually if you do not have a OpenTask executable available.

[Haxe](https://haxe.org/) will also need to be installed.

Once the repo has been cloned locally, check if you have the 

initialize all the dependencies with:
```shell
opentask rungroup init
```

### Server

The server is build using [interfaces](https://github.com/interealm-games/server/tree/main/src/interealmGames/server/http) from [interealm-games/server](https://github.com/interealm-games/server), meaning the code can be run by any http server that implements those same interaces.

Gambit is currently using the [interealm-games/server-php](https://github.com/interealm-games/server-php) implementation.

Server will need:
- PHP 7.4 (with an executable aliased as `php7`)
- Redis installed

Steps:
- Clone the [interealm-games/server-php](https://github.com/interealm-games/server-php) repo.
- In that repo, run `opentask rungroup init`
- And `opentask rungroup build`
- Create a configuration file according to the requirements of [src/dmcblue/gambit/server/Configuration.hx](src/dmcblue/gambit/server/Configuration.hx)
	```json
	{
		"gameConnection": {
			"type": "EXPIRING_REDIS",
			"db": 7,
			"expirationSeconds": 604800,
			"host": "localhost",
			"port": 6379
		},
		"aiConnection": {
			"type": "FILE",
			"extension": "json",
			"path": "/ai/"
		}
	}
	```
- Indicate the path of the configuration file in a `.env` file below the expected working directory of the server.
  For `server-php`, the working directory is `api/public` so the .env file should be in `api`.
  ```
    # no quotation marks
	GAMBIT_CONFIG_PATH=/gambit/config.json
  ```
- In the `gambit` repository, build the endpoints in the target language (here `php`)
  ```
  opentask rungroup build:server
  ```
-  Indicate to `server-php` where the endpoints can be picked up by placing a `.env` file in `server-php/environments`
  ```
  # relative path
  REQUEST_HANDLERS_PATH="../../../gambit/bin/index.php"
  ```
- Run development server (in `server-php`) `composer start run`

### Client

The code base allows for the implementation of synchronous and asynchronous clients and implements one of each, in C++ and Javascript respectively.

For both, you will need to make an environment file:
```
cp src/dmcblue/gambit/Environment.hx.template src/dmcblue/gambit/Environment.hx
```
and adjust it accordingly.

#### Web

```
opentask rungroup build:web
```

will build a website client at `bin/web`.

#### Terminal

```
opentask rungroup init # install all dependencies
opentask rungroup build # build an executable to bin/gambit
```

Then run:
```
bin/gambit
```


References: 
- https://invisible-island.net/ncurses/man/ncurses.3x.html
- https://github.com/tony/NCURSES-Programming-HOWTO-examples/blob/master/16-panels/show-hide.c
- https://tldp.org/HOWTO/NCURSES-Programming-HOWTO/menus.html
