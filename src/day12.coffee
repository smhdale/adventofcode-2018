helpers = require './helpers'

ALIVE = '#'
DEAD = '.'

parseInitial = (state) -> [ ...state.replace 'initial state: ', '' ]

# Stores map of pots with plants in them
class Pots
  constructor: (state) ->
    @min = 0
    @max = state.length - 1
    @rules = new Map()
    @state = new Map()
    for pot, i in state
      @state.set i, pot

  # Adds a rule for whether a plant survives in the next generation
  addRule: (rule) ->
    [ condition, outcome ] = rule.split ' => '
    @rules.set condition, outcome

  # Gets a segment of the pots map
  segment: (x, len = 5) ->
    [x...x + len]
      .map (i) => @state.get(i) or DEAD
      .join ''

  # Progresses to the next generation of plants
  grow: () ->
    min = @min - 2
    max = @max + 2

    # Work out next generation
    nextGen = (@rules.get @segment x - 2 for x in [min..max])

    # Update pots
    foundFirstAlive = no
    for x in [min..max]
      newState = nextGen[x - min]
      @state.set x, newState

      # Update pot bounds if a plant grew outside them
      if newState is ALIVE
        @max = Math.max @max, x
        if not foundFirstAlive
          foundFirstAlive = yes
          @min = x

  # Returns sum of the indexes of all living plants
  sumAliveIndexes: () ->
    total = 0
    for x in [@min..@max]
      if @state.get(x) is ALIVE
        total += x
    total

# Sets up pots and runs n generations of growing
growPlants = (generations) ->
  [ state, ...rules ] = [ ...helpers.inputLines '12' ]

  # Set up pots
  pots = new Pots parseInitial state
  pots.addRule rule for rule in rules

  # Grow some plants!
  for i in [1..generations]
    if not (i % 1000000000)
      console.log 'ayy'
    pots.grow()

  # Return sum of indexes of all pots with living plants
  pots.sumAliveIndexes()


## PART 1 SOLUTION ##
day12 = -> growPlants 20

## PART 2 SOLUTION ##
day12_adv = -> growPlants 50000000000

console.log day12()
console.log day12_adv()
