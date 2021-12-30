# Random Notes

## Game

### instantiate/start
check status
See if join link

### create
create game, check

### join
get game id and run join, then check

### loop
-> get
  if currentPlayer
    show moves
    or pass
  call loop

## Endpoints

All requests should include an ID (UUID) for each player, they don't know each others.

### GET /status
Response
200

### POST /create
Request
- startingPlayer:Piece
Response
- Game UUID
- Player UUID
- Team
- GameRecord

### GET /join
Request
- Game UUID
Response
- Player UUID
- Team

### POST /move
Request
- Game UUID
- Player UUID
- from:
    - x
    - y
- to:
    - x
    - y
Response
- GameRecord
OR
- Error

### POST /game/{gameid}/pass
Request
- Game UUID
- User UUID

### GET /game/{id}
Response
- Game

Used to routinely check state changes

