helpers = require './helpers'

[ PLAYERS, LAST_MARBLE ] = helpers.input '9'
  .match /\d+/g
  .map Number

# Marble class (node)
class Marble
  constructor: (@value, @prev, @next) ->

# Game class (two-way linked list)
class Game
  constructor: (@players) ->
    @current = new Marble 0, null, null
    @current.prev = @current
    @current.next = @current
    @marble = 1

  # Navigate around the marble circle
  forward: (n) -> @current = @current.next for _ in [1..n]
  backward: (n) -> @current = @current.prev for _ in [1..n]

  # Add a marble
  addMarble: () ->
    @current = new Marble @marble++, @current, @current.next
    @current.prev.next = @current
    @current.next.prev = @current

  # Remove a marble and return its value
  removeMarble: () ->
    { prev, next, value } = @current
    prev.next = next
    next.prev = prev
    @current = next
    value

  # Play one turn of the game
  playTurn: () ->
    if @marble % 23
      # Add marble to circle, award no points
      @forward 1
      @addMarble() and 0
    else
      # Award value of current plus marble 7 places back
      @backward 7
      @removeMarble() + @marble++


## PART 1 SOLUTION ##
day9 = (multiplier = 1) ->
  game = new Game()
  scores = Array(PLAYERS).fill 0
  player = 0

  # Play the game
  while game.marble < LAST_MARBLE * multiplier
    scores[player] += game.playTurn()
    player = (player + 1) % PLAYERS

  Math.max ...scores

## PART 2 SOLUTION ##
day9_adv = -> day9 100

console.log day9()
console.log day9_adv()