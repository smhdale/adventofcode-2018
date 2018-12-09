helpers = require './helpers'

PLAYERS = 464
LAST_MARBLE = 71730

class Game
  constructor: (@players) ->
    @circle = [ 0 ]
    @current = 0
    @marble = 1
  
  addMarble: () ->
    numMarbles = @circle.length

    if @marble % 23
      # Add marble to circle and award no points
      @current = (@current + 2) % numMarbles
      @circle.splice(@current, 0, @marble++) and 0
    else
      # Marble is a multiple of 23
      @current = (@current - 7) %% numMarbles
      @circle.splice(@current, 1)[0] + @marble++


## PART 1 SOLUTION
day9 = () ->
  game = new Game()
  scores = Array(PLAYERS).fill 0
  player = 0

  # Play the game
  while game.marble < LAST_MARBLE
    scores[player] += game.addMarble()
    player = (player + 1) % PLAYERS
  
  Math.max ...scores

## PART 2 SOLUTION ##
day9_adv = () ->

console.log day9()
# console.log day9_adv()