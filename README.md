# Minesweeper

Minesweeper is a RESTful service that expose an API to manage and play minesweeper.
It supports:
* Multiple user accounts
* Ability to play multiple games per user
* Ability to resume any undecided game anytime
* Keep tracks of start and decision date of the game
* Allows to mark ("?"), flag ("F"), or swipe (" ") cells
* Swiping cells with no adjacent mines, propagates the swipe
* Provides hints with the mount of adjacent mines in cleared cells

## Running it locally
```bash
git clone git@github.com:rosacris/minesweeper.git .
&& cd minesweeper/
&& mix deps.get
&& iex -S mix
```

### Database creation
The database needs to be created on the first execution.
This is achieved by running the following command from `iex`:
```elixir
iex(1)> Minesweeper.Console.setup!()
```

### Adding users
Users can be added by running the following command from the `iex`:
```elixir
iex(2)> Minesweeper.User.add("someuser", "somepass")
```
and you can verify the login as follows:
```elixir
iex(3)> Minesweeper.User.login("someuser", "somepass")
"EB7BC743D1A86E2FBE99A1027D8D5349C7FEF0C5F0F4F6F5CA4CA8B4EE1FCA0E"
```
That is the session token expected by the endpoints as an `authorization` header.
You can retrieve this token using the login endpoint as well.

## Endpoints

### Login
Logins a user 

```
curl -d '{"username":"pepe", "password":"toto"}' -H "Content-Type: application/json" -X POST "localhost:4001/login"
{"token":"4308D6D5F0E24EFF89623BD1DA22BBEBD623B364DB79B73F0FE332C5F8393C2C"}
```

### Get game list
List all authenticated user game identifiers

```
curl -H "Authorization: 4308D6D5F0E24EFF89623BD1DA22BBEBD623B364DB79B73F0FE332C5F8393C2C" -H "Content-Type: application/json" -X GET "localhost:4001/games"
[2]
```

### Get a game state
Get the state of user game 2:

```
curl -H "Authorization: 4308D6D5F0E24EFF89623BD1DA22BBEBD623B364DB79B73F0FE332C5F8393C2C" -H "Content-Type: application/json" -X GET "localhost:4001/games/2"
{
  "user_id": 2,
  "started_at": "2021-01-04T22:23:18.897203Z",
  "mines": 1,
  "id": 2,
  "game_status": "undecided",
  "ended_at": null,
  "board": [
    ["#", "#", "#", "#", "#"],
    ["#", "#", "#", "#", "#"],
    ["#", "#", "#", "#", "#"],
    ["#", "#", "#", "#", "#"],
    ["#", "#", "#", "#", "#"]
  ]
}
```

### Create a new game
Create a new game of size 2x2 with 1 mine:
```
curl -d '{"rows": 2, "cols": 2, "mines": 1}' -H "Authorization: 4308D6D5F0E24EFF89623BD1DA22BBEBD623B364DB79B73F0FE332C5F8393C2C" -H "Content-Type: application/json" -X POST "localhost:4001/games"
{
  "user_id": 2,
  "started_at": "2021-01-04T22:28:42.285776Z",
  "mines": 1,
  "id": 3,
  "game_status": "undecided",
  "ended_at": null,
  "board": [
    ["#", "#"],
    ["#", "#"]
  ]
}
```

### Change a board cell
```
curl -d '{"row": 0, "col": 0, "status": "?"}' -H "Authorization: 4308D6D5F0E24EFF89623BD1DA22BBEBD623B364DB79B73F0FE332C5F8393C2C" -H "Content-Type: application/json" -X PUT "localhost:4001/games/3/board"
```
You have to fetch the board again to see the changes reflected

## Architecture
The architecture attempts to provide a minimalistic (yet feature complete) API for the minesweeper game.
For this reason, it keeps external dependencies to the bare minimum.
In addition, it runs its own on-disk database to avoid depending on external servicies at runtime.

The design of the API guarantees that all game state changes are decided by the server to avoid
cheating by the users.
### HTTP Server
Minesweeper uses Erlang's `:cowboy` HTTP server which is the defacto standard.
Serialization and deserialization is done by the `:poison` library.

### Database
Minesweeper uses Erlang's `mnesia` database mainly due to its simplicity.
It provides a simple on-disk key/value store with transactional semantics.
Moreover, `mnesia` already handles Elixir data serialization/deserialization out-of-the-box.
It is important to note that we use the `:memento` library that is a wrapper around `:mnesia` that
exposes an API that is better tailored to Elixir style.
A full fledged solution may use DynamoDB or any key/value store for proper scalability.

### Authentication
Minesweeper implements a very simple ad-hoc token based request authentication method.
Each user that logins successfully is assigned a random token that expires in one hour.
The token is persisted in the `User` record table.
Further possible improvements are the use of JWT, and an in-memory cache to avoid hitting the database
on each request.

### Modules
Minesweeper is an Elixir/OTP app that is composed of five main modules:

#### Board Module
The Board implements the game logic written in a purely functional way (no side-effects).

An example:
```elixir
Board.new(5, 5, 1)
|> Board.mark(1, 2)
|> Board.swipe(3, 3)
|> Board.flag(2, 3)
|> Board.decide()
```
Here we create a new board of 5x5 with 1 mine, then mark cell (1, 2) as suspicious,
then swipe starting from cell (3, 3), next we flag cell (2, 3), and finally we decide the board.

Game logic is tested at this stage given the simplicity of asserting after chaining actions.

#### Minesweeper Module
The Minesweeper module has the use cases offered by the API.
It acts as a context boundary, and the API can be used from many clients such as the endpoints controller or a command line console.

The module fetches the games from the database, performs the desired actions on the board
(using the Board module) and persists changes back into the database.
It has no knowledge of game rules, endpoints, nor database details.

Each use case has a top-level `try/rescue` wrapper to avoid leaking any exceptions outside the boundaries
of the module.

Example
```elixir
def list_games(user_id) do
  try do
    Game.list(user_id)
    |> Enum.map(fn game -> Map.fetch!(game, :id) end)
  rescue
    e -> {:error, e.message}
  end
end
```
Here, the use case that list the games of a user. It acces the database using Game module and
returns the list of game ids.

#### Game Module
The Game module defines the table schema for persisting games.
It also offers get/create/update functions with transactional guarantees.

#### User Module
The User module defines the table schema for persisting user credentials and tokens.
It also offers get/create/update functions with transactional guarantees.

#### AuthRouter
The AuthRouter module implements the authenticated endpoints.
It defines its own Cowboy Plug pipeline that decodes JSON payloads, and injects user identity in the request context.
Each endpoint calls one or more use case in `Minesweeper` module.

## Final considerations
After evaluating several API options, it is clear that REST is better suited for applications where the
semantics of the changes are more CRUD like.
In case of games, where state changes must be decided by the server, perhaps a more RPC API would convey
the semantics of the actions more precisely (i.e JsonRPC)